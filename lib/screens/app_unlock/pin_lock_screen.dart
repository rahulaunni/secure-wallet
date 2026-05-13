import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:local_auth/local_auth.dart';
import 'package:swallet/constants/layout_constants.dart';
import 'package:swallet/data/local/hive_boxes.dart';
import 'package:swallet/models/card_data.dart';
import 'package:swallet/models/card_type.dart';
import 'package:swallet/screens/app_unlock/security_setup_screen.dart';
import 'package:swallet/screens/app_unlock/security_verification_screen.dart';
import 'package:swallet/theme/swallet_theme.dart';
import 'package:swallet/utils/adaptive_layout.dart';
import 'package:swallet/utils/security_store.dart';
import 'package:swallet/widgets/add_card/add_card_material_tokens.dart';
import 'package:swallet/widgets/app_lock/security_features_intro_overlay.dart';
import 'package:swallet/widgets/buttons/custom_back_button.dart';
import 'package:swallet/widgets/card/bank_card.dart';
import 'package:swallet/widgets/card/secure_reveal_wrapper.dart';
import 'package:swallet/widgets/top_nav/top_nav_constants.dart';

class PinLockScreen extends StatefulWidget {
  final VoidCallback onUnlocked;
  final VoidCallback? onUnlockStarted;

  const PinLockScreen({
    super.key,
    required this.onUnlocked,
    this.onUnlockStarted,
  });

  @override
  State<PinLockScreen> createState() => _PinLockScreenState();
}

class _PinLockScreenState extends State<PinLockScreen>
    with TickerProviderStateMixin {
  final LocalAuthentication _auth = LocalAuthentication();
  final Box _settingsBox = Hive.box(HiveBoxes.settings);
  static const int _pinLength = 4;
  static const Color _lockBgLight = Color(0xFFF5F5F5);
  static const Color _lockBgDark = Color(0xFF000000);
  static const Color _lockTitleLight = Color(0xFF141414);
  static const Color _lockTitleDark = Color(0xFFF2F2F2);
  static const Color _lockSubtitleLight = Color(0xFF70757F);
  static const Color _lockSubtitleDark = Color(0xFFA7ACB5);
  static const Color _keyTextLight = Color(0xFF141414);
  static const Color _keyTextDark = Color(0xFFF2F2F2);

  String _enteredPin = '';
  String? _tempPinForCreation;
  bool _isCreating = false;
  bool _isError = false;
  bool _isUnlocking = false;
  bool _showResetButton = false;
  bool _securityIntroQueued = false;
  bool _securityIntroCompletedThisSession = false;
  String _errorMessage = '';
  String _statusMessage = 'Enter your App PIN';

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  late AnimationController _unlockController;
  late bool _isDark;

  @override
  void initState() {
    super.initState();
    _isDark = _settingsBox.get('is_dark', defaultValue: true);
    _initShakeAnimation();
    _unlockController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1180),
    );
    _checkPinStatus();
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _unlockController.dispose();
    super.dispose();
  }

  void _initShakeAnimation() {
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 24)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_shakeController)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _shakeController.reset();
          setState(() {
            _enteredPin = '';
            Timer(const Duration(milliseconds: 200), () {
              if (mounted) setState(() => _isError = false);
            });
          });
        }
      });
  }

  Future<void> _checkPinStatus() async {
    final savedPin = await SecurityStore.readPin();

    setState(() {
      _isError = false;
      _errorMessage = '';
      _enteredPin = '';
      _tempPinForCreation = null;
      _showResetButton = false;
    });

    if (savedPin == null) {
      setState(() {
        _isCreating = true;
        _statusMessage = 'Set a 4-digit PIN';
        _showResetButton = false;
      });
      _scheduleSecurityIntro();
      return;
    }

    setState(() {
      _isCreating = false;
      _statusMessage = 'Enter your App PIN';
      _showResetButton = false;
    });
    _triggerBiometrics();
  }

  void _scheduleSecurityIntro() {
    if (_securityIntroQueued || _securityIntroCompletedThisSession) return;

    _securityIntroQueued = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted || !_isCreating) {
        _securityIntroQueued = false;
        return;
      }

      final completed = await showGeneralDialog<bool>(
        context: context,
        barrierDismissible: false,
        barrierLabel: 'Security features introduction',
        barrierColor: Colors.transparent,
        transitionDuration: const Duration(milliseconds: 220),
        pageBuilder: (context, _, __) {
          return SecurityFeaturesIntroOverlay(
            isDark: _isDark,
            onDone: () => Navigator.of(context).pop(true),
          );
        },
        transitionBuilder: (context, animation, _, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          );
          return FadeTransition(
            opacity: curved,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.98, end: 1).animate(curved),
              child: child,
            ),
          );
        },
      );

      if (completed == true) {
        _securityIntroCompletedThisSession = true;
      }
      _securityIntroQueued = false;
    });
  }

  void _onNumTapped(String number) {
    if (_isUnlocking) return;

    if (_isError || _errorMessage.isNotEmpty) {
      setState(() {
        _isError = false;
        _errorMessage = '';
        _showResetButton = false;
      });
    }

    if (_enteredPin.length < _pinLength) {
      setState(() => _enteredPin += number);
      HapticFeedback.lightImpact();

      if (_enteredPin.length == _pinLength) {
        _handleSubmit();
      }
    }
  }

  void _onBackspace() {
    if (_isUnlocking) return;
    if (_enteredPin.isEmpty) return;

    setState(() {
      _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
      _isError = false;
      _showResetButton = false;
    });
    HapticFeedback.lightImpact();
  }

  Future<void> _handleSubmit() async {
    await Future.delayed(const Duration(milliseconds: 150));

    if (_isCreating) {
      await _handleCreationFlow();
    } else {
      await _handleUnlockFlow();
    }
  }

  Future<void> _handleCreationFlow() async {
    if (_tempPinForCreation == null) {
      setState(() {
        _tempPinForCreation = _enteredPin;
        _enteredPin = '';
        _statusMessage = 'Confirm your PIN';
      });
      return;
    }

    if (_enteredPin == _tempPinForCreation) {
      await SecurityStore.savePin(_enteredPin);
      HapticFeedback.mediumImpact();
      if (!mounted) return;

      final setupSuccess = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (context) => SecuritySetupScreen(isDark: _isDark),
        ),
      );

      if (setupSuccess == true) {
        if (!mounted) return;
        await _checkPinStatus();
        if (!mounted) return;
        _showSetupSnackBar();
      }
      return;
    }

    _triggerError('PINs did not match. Try again.');
    setState(() {
      _tempPinForCreation = null;
      _statusMessage = 'Set a 4-digit PIN';
    });
  }

  Future<void> _handleUnlockFlow() async {
    final savedPin = await SecurityStore.readPin();
    if (_enteredPin == savedPin) {
      HapticFeedback.mediumImpact();
      await _completeUnlock();
      return;
    }

    _triggerError('Wrong PIN');
    setState(() => _showResetButton = true);
  }

  void _triggerError(String msg) {
    HapticFeedback.heavyImpact();
    setState(() {
      _isError = true;
      _errorMessage = msg;
    });
    _shakeController.forward();
  }

  Future<void> _completeUnlock() async {
    if (_isUnlocking) return;

    setState(() {
      _isUnlocking = true;
      _isError = false;
      _errorMessage = '';
    });

    widget.onUnlockStarted?.call();
    await _unlockController.forward(from: 0);
    if (!mounted) return;
    widget.onUnlocked();
  }

  void _onBackFromConfirmation() {
    setState(() {
      _tempPinForCreation = null;
      _enteredPin = '';
      _statusMessage = 'Set a 4-digit PIN';
      _isError = false;
      _errorMessage = '';
      _showResetButton = false;
    });
  }

  Future<void> _triggerBiometrics() async {
    if (_isCreating) return;
    final useBio = _settingsBox.get('use_biometrics', defaultValue: false);
    if (!useBio) return;

    try {
      final canCheck = await _auth.canCheckBiometrics;
      if (!canCheck) return;

      final didAuthenticate = await _auth.authenticate(
        localizedReason: 'Unlock App',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (didAuthenticate) {
        await _completeUnlock();
      }
    } catch (e) {
      debugPrint('Biometric error: $e');
    }
  }

  void _showSetupSnackBar() {
    final tokens = AddCardMaterialTokens(_isDark);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(CupertinoIcons.check_mark, color: tokens.onPrimary, size: 18),
            const SizedBox(width: 8),
            Text(
              'Setup successful',
              style: GoogleFonts.roboto(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: tokens.onPrimary,
              ),
            ),
          ],
        ),
        backgroundColor: tokens.primary,
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        shape: RoundedRectangleBorder(borderRadius: tokens.pillRadius),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AddCardMaterialTokens(_isDark);
    final isStep2 = _isCreating && _tempPinForCreation != null;
    final useClassicPinLayout = _isCreating;
    final lockBackground = _isDark ? _lockBgDark : _lockBgLight;
    final overlayStyle = SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: _isDark ? Brightness.light : Brightness.dark,
      statusBarBrightness: _isDark ? Brightness.dark : Brightness.light,
      systemNavigationBarColor:
          useClassicPinLayout ? tokens.surface : lockBackground,
      systemNavigationBarIconBrightness:
          _isDark ? Brightness.light : Brightness.dark,
    );

    final content = useClassicPinLayout
        ? _buildClassicPinContent(tokens: tokens, isStep2: isStep2)
        : Stack(
            children: [
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _unlockController,
                  builder: (context, _) {
                    final fade =
                        1 - _interval(_unlockController.value, 0.08, 0.5);
                    return IgnorePointer(
                      child: Opacity(
                        opacity: fade,
                        child: ColoredBox(color: lockBackground),
                      ),
                    );
                  },
                ),
              ),
              _buildPinContent(
                tokens: tokens,
                isStep2: isStep2,
              ),
            ],
          );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyle,
      child: Scaffold(
        backgroundColor:
            useClassicPinLayout ? tokens.surface : Colors.transparent,
        body: content,
      ),
    );
  }

  Widget _buildPinContent({
    required AddCardMaterialTokens tokens,
    required bool isStep2,
  }) {
    return ValueListenableBuilder<Box<CardData>>(
      valueListenable: Hive.box<CardData>(HiveBoxes.cards).listenable(),
      builder: (context, cardsBox, _) {
        final savedCards = cardsBox.values.toList(growable: false);
        if (savedCards.isEmpty) {
          return _buildClassicPinContent(tokens: tokens, isStep2: isStep2);
        }

        return _buildWalletPinContent(
          tokens: tokens,
          isStep2: isStep2,
          savedCards: savedCards,
        );
      },
    );
  }

  Widget _buildWalletPinContent({
    required AddCardMaterialTokens tokens,
    required bool isStep2,
    required List<CardData> savedCards,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final mediaSize = MediaQuery.sizeOf(context);
        final mediaPadding = MediaQuery.paddingOf(context);
        final maxWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : mediaSize.width;
        final maxHeight = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : mediaSize.height;
        final safeHeight = maxHeight - mediaPadding.top - mediaPadding.bottom;
        const sourceWidth = 357.0;
        const titleHeight = 52.0;
        const titleTopOffset = 24.0;
        const minWalletGap = 24.0;
        const keypadHeight = 380.0;
        const keypadBottomOffset = 28.0;
        const walletHeroScale = 0.92;
        const designContentHeight = titleTopOffset +
            titleHeight +
            (minWalletGap * 2) +
            (280 * walletHeroScale) +
            keypadHeight +
            keypadBottomOffset;
        final widthScale = (maxWidth - 48) / sourceWidth;
        final heightScale = safeHeight / designContentHeight;
        final scale = math.max(
          0.52,
          math.min(1.0, math.min(widthScale, heightScale)),
        );
        final walletScale = scale * walletHeroScale;
        final walletWidth = sourceWidth * walletScale;
        final walletHeight = 280 * walletScale;
        final titleTop = mediaPadding.top + (titleTopOffset * scale);
        final titleBottom = titleTop + (titleHeight * scale);
        final keypadTop = maxHeight -
            mediaPadding.bottom -
            (keypadBottomOffset * scale) -
            (keypadHeight * scale);
        final walletGap = math.max(
          minWalletGap * scale,
          (keypadTop - titleBottom - walletHeight) / 2,
        );
        final walletTop = titleBottom + walletGap;
        final keypadWidth = ((80 * scale) * 3) + ((28 * scale) * 2);
        final canvasWidth = maxWidth;
        final canvasHeight = maxHeight;
        final walletLeft = (canvasWidth - walletWidth) / 2;
        final homeFirstCardTop =
            mediaPadding.top + 14 + 48 + 14 + topNavHeight + 12;

        return SizedBox(
          width: canvasWidth,
          height: canvasHeight,
          child: AnimatedBuilder(
            animation: _unlockController,
            builder: (context, _) {
              final chromeOpacity =
                  1 - Curves.easeOut.transform(_unlockController.value);

              return Stack(
                children: [
                  Positioned(
                    left: 16 * scale,
                    right: 16 * scale,
                    top: titleTop,
                    child: Opacity(
                      opacity: chromeOpacity,
                      child: _buildTitleHeader(tokens, isStep2, scale),
                    ),
                  ),
                  Positioned(
                    left: walletLeft,
                    top: walletTop,
                    child: _buildWalletHero(
                      cards: _lockCards(savedCards),
                      hasSavedCards: true,
                      scale: walletScale,
                      canvasWidth: canvasWidth,
                      walletLeftOnCanvas: walletLeft,
                      walletTopOnCanvas: walletTop,
                      homeFirstCardTop: homeFirstCardTop,
                    ),
                  ),
                  Positioned(
                    left: (canvasWidth - keypadWidth) / 2,
                    top: keypadTop,
                    child: Opacity(
                      opacity: chromeOpacity,
                      child: _buildNumPad(tokens, scale: scale),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildTitleHeader(
    AddCardMaterialTokens tokens,
    bool isStep2,
    double scale,
  ) {
    final titleColor = _isDark ? _lockTitleDark : _lockTitleLight;
    final subtitleColor = _isDark ? _lockSubtitleDark : _lockSubtitleLight;

    return SizedBox(
      height: 42 * scale,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (_isCreating && isStep2)
            Align(
              alignment: Alignment.centerLeft,
              child: CustomBackButton(
                isDark: _isDark,
                onTap: _onBackFromConfirmation,
              ),
            ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Swallet',
                style: GoogleFonts.poppins(
                  fontSize: 20 * scale,
                  height: 1,
                  fontWeight: FontWeight.w600,
                  color: titleColor,
                ),
              ),
              SizedBox(height: 4 * scale),
              Text(
                _isCreating ? _statusMessage : 'Your digital card storage',
                style: GoogleFonts.poppins(
                  fontSize: 14 * scale,
                  height: 1.25,
                  fontWeight: FontWeight.w400,
                  color: subtitleColor,
                ),
              ),
            ],
          ),
          if (_isCreating)
            Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildStepIndicator('1', true, tokens),
                  Container(
                    width: 24,
                    height: 1,
                    color: tokens.outlineVariant,
                  ),
                  _buildStepIndicator('2', isStep2, tokens),
                ],
              ),
            ),
        ],
      ),
    );
  }

  List<CardData> _lockCards(List<CardData> savedCards) {
    return savedCards.take(3).toList(growable: false);
  }

  Widget _buildWalletHero({
    required List<CardData> cards,
    required bool hasSavedCards,
    required double scale,
    required double canvasWidth,
    required double walletLeftOnCanvas,
    required double walletTopOnCanvas,
    required double homeFirstCardTop,
  }) {
    final heroWidth = 357 * scale;
    final heroHeight = 280 * scale;
    final backPlateLeft = 18.2856 * scale;
    final backPlateTop = 54.8574 * scale;
    final backPlateWidth = 320 * scale;
    final pocketLeft = 18.2856 * scale;
    final pocketTop = 118.857 * scale;
    final pocketWidth = 320 * scale;
    final walletHeight = 149.333 * scale;
    const cardStartInset = 16.0;
    final cardStartWidth = backPlateWidth - (cardStartInset * 2);
    final cardStartLeft = backPlateLeft + cardStartInset;

    return AnimatedBuilder(
      animation: Listenable.merge([_shakeController, _unlockController]),
      builder: (context, child) {
        final unlock = _unlockController.value;
        final walletExit = _walletExitProgress(unlock);
        final walletOpacity = 1 - _interval(unlock, 0.12, 0.42);
        final walletOffset = Offset(0, 178 * scale * walletExit);

        return Transform.translate(
          offset: Offset(_shakeAnimation.value * 2, 0),
          child: SizedBox(
            width: heroWidth,
            height: heroHeight,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topCenter,
              children: [
                Positioned(
                  left: backPlateLeft,
                  top: backPlateTop,
                  child: Transform.translate(
                    offset: walletOffset,
                    child: Opacity(
                      opacity: walletOpacity,
                      child: _buildWalletBackPlate(
                        width: backPlateWidth,
                        height: 213.333 * scale,
                        scale: scale,
                      ),
                    ),
                  ),
                ),
                for (var i = 0; i < cards.length; i++)
                  Positioned(
                    left: hasSavedCards
                        ? _animatedCardLeft(
                            index: i,
                            unlock: unlock,
                            startLeft: cardStartLeft,
                            startWidth: cardStartWidth,
                            finalLeft: _homeCardLeft(
                                  i,
                                  canvasWidth: canvasWidth,
                                ) -
                                walletLeftOnCanvas,
                          )
                        : cardStartLeft,
                    top: hasSavedCards
                        ? _animatedCardTop(
                            index: i,
                            stackSlot: i + (3 - cards.length),
                            unlock: unlock,
                            scale: scale,
                            walletTopOnCanvas: walletTopOnCanvas,
                            homeFirstCardTop: homeFirstCardTop,
                            canvasWidth: canvasWidth,
                          )
                        : switch (i) {
                            0 => 8.38098 * scale,
                            1 => 47.2382 * scale,
                            _ => 83.0477 * scale,
                          },
                    child: Transform.translate(
                      offset: hasSavedCards ? Offset.zero : walletOffset,
                      child: Opacity(
                        opacity: hasSavedCards ? 1 : walletOpacity,
                        child: _buildScaledHomeCard(
                          cards[i],
                          width: hasSavedCards
                              ? _animatedCardWidth(
                                  index: i,
                                  unlock: unlock,
                                  startWidth: cardStartWidth,
                                )
                              : cardStartWidth,
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  left: pocketLeft,
                  top: pocketTop,
                  child: Transform.translate(
                    offset: walletOffset,
                    child: IgnorePointer(
                      ignoring: walletOpacity == 0,
                      child: Opacity(
                        opacity: walletOpacity,
                        child: _buildWalletPocket(
                          width: pocketWidth,
                          height: walletHeight,
                          scale: scale,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  double _animatedCardLeft({
    required int index,
    required double unlock,
    required double startLeft,
    required double startWidth,
    required double finalLeft,
  }) {
    final stackLeft = startLeft;
    final liftProgress = _cardLiftProgress(unlock);
    final settleProgress = _cardSettleProgress(index, unlock);
    final liftedLeft = startLeft + ((stackLeft - startLeft) * liftProgress);

    return liftedLeft + ((finalLeft - liftedLeft) * settleProgress);
  }

  double _animatedCardTop({
    required int index,
    required int stackSlot,
    required double unlock,
    required double scale,
    required double walletTopOnCanvas,
    required double homeFirstCardTop,
    required double canvasWidth,
  }) {
    final startTop = switch (stackSlot) {
      0 => 8.38098 * scale,
      1 => 47.2382 * scale,
      _ => 83.0477 * scale,
    };
    final stackedTop = (-24 + (stackSlot * 13.0)) * scale;
    final finalTop = _homeCardTop(
          index,
          canvasWidth: canvasWidth,
          homeFirstCardTop: homeFirstCardTop,
        ) -
        walletTopOnCanvas;
    final liftProgress = _cardLiftProgress(unlock);
    final settleProgress = _cardSettleProgress(index, unlock);
    final liftedTop = startTop + ((stackedTop - startTop) * liftProgress);

    return liftedTop + ((finalTop - liftedTop) * settleProgress);
  }

  double _animatedCardWidth({
    required int index,
    required double unlock,
    required double startWidth,
  }) {
    final progress = _cardScaleProgress(index, unlock);
    const finalWidth = AdaptiveLayout.phoneCardWidth;

    return startWidth + ((finalWidth - startWidth) * progress);
  }

  double _homeCardLeft(
    int index, {
    required double canvasWidth,
  }) {
    final paneCount = AdaptiveLayout.cardPaneCountForWidth(canvasWidth);
    final horizontalPadding =
        AdaptiveLayout.horizontalPaddingForWidth(canvasWidth);
    const spacing = AdaptiveLayout.cardPaneSpacing;
    const cardWidth = AdaptiveLayout.phoneCardWidth;

    if (paneCount == 1) {
      return horizontalPadding;
    }

    final contentWidth = (cardWidth * paneCount) + (spacing * (paneCount - 1));
    final contentLeft = (canvasWidth - contentWidth) / 2;
    final column = index % paneCount;

    return contentLeft + (column * (cardWidth + spacing));
  }

  double _homeCardTop(
    int index, {
    required double canvasWidth,
    required double homeFirstCardTop,
  }) {
    final paneCount = AdaptiveLayout.cardPaneCountForWidth(canvasWidth);
    const fullWidth = AdaptiveLayout.phoneCardWidth;
    const cardHeight =
        fullWidth * (cardAspectRatioHeight / cardAspectRatioWidth);
    final row = index ~/ paneCount;

    return homeFirstCardTop + (row * (cardHeight + bankCardVerticalSpacing));
  }

  double _walletExitProgress(double unlock) {
    return _interval(unlock, 0.02, 0.36);
  }

  double _cardLiftProgress(double unlock) {
    return _interval(unlock, 0.04, 0.34);
  }

  double _cardSettleProgress(int index, double unlock) {
    final start = 0.34 + (index * 0.10);
    return _interval(unlock, start, start + 0.44);
  }

  double _cardScaleProgress(int index, double unlock) {
    final start = 0.42 + (index * 0.10);
    return _interval(unlock, start, start + 0.42);
  }

  double _interval(double value, double start, double end) {
    if (value <= start) return 0;
    if (value >= end) return 1;

    final t = (value - start) / (end - start);
    return Curves.easeInOutCubic.transform(t);
  }

  Widget _buildWalletBackPlate({
    required double width,
    required double height,
    required double scale,
  }) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _WalletBackPainter(),
      ),
    );
  }

  Widget _buildScaledHomeCard(
    CardData card, {
    required double width,
  }) {
    final cardTypeLabel = card.cardType == CardType.credit ? 'Credit' : 'Debit';
    const fullWidth = AdaptiveLayout.phoneCardWidth;
    const aspect = cardAspectRatioWidth / cardAspectRatioHeight;
    const fullHeight = fullWidth / aspect;
    final scale = width / fullWidth;

    return SizedBox(
      width: width,
      height: fullHeight * scale,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(cardBorderRadius * scale),
        child: FittedBox(
          fit: BoxFit.fill,
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: fullWidth,
            height: fullHeight,
            child: BankCardScope(
              revealed: false,
              cvvVisible: false,
              onToggleCvv: () {},
              child: BankCard(
                bankLogo: card.bankCid,
                networkLogo: card.cardNetwork.assetPath,
                cardType: cardTypeLabel,
                cardNumber: card.cardNumber,
                validThru: card.expiry,
                holderName: card.holderName,
                cvv: card.cvv,
                customBankName: card.customBankName,
                customBankLogoPath: card.customBankLogoPath,
                customGradientStartColor: card.customGradientStartColor != null
                    ? Color(card.customGradientStartColor!)
                    : null,
                customGradientMiddleColor:
                    card.customGradientMiddleColor != null
                        ? Color(card.customGradientMiddleColor!)
                        : null,
                customGradientEndColor: card.customGradientEndColor != null
                    ? Color(card.customGradientEndColor!)
                    : null,
                customCardPatternAssetPath: card.customCardVisualMode == 0
                    ? card.customCardPatternAssetPath
                    : null,
                customCardImagePath: card.customCardVisualMode == 1
                    ? card.customCardImagePath
                    : null,
                customCardImageAlignment: Alignment(
                  card.customCardImageAlignmentX ?? 0,
                  card.customCardImageAlignmentY ?? 0,
                ),
                showActions: false,
                onEyeTap: () {},
                onShareTap: () {},
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWalletPocket({
    required double width,
    required double height,
    required double scale,
  }) {
    final hasError = _isError || _errorMessage.isNotEmpty;
    final caption = _isError || _errorMessage.isNotEmpty
        ? _errorMessage
        : _isCreating
            ? _statusMessage
            : 'Forgot PIN?';
    final captionColor = hasError ? SwalletColors.destructive : Colors.white;

    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _WalletPocketPainter(),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 64.5 * scale,
            child: _buildWalletPinDots(scale),
          ),
          Positioned(
            left: 24 * scale,
            right: 24 * scale,
            top: 109 * scale,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: (!_isCreating && !_isError) ? _openResetPin : null,
              child: Text(
                caption,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  color: captionColor,
                  fontSize: 14 * scale,
                  height: 1,
                  fontWeight: hasError ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletPinDots(double scale) {
    final hasError = _isError || _errorMessage.isNotEmpty;
    final dotColor = hasError ? SwalletColors.destructive : Colors.white;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_pinLength, (index) {
        final filled = index < _enteredPin.length;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: EdgeInsets.symmetric(horizontal: 4.5 * scale),
          width: filled ? 20 * scale : 18 * scale,
          height: filled ? 20 * scale : 18 * scale,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: filled ? dotColor : Colors.transparent,
            border: Border.all(
              color: dotColor.withValues(alpha: filled ? 1 : 0.72),
              width: 2 * scale,
            ),
            boxShadow: hasError && filled
                ? [
                    BoxShadow(
                      color: SwalletColors.destructive.withValues(alpha: 0.28),
                      blurRadius: 12 * scale,
                      spreadRadius: 1.5 * scale,
                    ),
                  ]
                : null,
          ),
        );
      }),
    );
  }

  Future<void> _openResetPin() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SecurityVerificationScreen(
          isDark: _isDark,
          onVerificationSuccess: () async {
            Navigator.pop(context);
            await SecurityStore.deletePin();
            await _checkPinStatus();
          },
        ),
      ),
    );
  }

  Widget _buildClassicPinContent({
    required AddCardMaterialTokens tokens,
    required bool isStep2,
  }) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isTightHeight = constraints.maxHeight < 700;
          final headerTopPadding = isTightHeight ? 8.0 : 12.0;

          return SingleChildScrollView(
            physics: isTightHeight
                ? const BouncingScrollPhysics()
                : const NeverScrollableScrollPhysics(),
            child: SizedBox(
              height: constraints.maxHeight,
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      16,
                      headerTopPadding,
                      16,
                      0,
                    ),
                    child: _buildClassicHeader(tokens, isStep2),
                  ),
                  const Spacer(),
                  _buildSecureStoragePinStatus(tokens),
                  SizedBox(height: isTightHeight ? 12 : 16),
                  _buildClassicPinDots(tokens),
                  SizedBox(height: isTightHeight ? 16 : 28),
                  _buildClassicErrorAndReset(tokens),
                  const Spacer(),
                  _buildClassicNumPad(tokens, compact: isTightHeight),
                  SizedBox(height: isTightHeight ? 12 : 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildClassicHeader(AddCardMaterialTokens tokens, bool isStep2) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (_isCreating && isStep2)
          CustomBackButton(
            isDark: _isDark,
            onTap: _onBackFromConfirmation,
          )
        else
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: tokens.surfaceContainer,
              borderRadius: BorderRadius.circular(22),
            ),
            child: SvgPicture.asset(
              'assets/images/logo_44.svg',
              width: 30,
              height: 30,
              errorBuilder: (_, __, ___) => const Icon(CupertinoIcons.lock),
            ),
          ),
        if (_isCreating)
          Row(
            children: [
              _buildStepIndicator('1', true, tokens),
              Container(
                width: 24,
                height: 1,
                color: tokens.outlineVariant.withValues(alpha: 0.72),
              ),
              _buildStepIndicator('2', isStep2, tokens),
            ],
          )
        else
          const SizedBox(width: 48),
        const SizedBox(width: 48),
      ],
    );
  }

  Widget _buildSecureStoragePinStatus(AddCardMaterialTokens tokens) {
    final text = _isError || _errorMessage.isNotEmpty
        ? _errorMessage
        : _isCreating
            ? _statusMessage
            : 'Enter your App PIN';
    final color = _isError || _errorMessage.isNotEmpty
        ? SwalletColors.destructive
        : tokens.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: SwalletText.bodyMedium.copyWith(
          color: color,
          height: 1.25,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildClassicPinDots(AddCardMaterialTokens tokens) {
    final hasError = _isError || _errorMessage.isNotEmpty;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_pinLength, (index) {
        final filled = index < _enteredPin.length;
        final activeColor =
            hasError ? SwalletColors.destructive : tokens.primary;
        final borderColor = hasError
            ? SwalletColors.destructive.withValues(alpha: filled ? 1 : 0.34)
            : (filled
                ? tokens.primary
                : tokens.primary.withValues(alpha: _isDark ? 0.32 : 0.24));
        final fillColor = filled
            ? activeColor.withValues(alpha: _isDark ? 0.20 : 0.16)
            : tokens.primary.withValues(alpha: _isDark ? 0.12 : 0.10);

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: fillColor,
            border: Border.all(
              color: borderColor,
              width: filled ? 1.6 : 1.2,
            ),
            boxShadow: filled
                ? [
                    BoxShadow(
                      color: activeColor.withValues(alpha: 0.18),
                      blurRadius: 10,
                      spreadRadius: 1.6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: filled ? 10 : 8,
              height: filled ? 10 : 8,
              decoration: BoxDecoration(
                color: filled ? activeColor : Colors.transparent,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildClassicErrorAndReset(AddCardMaterialTokens tokens) {
    return Column(
      children: [
        SizedBox(
          height: 20,
          child: (_isError || _errorMessage.isNotEmpty)
              ? Text(
                  _errorMessage,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.roboto(
                    color: SwalletColors.destructive,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                )
              : null,
        ),
        if (_showResetButton && !_isCreating) ...[
          const SizedBox(height: 10),
          TextButton(
            onPressed: _openResetPin,
            style: TextButton.styleFrom(
              foregroundColor: tokens.primary,
              shape: RoundedRectangleBorder(borderRadius: tokens.pillRadius),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              textStyle: GoogleFonts.roboto(
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            child: const Text('Reset PIN'),
          ),
        ],
      ],
    );
  }

  Widget _buildClassicNumPad(
    AddCardMaterialTokens tokens, {
    bool compact = false,
  }) {
    final buttonSize = compact ? 74.0 : 80.0;
    final columnGap = compact ? 20.0 : 28.0;
    final rowGap = compact ? 16.0 : 20.0;
    final keypadWidth = (buttonSize * 3) + (columnGap * 2);

    return Center(
      child: SizedBox(
        width: keypadWidth,
        child: Column(
          children: [
            _buildClassicRow(['1', '2', '3'], tokens, buttonSize),
            SizedBox(height: rowGap),
            _buildClassicRow(['4', '5', '6'], tokens, buttonSize),
            SizedBox(height: rowGap),
            _buildClassicRow(['7', '8', '9'], tokens, buttonSize),
            SizedBox(height: rowGap),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildClassicBiometricPadButton(tokens, buttonSize),
                _buildClassicNumButton('0', tokens, buttonSize),
                _buildClassicBackspaceButton(tokens, buttonSize),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClassicBiometricPadButton(
    AddCardMaterialTokens tokens,
    double buttonSize,
  ) {
    final useBio = !_isCreating &&
        _settingsBox.get(
          'use_biometrics',
          defaultValue: false,
        );

    if (!useBio) {
      return SizedBox(width: buttonSize, height: buttonSize);
    }

    return SizedBox(
      width: buttonSize,
      height: buttonSize,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _triggerBiometrics,
          borderRadius: BorderRadius.circular(12),
          child: Icon(
            Icons.fingerprint,
            color: tokens.onSurface,
            size: 24,
          ),
        ),
      ),
    );
  }

  Widget _buildClassicRow(
    List<String> numbers,
    AddCardMaterialTokens tokens,
    double buttonSize,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: numbers
          .map((n) => _buildClassicNumButton(n, tokens, buttonSize))
          .toList(),
    );
  }

  Widget _buildClassicNumButton(
    String number,
    AddCardMaterialTokens tokens,
    double buttonSize,
  ) {
    return _buildSecureKeySurface(
      tokens,
      buttonSize: buttonSize,
      onTap: () => _onNumTapped(number),
      child: Text(
        number,
        style: GoogleFonts.poppins(
          fontSize: buttonSize < 70 ? 24 : 27,
          fontWeight: FontWeight.w500,
          color: tokens.onSurface,
          height: 1,
        ),
      ),
    );
  }

  Widget _buildSecureKeySurface(
    AddCardMaterialTokens tokens, {
    required double buttonSize,
    required Widget child,
    required VoidCallback onTap,
    bool lowEmphasis = false,
  }) {
    final bgColor =
        lowEmphasis ? Colors.transparent : tokens.surfaceContainerHigh;

    return SizedBox(
      width: buttonSize,
      height: buttonSize,
      child: Material(
        color: bgColor,
        shape: lowEmphasis ? null : const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTapDown: (_) => HapticFeedback.selectionClick(),
          onTap: onTap,
          customBorder: lowEmphasis ? null : const CircleBorder(),
          borderRadius: lowEmphasis ? BorderRadius.circular(12) : null,
          child: Center(child: child),
        ),
      ),
    );
  }

  Widget _buildClassicBackspaceButton(
    AddCardMaterialTokens tokens,
    double buttonSize,
  ) {
    return _buildSecureKeySurface(
      tokens,
      buttonSize: buttonSize,
      onTap: _onBackspace,
      lowEmphasis: true,
      child: Icon(
        CupertinoIcons.delete_left,
        color: tokens.onSurfaceVariant,
        size: buttonSize < 70 ? 24 : 27,
      ),
    );
  }

  Widget _buildStepIndicator(
    String step,
    bool isActive,
    AddCardMaterialTokens tokens,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? tokens.primaryContainer : tokens.surfaceContainer,
        border: Border.all(
          color: isActive ? tokens.primary : tokens.outlineVariant,
          width: 1.4,
        ),
      ),
      child: Text(
        step,
        style: GoogleFonts.roboto(
          color: isActive ? tokens.onPrimaryContainer : tokens.onSurfaceVariant,
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildNumPad(AddCardMaterialTokens tokens, {required double scale}) {
    final buttonSize = 80 * scale;
    final columnGap = 28 * scale;
    final rowGap = 20 * scale;
    final keypadWidth = (buttonSize * 3) + (columnGap * 2);

    return SizedBox(
      width: keypadWidth,
      child: Column(
        children: [
          _buildRow(['1', '2', '3'], tokens, buttonSize, scale),
          SizedBox(height: rowGap),
          _buildRow(['4', '5', '6'], tokens, buttonSize, scale),
          SizedBox(height: rowGap),
          _buildRow(['7', '8', '9'], tokens, buttonSize, scale),
          SizedBox(height: rowGap),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildBiometricPadButton(tokens, buttonSize, scale),
              SizedBox(width: columnGap),
              _buildNumButton('0', tokens, buttonSize, scale),
              SizedBox(width: columnGap),
              _buildDeletePadButton(tokens, buttonSize, scale),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBiometricPadButton(
    AddCardMaterialTokens tokens,
    double buttonSize,
    double scale,
  ) {
    final useBio = !_isCreating &&
        _settingsBox.get(
          'use_biometrics',
          defaultValue: false,
        );

    if (!useBio) {
      return SizedBox(width: buttonSize, height: buttonSize);
    }

    return _buildSecureKeySurface(
      tokens,
      buttonSize: buttonSize,
      onTap: _triggerBiometrics,
      lowEmphasis: true,
      child: Icon(
        Icons.fingerprint,
        color: _isDark ? _keyTextDark : _keyTextLight,
        size: 27 * scale,
      ),
    );
  }

  Widget _buildDeletePadButton(
    AddCardMaterialTokens tokens,
    double buttonSize,
    double scale,
  ) {
    return _buildSecureKeySurface(
      tokens,
      buttonSize: buttonSize,
      onTap: _onBackspace,
      lowEmphasis: true,
      child: Text(
        'Delete',
        style: SwalletText.button.copyWith(
          color: _isDark ? _keyTextDark : _keyTextLight,
          fontSize: 14 * scale,
          fontWeight: FontWeight.w600,
          height: 1,
        ),
      ),
    );
  }

  Widget _buildRow(
    List<String> numbers,
    AddCardMaterialTokens tokens,
    double buttonSize,
    double scale,
  ) {
    final columnGap = 28 * scale;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: numbers
          .map(
            (n) => Padding(
              padding: EdgeInsets.only(
                right: n == numbers.last ? 0 : columnGap,
              ),
              child: _buildNumButton(n, tokens, buttonSize, scale),
            ),
          )
          .toList(growable: false),
    );
  }

  Widget _buildNumButton(
    String number,
    AddCardMaterialTokens tokens,
    double buttonSize,
    double scale,
  ) {
    return _buildSecureKeySurface(
      tokens,
      buttonSize: buttonSize,
      onTap: () => _onNumTapped(number),
      child: Text(
        number,
        style: GoogleFonts.poppins(
          fontSize: 24 * scale,
          height: 1,
          fontWeight: FontWeight.w500,
          color: _isDark ? _keyTextDark : _keyTextLight,
        ),
      ),
    );
  }
}

class _WalletBackPainter extends CustomPainter {
  static const _sourceSize = Size(320, 213.333);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(
      size.width / _sourceSize.width,
      size.height / _sourceSize.height,
    );

    final outerPath = Path()
      ..moveTo(298.667, 0)
      ..cubicTo(310.449, 0, 320, 9.55125, 320, 21.3333)
      ..lineTo(320, 192)
      ..lineTo(319.993, 192.551)
      ..cubicTo(319.706, 203.895, 310.562, 213.039, 299.217, 213.327)
      ..lineTo(298.667, 213.333)
      ..lineTo(21.3333, 213.333)
      ..cubicTo(9.73541, 213.333, 0.298641, 204.078, 0.00651042, 192.551)
      ..lineTo(0, 192)
      ..lineTo(0, 21.3333)
      ..cubicTo(0.0000073302, 9.55126, 9.55127, 0.00000160354, 21.3333, 0)
      ..lineTo(298.667, 0)
      ..close();

    final outerPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = ui.Gradient.linear(
        const Offset(292.952, 0),
        const Offset(63.2381, 169.905),
        const [
          Color(0xFF51C7FF),
          Color(0xFF90F4FC),
          Color(0xFF219BD5),
        ],
        const [0.017217, 0.966318, 1],
      );

    canvas.drawPath(outerPath, outerPaint);

    final innerPath = Path()
      ..moveTo(298.667, 13.3333)
      ..cubicTo(303.085, 13.3333, 306.667, 16.915, 306.667, 21.3333)
      ..lineTo(306.667, 192)
      ..lineTo(306.664, 192.214)
      ..cubicTo(306.556, 196.455, 303.132, 199.882, 298.892, 199.996)
      ..lineTo(298.62, 200)
      ..lineTo(21.3335, 200)
      ..cubicTo(17.1216, 200, 13.6666, 196.742, 13.3556, 192.615)
      ..lineTo(13.3361, 192.214)
      ..lineTo(13.3335, 192)
      ..lineTo(13.3335, 21.3333)
      ..cubicTo(13.3335, 16.915, 16.9152, 13.3333, 21.3335, 13.3333)
      ..lineTo(298.667, 13.3333)
      ..close();

    canvas.drawPath(
      innerPath,
      Paint()
        ..style = PaintingStyle.fill
        ..color = const Color(0xFF000100),
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _WalletPocketPainter extends CustomPainter {
  static const _sourceSize = Size(320, 149.3332);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(
      size.width / _sourceSize.width,
      size.height / _sourceSize.height,
    );

    final path = Path()
      ..moveTo(104.8934, 0)
      ..cubicTo(109.4704, 0, 113.8884, 1.6815, 117.3074, 4.7253)
      ..lineTo(126.1594, 12.6081)
      ..cubicTo(129.5774, 15.6519, 133.9954, 17.3334, 138.5734, 17.3334)
      ..lineTo(182.7604, 17.3334)
      ..cubicTo(187.3374, 17.3334, 191.7564, 15.6519, 195.1744, 12.6081)
      ..lineTo(204.0264, 4.7253)
      ..cubicTo(207.4444, 1.6815, 211.8634, 0, 216.4404, 0)
      ..lineTo(320, 0)
      ..lineTo(320, 128.0002)
      ..cubicTo(320, 139.7822, 310.4484, 149.3332, 298.6664, 149.3332)
      ..lineTo(21.3334, 149.3332)
      ..cubicTo(9.5513, 149.3332, 0, 139.7822, 0, 128.0002)
      ..lineTo(0, 0)
      ..lineTo(104.8934, 0)
      ..close();

    canvas.drawShadow(
      path.shift(const Offset(0, -6.85714)),
      Colors.black.withValues(alpha: 0.25),
      9.14286,
      false,
    );

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..shader = ui.Gradient.radial(
        const Offset(160, -34.66664),
        184,
        const [
          Color(0xFF41FEFE),
          Color(0xFF90F4FC),
          Color(0xFF219BD5),
        ],
        const [0, 0.351981, 1],
        TileMode.clamp,
        Matrix4.diagonal3Values(278.377 / 184, 1, 1).storage,
      );

    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
