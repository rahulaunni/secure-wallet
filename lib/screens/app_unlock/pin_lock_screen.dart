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
  static const double _homeStackCollapsedScaleStep = 0.045;
  static const int _homeStackMaxCollapsedDepth = 4;
  static const int _homeStackVisibleCollapsedCards = 4;
  static const String _walletLeatherTextureAsset =
      'assets/images/textures/blue_leather_texture.jpeg';
  static const List<double> _homeStackCollapsedTopOffsets = <double>[
    64,
    30,
    12,
    0,
  ];
  static const Curve _iosSettleCurve = Cubic(0.22, 1, 0.36, 1);

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
  ui.Image? _walletLeatherImage;

  @override
  void initState() {
    super.initState();
    _isDark = _settingsBox.get('is_dark', defaultValue: true);
    _initShakeAnimation();
    _unlockController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1480),
    );
    _loadWalletLeatherTexture();
    _checkPinStatus();
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _unlockController.dispose();
    _walletLeatherImage?.dispose();
    super.dispose();
  }

  Future<void> _loadWalletLeatherTexture() async {
    late final ui.FrameInfo frame;
    try {
      final data = await rootBundle.load(_walletLeatherTextureAsset);
      final bytes = data.buffer.asUint8List(
        data.offsetInBytes,
        data.lengthInBytes,
      );
      final codec = await ui.instantiateImageCodec(bytes);
      frame = await codec.getNextFrame();
    } catch (_) {
      return;
    }

    if (!mounted) {
      frame.image.dispose();
      return;
    }

    setState(() {
      _walletLeatherImage?.dispose();
      _walletLeatherImage = frame.image;
    });
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
                        1 - _interval(_unlockController.value, 0.05, 0.34);
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
              final unlock = _unlockController.value;
              final chromeExit = _walletExitProgress(unlock);
              final chromeOpacity = 1 - chromeExit;
              final chromeOffset = Offset(0, 178 * scale * chromeExit);

              return Stack(
                children: [
                  Positioned(
                    left: 16 * scale,
                    right: 16 * scale,
                    top: titleTop,
                    child: Transform.translate(
                      offset: Offset(0, -20 * scale * chromeExit),
                      child: Opacity(
                        opacity: chromeOpacity,
                        child: _buildTitleHeader(tokens, isStep2, scale),
                      ),
                    ),
                  ),
                  Positioned(
                    left: walletLeft,
                    top: walletTop,
                    child: _buildWalletHero(
                      cards: _lockCards(savedCards),
                      stackCards: _stackFormationCards(savedCards),
                      totalCardCount: savedCards.length,
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
                    child: Transform.translate(
                      offset: chromeOffset,
                      child: Opacity(
                        opacity: chromeOpacity,
                        child: _buildNumPad(tokens, scale: scale),
                      ),
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

  List<CardData> _stackFormationCards(List<CardData> savedCards) {
    if (savedCards.length <= 3) {
      return const <CardData>[];
    }

    return savedCards
        .skip(3)
        .take(_homeStackVisibleCollapsedCards - 1)
        .toList(growable: false);
  }

  Widget _buildWalletHero({
    required List<CardData> cards,
    required List<CardData> stackCards,
    required int totalCardCount,
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
        final walletOpacity = 1 - _interval(unlock, 0.08, 0.34);
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
                for (var stackIndex = stackCards.length - 1;
                    stackIndex >= 0;
                    stackIndex--)
                  Positioned(
                    left: _homeCardLeft(
                          stackIndex + 3,
                          totalCardCount: totalCardCount,
                          canvasWidth: canvasWidth,
                        ) -
                        walletLeftOnCanvas,
                    top: _animatedStackCardTop(
                      stackIndex: stackIndex,
                      unlock: unlock,
                      walletTopOnCanvas: walletTopOnCanvas,
                      homeFirstCardTop: homeFirstCardTop,
                      totalCardCount: totalCardCount,
                      canvasWidth: canvasWidth,
                    ),
                    child: Opacity(
                      opacity: _stackFormationProgress(
                        index: stackIndex + 3,
                        unlock: unlock,
                      ),
                      child: _buildScaledHomeCard(
                        stackCards[stackIndex],
                        width: _homeCardWidth(canvasWidth: canvasWidth) *
                            _homeCardFinalScale(
                              stackIndex + 3,
                              totalCardCount: totalCardCount,
                              canvasWidth: canvasWidth,
                            ),
                        baseWidth: _homeCardWidth(canvasWidth: canvasWidth),
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
                            normalFinalLeft: _homeCardNormalLeft(
                                  i,
                                  canvasWidth: canvasWidth,
                                ) -
                                walletLeftOnCanvas,
                            finalLeft: _homeCardLeft(
                                  i,
                                  totalCardCount: totalCardCount,
                                  canvasWidth: canvasWidth,
                                ) -
                                walletLeftOnCanvas,
                            totalCardCount: totalCardCount,
                            canvasWidth: canvasWidth,
                          )
                        : cardStartLeft,
                    top: hasSavedCards
                        ? _animatedCardTop(
                            index: i,
                            stackSlot: _walletStackSlotForIndex(
                              i,
                              cards.length,
                            ),
                            unlock: unlock,
                            scale: scale,
                            walletTopOnCanvas: walletTopOnCanvas,
                            homeFirstCardTop: homeFirstCardTop,
                            totalCardCount: totalCardCount,
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
                                  totalCardCount: totalCardCount,
                                  canvasWidth: canvasWidth,
                                )
                              : cardStartWidth,
                          baseWidth: hasSavedCards
                              ? _homeCardWidth(canvasWidth: canvasWidth)
                              : AdaptiveLayout.phoneCardWidth,
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
    required double normalFinalLeft,
    required double finalLeft,
    required int totalCardCount,
    required double canvasWidth,
  }) {
    final usesStackedHomeLayout = _usesStackedHomeLayout(
      totalCardCount: totalCardCount,
      canvasWidth: canvasWidth,
    );
    final stackLeft = startLeft;
    final liftProgress = _cardLiftProgress(unlock);
    final settleProgress = _cardSettleProgress(index, unlock);
    final liftedLeft = startLeft + ((stackLeft - startLeft) * liftProgress);

    final normalLeft =
        liftedLeft + ((normalFinalLeft - liftedLeft) * settleProgress);

    if (!usesStackedHomeLayout || index < 2) {
      return normalLeft;
    }

    return _lerp(
      normalLeft,
      finalLeft,
      _stackFormationProgress(
        index: index,
        unlock: unlock,
      ),
    );
  }

  int _walletStackSlotForIndex(int index, int previewCardCount) {
    if (previewCardCount <= 3) {
      return index + (3 - previewCardCount);
    }

    return index;
  }

  double _animatedCardTop({
    required int index,
    required int stackSlot,
    required double unlock,
    required double scale,
    required double walletTopOnCanvas,
    required double homeFirstCardTop,
    required int totalCardCount,
    required double canvasWidth,
  }) {
    final usesStackedHomeLayout = _usesStackedHomeLayout(
      totalCardCount: totalCardCount,
      canvasWidth: canvasWidth,
    );
    final startTop = _walletCardStartTop(stackSlot, scale);
    final stackedTop = (-24 + (stackSlot * 13.0)) * scale;
    final normalFinalTop = _homeCardNormalTop(
          index,
          canvasWidth: canvasWidth,
          homeFirstCardTop: homeFirstCardTop,
        ) -
        walletTopOnCanvas;
    final stackedFinalTop = _homeCardTop(
          index,
          canvasWidth: canvasWidth,
          homeFirstCardTop: homeFirstCardTop,
          totalCardCount: totalCardCount,
        ) -
        walletTopOnCanvas;
    final liftProgress = _cardLiftProgress(unlock);
    final settleProgress = _cardSettleProgress(index, unlock);
    final liftedTop = startTop + ((stackedTop - startTop) * liftProgress);

    final normalTop =
        liftedTop + ((normalFinalTop - liftedTop) * settleProgress);

    if (!usesStackedHomeLayout || index < 2) {
      return normalTop;
    }

    final stackProgress = _stackFormationProgress(
      index: index,
      unlock: unlock,
    );

    return _lerp(normalTop, stackedFinalTop, stackProgress);
  }

  double _animatedStackCardTop({
    required int stackIndex,
    required double unlock,
    required double walletTopOnCanvas,
    required double homeFirstCardTop,
    required int totalCardCount,
    required double canvasWidth,
  }) {
    final cardIndex = stackIndex + 3;
    final progress = _stackFormationProgress(
      index: cardIndex,
      unlock: unlock,
    );
    final frontStackTop = _homeCardTop(
          2,
          canvasWidth: canvasWidth,
          homeFirstCardTop: homeFirstCardTop,
          totalCardCount: totalCardCount,
        ) -
        walletTopOnCanvas;
    final finalTop = _homeCardTop(
          cardIndex,
          canvasWidth: canvasWidth,
          homeFirstCardTop: homeFirstCardTop,
          totalCardCount: totalCardCount,
        ) -
        walletTopOnCanvas;
    final behindThirdStartTop = frontStackTop + (10 * stackIndex);

    return _lerp(behindThirdStartTop, finalTop, progress);
  }

  double _animatedCardWidth({
    required int index,
    required double unlock,
    required double startWidth,
    required int totalCardCount,
    required double canvasWidth,
  }) {
    final homeCardWidth = _homeCardWidth(canvasWidth: canvasWidth);
    final usesStackedHomeLayout = _usesStackedHomeLayout(
      totalCardCount: totalCardCount,
      canvasWidth: canvasWidth,
    );
    final scaleProgress = _cardScaleProgress(index, unlock);
    final finalWidth = homeCardWidth *
        _homeCardFinalScale(
          index,
          totalCardCount: totalCardCount,
          canvasWidth: canvasWidth,
        );

    if (!usesStackedHomeLayout || index < 2) {
      return startWidth + ((homeCardWidth - startWidth) * scaleProgress);
    }

    final normalWidth =
        startWidth + ((homeCardWidth - startWidth) * scaleProgress);
    return _lerp(
      normalWidth,
      finalWidth,
      _stackFormationProgress(
        index: index,
        unlock: unlock,
      ),
    );
  }

  double _walletCardStartTop(int stackSlot, double scale) {
    if (stackSlot <= 0) return 8.38098 * scale;
    if (stackSlot == 1) return 47.2382 * scale;
    return (83.0477 + ((stackSlot - 2) * 6)) * scale;
  }

  double _homeCardNormalLeft(
    int index, {
    required double canvasWidth,
  }) {
    final paneCount = AdaptiveLayout.cardPaneCountForWidth(canvasWidth);
    final horizontalPadding =
        AdaptiveLayout.horizontalPaddingForWidth(canvasWidth);
    const spacing = AdaptiveLayout.cardPaneSpacing;
    final cardWidth = _homeCardWidth(canvasWidth: canvasWidth);

    if (paneCount == 1) {
      return horizontalPadding;
    }

    final contentWidth = (cardWidth * paneCount) + (spacing * (paneCount - 1));
    final contentLeft = (canvasWidth - contentWidth) / 2;
    final column = index % paneCount;

    return contentLeft + (column * (cardWidth + spacing));
  }

  double _homeCardLeft(
    int index, {
    required int totalCardCount,
    required double canvasWidth,
  }) {
    final paneCount = AdaptiveLayout.cardPaneCountForWidth(canvasWidth);
    final horizontalPadding =
        AdaptiveLayout.horizontalPaddingForWidth(canvasWidth);
    const spacing = AdaptiveLayout.cardPaneSpacing;
    final cardWidth = _homeCardWidth(canvasWidth: canvasWidth);

    if (paneCount == 1) {
      final finalScale = _homeCardFinalScale(
        index,
        totalCardCount: totalCardCount,
        canvasWidth: canvasWidth,
      );
      return horizontalPadding + ((cardWidth - (cardWidth * finalScale)) / 2);
    }

    final contentWidth = (cardWidth * paneCount) + (spacing * (paneCount - 1));
    final contentLeft = (canvasWidth - contentWidth) / 2;
    final column = index % paneCount;

    return contentLeft + (column * (cardWidth + spacing));
  }

  double _homeCardWidth({
    required double canvasWidth,
  }) {
    final paneCount = AdaptiveLayout.cardPaneCountForWidth(canvasWidth);
    if (paneCount == 1) {
      final horizontalPadding =
          AdaptiveLayout.horizontalPaddingForWidth(canvasWidth);
      return canvasWidth - (horizontalPadding * 2);
    }

    return AdaptiveLayout.phoneCardWidth;
  }

  double _homeCardNormalTop(
    int index, {
    required double canvasWidth,
    required double homeFirstCardTop,
  }) {
    final paneCount = AdaptiveLayout.cardPaneCountForWidth(canvasWidth);
    final fullWidth = _homeCardWidth(canvasWidth: canvasWidth);
    final cardHeight =
        fullWidth * (cardAspectRatioHeight / cardAspectRatioWidth);
    const cardTiltPadding = 8.0;
    final slotHeight = cardHeight + cardTiltPadding + bankCardVerticalSpacing;
    final row = index ~/ paneCount;

    return homeFirstCardTop + (row * slotHeight) + cardTiltPadding;
  }

  double _homeCardTop(
    int index, {
    required double canvasWidth,
    required double homeFirstCardTop,
    required int totalCardCount,
  }) {
    final paneCount = AdaptiveLayout.cardPaneCountForWidth(canvasWidth);
    final fullWidth = _homeCardWidth(canvasWidth: canvasWidth);
    final cardHeight =
        fullWidth * (cardAspectRatioHeight / cardAspectRatioWidth);
    const cardTiltPadding = 8.0;
    final slotHeight = cardHeight + cardTiltPadding + bankCardVerticalSpacing;

    if (_usesStackedHomeLayout(
          totalCardCount: totalCardCount,
          canvasWidth: canvasWidth,
        ) &&
        index >= 2) {
      return homeFirstCardTop +
          (2 * slotHeight) +
          _homeStackCollapsedTop(
            index,
            totalCardCount: totalCardCount,
          ) +
          cardTiltPadding;
    }

    final row = index ~/ paneCount;

    return homeFirstCardTop + (row * slotHeight) + cardTiltPadding;
  }

  bool _usesStackedHomeLayout({
    required int totalCardCount,
    required double canvasWidth,
  }) {
    return totalCardCount > 3 &&
        AdaptiveLayout.cardPaneCountForWidth(canvasWidth) == 1;
  }

  double _homeCardFinalScale(
    int index, {
    required int totalCardCount,
    required double canvasWidth,
  }) {
    if (!_usesStackedHomeLayout(
          totalCardCount: totalCardCount,
          canvasWidth: canvasWidth,
        ) ||
        index < 2) {
      return 1;
    }

    final collapsedDepth = _homeStackCollapsedDepth(
      index,
      totalCardCount: totalCardCount,
    );
    return 1 - (_homeStackCollapsedScaleStep * collapsedDepth);
  }

  double _homeStackCollapsedTop(
    int index, {
    required int totalCardCount,
  }) {
    final stackIndex = index - 2;
    if (stackIndex < _homeStackCollapsedTopOffsets.length) {
      return _homeStackCollapsedTopOffsets[stackIndex];
    }

    return _homeStackCollapsedTopOffsets.last;
  }

  int _homeStackCollapsedDepth(
    int index, {
    required int totalCardCount,
  }) {
    final stackIndex = index - 2;
    final stackCount = totalCardCount - 2;
    final maxDepth = (stackCount - 1).clamp(1, _homeStackMaxCollapsedDepth);

    return stackIndex.clamp(0, maxDepth);
  }

  double _stackFormationProgress({
    required int index,
    required double unlock,
  }) {
    final stagger = index <= 2 ? 0.0 : ((index - 3).clamp(0, 4) * 0.04);
    final start = index <= 2 ? 0.8 : 0.81 + stagger;
    final end = math.min(0.99, start + 0.23);

    return _interval(unlock, start, end);
  }

  double _lerp(double from, double to, double progress) {
    return from + ((to - from) * progress);
  }

  double _walletExitProgress(double unlock) {
    return _interval(unlock, 0.02, 0.38);
  }

  double _cardLiftProgress(double unlock) {
    return _interval(unlock, 0.03, 0.36);
  }

  double _cardSettleProgress(int index, double unlock) {
    final start = 0.25 + (index * 0.075);
    return _interval(unlock, start, start + 0.42);
  }

  double _cardScaleProgress(int index, double unlock) {
    final start = 0.31 + (index * 0.07);
    return _interval(unlock, start, start + 0.4);
  }

  double _interval(double value, double start, double end) {
    if (value <= start) return 0;
    if (value >= end) return 1;

    final t = (value - start) / (end - start);
    return _iosSettleCurve.transform(t);
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
        painter: _WalletBackPainter(leather: _walletLeatherImage),
      ),
    );
  }

  Widget _buildScaledHomeCard(
    CardData card, {
    required double width,
    required double baseWidth,
  }) {
    final cardTypeLabel = card.cardType == CardType.credit ? 'Credit' : 'Debit';
    const aspect = cardAspectRatioWidth / cardAspectRatioHeight;
    final fullHeight = baseWidth / aspect;
    final scale = width / baseWidth;

    return SizedBox(
      width: width,
      height: fullHeight * scale,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(cardBorderRadius * scale),
        child: FittedBox(
          fit: BoxFit.fill,
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: baseWidth,
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
              painter: _WalletPocketPainter(leather: _walletLeatherImage),
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

  final ui.Image? leather;

  const _WalletBackPainter({required this.leather});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(
      size.width / _sourceSize.width,
      size.height / _sourceSize.height,
    );

    const outerRect = Rect.fromLTWH(0, 0, 320, 213.333);
    final outerPath = _WalletLeather.handmadeRoundedRectPath(
      outerRect,
      radius: 42,
      phase: 0.15,
    );
    _WalletLeather.paintSoftPathCastShadow(canvas, outerPath);
    canvas.drawShadow(
      outerPath,
      Colors.black.withValues(alpha: 0.30),
      11,
      false,
    );
    _WalletLeather.paintTextureSurface(
      canvas,
      rect: outerRect,
      clip: outerPath,
      leather: leather,
      shadow: const Color(0xFF01020B),
      mid: const Color(0xFF11132D),
      glow: const Color(0xFF272D5D),
      textureScale: 1.1,
    );
    _WalletLeather.paintBackPanelSideWalls(canvas, outerPath, outerRect);
    _WalletLeather.paintCardPressureBulge(canvas, outerPath, outerRect);
    _WalletLeather.paintFoldedLeatherEdge(
      canvas,
      outerPath: outerPath,
      innerPath: _WalletLeather.handmadeRoundedRectPath(
        outerRect.deflate(10),
        radius: 32,
        phase: 1.1,
      ),
      bounds: outerRect,
    );

    const innerRect = Rect.fromLTWH(14, 14, 292, 186);
    final innerRRect = RRect.fromRectAndRadius(
      innerRect,
      const Radius.circular(30),
    );
    _WalletLeather.paintTextureSurface(
      canvas,
      rect: innerRect,
      clip: innerRRect.outerPath,
      leather: leather,
      shadow: const Color(0xFF01020D),
      mid: const Color(0xFF080B21),
      glow: const Color(0xFF191E49),
      textureScale: 1.24,
    );
    _WalletLeather.paintInsetHighlight(canvas, innerRRect);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _WalletBackPainter oldDelegate) {
    return oldDelegate.leather != leather;
  }
}

class _WalletPocketPainter extends CustomPainter {
  static const _sourceSize = Size(320, 149.3332);

  final ui.Image? leather;

  const _WalletPocketPainter({required this.leather});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(
      size.width / _sourceSize.width,
      size.height / _sourceSize.height,
    );

    const frontRect = Rect.fromLTWH(0, 0, 320, 149.3332);
    final path = _WalletLeather.pocketOuterPath();

    _WalletLeather.paintPocketCastShadow(canvas, path);
    _WalletLeather.paintTextureSurface(
      canvas,
      rect: frontRect,
      clip: path,
      leather: leather,
      shadow: const Color(0xFF01020B),
      mid: const Color(0xFF11142F),
      glow: const Color(0xFF2E3470),
      textureScale: 1.06,
    );
    _WalletLeather.paintFrontPanelLift(canvas, path);
    _WalletLeather.paintCornerCompression(canvas, path);
    _WalletLeather.paintFoldedLeatherEdge(
      canvas,
      outerPath: path,
      innerPath: _WalletLeather.pocketInnerEdgePath(),
      bounds: frontRect,
    );
    _WalletLeather.paintPocketOpeningLip(
        canvas, _WalletLeather.pocketOpeningPath());
    final pocketStitchPath = _WalletLeather.pocketStitchPath();
    _WalletLeather.paintStitchChannel(canvas, pocketStitchPath);
    _WalletLeather.paintSaddleStitches(
      canvas,
      pocketStitchPath,
      threadColor: const Color(0xFF39433F),
      bounds: frontRect,
      startOffset: 0.4,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _WalletPocketPainter oldDelegate) {
    return oldDelegate.leather != leather;
  }
}

extension on RRect {
  Path get outerPath => Path()..addRRect(this);
}

class _WalletLeather {
  static Path pocketOuterPath() {
    return Path()
      ..moveTo(0, 8.2)
      ..lineTo(111.8, 8.6)
      ..cubicTo(125.6, 8.7, 134.3, 21.6, 153.8, 23.2)
      ..cubicTo(174.4, 24.9, 188.9, 20.0, 198.4, 11.2)
      ..cubicTo(205.5, 5.05, 217.4, 7.2, 231.6, 7.1)
      ..lineTo(320, 5.2)
      ..lineTo(320, 115.0)
      ..cubicTo(320.35, 134.0, 305.0, 149.22, 286.15, 149.3332)
      ..lineTo(33.8, 149.3332)
      ..cubicTo(15.18, 149.05, -0.2, 134.3, 0, 115.1)
      ..lineTo(0, 8.2)
      ..close();
  }

  static Path pocketInnerEdgePath() {
    return Path()
      ..moveTo(10.6, 16.4)
      ..lineTo(111.8, 16.7)
      ..cubicTo(124.1, 16.8, 134.3, 28.0, 154.2, 29.4)
      ..cubicTo(174.3, 30.8, 189.55, 26.1, 200.8, 17.9)
      ..cubicTo(209.0, 12.1, 218.7, 14.1, 231.2, 14.0)
      ..lineTo(310.0, 12.8)
      ..lineTo(310.2, 114.4)
      ..cubicTo(310.45, 128.6, 299.05, 140.05, 284.75, 140.1)
      ..lineTo(35.0, 140.1)
      ..cubicTo(20.85, 139.85, 9.6, 128.4, 9.8, 114.25)
      ..lineTo(10.6, 16.4)
      ..close();
  }

  static Path pocketOpeningPath() {
    return Path()
      ..moveTo(4.0, 9.2)
      ..lineTo(112.2, 9.55)
      ..cubicTo(126.0, 9.55, 134.8, 22.15, 154.0, 23.9)
      ..cubicTo(174.1, 25.6, 189.0, 20.8, 198.95, 12.0)
      ..cubicTo(206.2, 5.85, 217.2, 7.95, 231.2, 7.9)
      ..lineTo(316.0, 6.1);
  }

  static Path pocketStitchPath() {
    return Path()
      ..moveTo(13.6, 22.2)
      ..lineTo(13.6, 109.8)
      ..cubicTo(13.6, 126.4, 25.6, 135.4, 40.6, 135.4)
      ..lineTo(279.8, 136.0)
      ..cubicTo(294.4, 135.8, 306.2, 126.3, 306.2, 110.0)
      ..lineTo(306.2, 20.4);
  }

  static Path handmadeRoundedRectPath(
    Rect rect, {
    required double radius,
    required double phase,
  }) {
    final maxRadius = math.min(rect.width, rect.height) / 2;
    final baseRadius = radius.clamp(0.0, maxRadius);
    final left = rect.left + _edgeNoise(phase, 1);
    final top = rect.top + _edgeNoise(phase, 2);
    final right = rect.right + _edgeNoise(phase, 3);
    final bottom = rect.bottom + _edgeNoise(phase, 4);
    final tl = (baseRadius + _edgeNoise(phase, 5)).clamp(0.0, maxRadius);
    final tr = (baseRadius + _edgeNoise(phase, 6)).clamp(0.0, maxRadius);
    final br = (baseRadius + _edgeNoise(phase, 7)).clamp(0.0, maxRadius);
    final bl = (baseRadius + _edgeNoise(phase, 8)).clamp(0.0, maxRadius);
    const k = 0.5522847498307936;

    return Path()
      ..moveTo(left + tl, top + (_edgeNoise(phase, 9) * 0.25))
      ..lineTo(right - tr, top + (_edgeNoise(phase, 10) * 0.25))
      ..cubicTo(
        right - tr + (tr * k),
        top,
        right,
        top + tr - (tr * k),
        right,
        top + tr,
      )
      ..lineTo(right + (_edgeNoise(phase, 11) * 0.18), bottom - br)
      ..cubicTo(
        right,
        bottom - br + (br * k),
        right - br + (br * k),
        bottom,
        right - br,
        bottom,
      )
      ..lineTo(left + bl, bottom + (_edgeNoise(phase, 12) * 0.2))
      ..cubicTo(
        left + bl - (bl * k),
        bottom,
        left,
        bottom - bl + (bl * k),
        left,
        bottom - bl,
      )
      ..lineTo(left + (_edgeNoise(phase, 13) * 0.18), top + tl)
      ..cubicTo(
        left,
        top + tl - (tl * k),
        left + tl - (tl * k),
        top,
        left + tl,
        top,
      )
      ..close();
  }

  static double _edgeNoise(double phase, int step) {
    return math.sin((phase + step) * 1.71) * 0.46 +
        math.sin((phase + step) * 0.53) * 0.18;
  }

  static void paintSoftPathCastShadow(Canvas canvas, Path path) {
    canvas.drawPath(
      path.shift(const Offset(0, 10)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.24)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
    );
    canvas.drawPath(
      path.shift(const Offset(0, 4)),
      Paint()
        ..color = const Color(0xFF020814).withValues(alpha: 0.34)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
  }

  static void paintTextureSurface(
    Canvas canvas, {
    required Rect rect,
    required Path clip,
    required ui.Image? leather,
    required Color shadow,
    required Color mid,
    required Color glow,
    double textureScale = 1,
  }) {
    canvas.save();
    canvas.clipPath(clip);

    canvas.drawRect(
      rect,
      Paint()
        ..shader = ui.Gradient.linear(
          rect.topLeft,
          rect.bottomRight,
          [glow, mid, shadow],
          const [0, 0.48, 1],
        ),
    );

    if (leather != null) {
      final source = Rect.fromLTWH(
        0,
        0,
        leather.width.toDouble(),
        leather.height.toDouble(),
      );
      final textureRect = Rect.fromCenter(
        center: rect.center,
        width: rect.width * textureScale,
        height: rect.height * textureScale,
      );
      canvas.drawImageRect(
        leather,
        source,
        textureRect,
        Paint()
          ..filterQuality = FilterQuality.high
          ..isAntiAlias = true
          ..colorFilter = ColorFilter.mode(
            Colors.white.withValues(alpha: 0.36),
            BlendMode.modulate,
          ),
      );
    } else {
      _paintProceduralGrain(canvas, rect);
    }

    canvas.drawRect(
      rect,
      Paint()
        ..blendMode = BlendMode.multiply
        ..shader = ui.Gradient.linear(
          rect.topRight,
          rect.bottomLeft,
          [
            Colors.black.withValues(alpha: 0.10),
            Colors.black.withValues(alpha: 0.34),
          ],
          const [0, 1],
        ),
    );
    canvas.drawRect(
      rect,
      Paint()
        ..blendMode = BlendMode.screen
        ..shader = ui.Gradient.radial(
          rect.topCenter.translate(rect.width * 0.1, rect.height * 0.12),
          rect.width * 0.7,
          [
            Colors.white.withValues(alpha: 0.11),
            Colors.transparent,
          ],
          const [0, 1],
        ),
    );
    canvas.drawRect(
      rect,
      Paint()
        ..blendMode = BlendMode.screen
        ..shader = ui.Gradient.radial(
          rect.topLeft.translate(rect.width * 0.32, rect.height * 0.22),
          rect.width * 0.62,
          [
            Colors.white.withValues(alpha: 0.072),
            Colors.white.withValues(alpha: 0.018),
            Colors.transparent,
          ],
          const [0, 0.42, 1],
        ),
    );
    canvas.restore();
  }

  static void paintBackPanelSideWalls(Canvas canvas, Path path, Rect bounds) {
    canvas.save();
    canvas.clipPath(path);
    canvas.drawRect(
      Rect.fromLTWH(bounds.left, bounds.top + 18, 28, bounds.height - 34),
      Paint()
        ..blendMode = BlendMode.multiply
        ..shader = ui.Gradient.linear(
          bounds.centerLeft,
          bounds.centerRight,
          [
            Colors.black.withValues(alpha: 0.28),
            Colors.black.withValues(alpha: 0.08),
            Colors.transparent,
          ],
          const [0, 0.55, 1],
        ),
    );
    canvas.drawRect(
      Rect.fromLTWH(bounds.right - 28, bounds.top + 18, 28, bounds.height - 34),
      Paint()
        ..blendMode = BlendMode.multiply
        ..shader = ui.Gradient.linear(
          bounds.centerRight,
          bounds.centerLeft,
          [
            Colors.black.withValues(alpha: 0.24),
            Colors.black.withValues(alpha: 0.07),
            Colors.transparent,
          ],
          const [0, 0.58, 1],
        ),
    );
    canvas.restore();
  }

  static void paintCardPressureBulge(Canvas canvas, Path path, Rect bounds) {
    canvas.save();
    canvas.clipPath(path);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(bounds.center.dx, bounds.top + 96),
        width: 214,
        height: 72,
      ),
      Paint()
        ..blendMode = BlendMode.screen
        ..shader = ui.Gradient.radial(
          Offset(bounds.center.dx, bounds.top + 90),
          118,
          [
            Colors.white.withValues(alpha: 0.042),
            Colors.white.withValues(alpha: 0.014),
            Colors.transparent,
          ],
          const [0, 0.56, 1],
        ),
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(bounds.center.dx, bounds.top + 116),
        width: 236,
        height: 86,
      ),
      Paint()
        ..blendMode = BlendMode.multiply
        ..shader = ui.Gradient.radial(
          Offset(bounds.center.dx, bounds.top + 116),
          128,
          [
            Colors.transparent,
            Colors.black.withValues(alpha: 0.06),
          ],
          const [0.46, 1],
        ),
    );
    canvas.restore();
  }

  static void _paintProceduralGrain(Canvas canvas, Rect rect) {
    final lightPaint = Paint()
      ..strokeWidth = 0.55
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withValues(alpha: 0.035);
    final darkPaint = Paint()
      ..strokeWidth = 0.75
      ..strokeCap = StrokeCap.round
      ..color = Colors.black.withValues(alpha: 0.12);

    for (var i = 0; i < 280; i++) {
      final n = i.toDouble();
      final x = rect.left + (((n * 37.0) % 997) / 997.0) * rect.width;
      final y = rect.top + (((n * 61.0) % 991) / 991.0) * rect.height;
      final wave = math.sin(n * 1.73) * 1.8;
      final length = 2.4 + (((n * 17.0) % 100) / 100.0) * 5.2;
      final angle = -0.35 + math.sin(n * 0.79) * 0.24;
      final dx = math.cos(angle) * length;
      final dy = math.sin(angle) * length;
      canvas.drawLine(
        Offset(x, y + wave),
        Offset(x + dx, y + wave + dy),
        i.isEven ? lightPaint : darkPaint,
      );
    }
  }

  static void paintInsetHighlight(Canvas canvas, RRect rrect) {
    canvas.drawRRect(
      rrect.deflate(1.5),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.1
        ..shader = ui.Gradient.linear(
          rrect.outerRect.topLeft,
          rrect.outerRect.bottomRight,
          [
            const Color(0xFF7CC2F5).withValues(alpha: 0.14),
            Colors.transparent,
            Colors.black.withValues(alpha: 0.20),
          ],
          const [0, 0.42, 1],
        ),
    );
  }

  static void paintFoldedLeatherEdge(
    Canvas canvas, {
    required Path outerPath,
    required Path innerPath,
    required Rect bounds,
  }) {
    final edgeBand = Path()
      ..fillType = PathFillType.evenOdd
      ..addPath(outerPath, Offset.zero)
      ..addPath(innerPath, Offset.zero);

    canvas.save();
    canvas.clipPath(outerPath);

    canvas.drawPath(
      edgeBand,
      Paint()
        ..shader = ui.Gradient.linear(
          bounds.topCenter,
          bounds.bottomCenter,
          [
            const Color(0xFF01020A),
            const Color(0xFF080A1C),
            const Color(0xFF161A3E),
            const Color(0xFF01020A),
          ],
          const [0, 0.2, 0.58, 1],
        ),
    );
    canvas.drawPath(
      edgeBand,
      Paint()
        ..blendMode = BlendMode.screen
        ..shader = ui.Gradient.linear(
          bounds.topLeft,
          bounds.bottomRight,
          [
            const Color(0xFFC9D1FF).withValues(alpha: 0.09),
            Colors.transparent,
            Colors.white.withValues(alpha: 0.022),
          ],
          const [0, 0.45, 1],
        ),
    );
    canvas.drawPath(
      edgeBand,
      Paint()
        ..blendMode = BlendMode.softLight
        ..shader = ui.Gradient.linear(
          bounds.centerLeft,
          bounds.centerRight,
          [
            Colors.white.withValues(alpha: 0.025),
            Colors.transparent,
            Colors.black.withValues(alpha: 0.10),
          ],
          const [0, 0.52, 1],
        ),
    );
    canvas.drawPath(
      edgeBand,
      Paint()
        ..blendMode = BlendMode.multiply
        ..shader = ui.Gradient.linear(
          bounds.topRight,
          bounds.bottomLeft,
          [
            Colors.transparent,
            Colors.black.withValues(alpha: 0.28),
            Colors.black.withValues(alpha: 0.52),
          ],
          const [0.1, 0.64, 1],
        ),
    );

    canvas.drawPath(
      innerPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.8
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFF030827).withValues(alpha: 0.40),
    );
    canvas.drawPath(
      innerPath.shift(const Offset(0, -0.55)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.75
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFFD0D7FF).withValues(alpha: 0.10),
    );

    canvas.restore();
  }

  static void paintCornerCompression(Canvas canvas, Path path) {
    canvas.save();
    canvas.clipPath(path);
    final paint = Paint()
      ..blendMode = BlendMode.multiply
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 9)
      ..color = Colors.black.withValues(alpha: 0.105);

    canvas.drawOval(
      const Rect.fromLTWH(2, 123, 58, 32),
      paint,
    );
    canvas.drawOval(
      const Rect.fromLTWH(260, 122, 58, 32),
      paint..color = Colors.black.withValues(alpha: 0.095),
    );
    canvas.restore();
  }

  static void paintFrontPanelLift(Canvas canvas, Path path) {
    canvas.save();
    canvas.clipPath(path);
    canvas.drawRect(
      const Rect.fromLTWH(0, 0, 320, 28),
      Paint()
        ..blendMode = BlendMode.multiply
        ..shader = ui.Gradient.linear(
          const Offset(0, 0),
          const Offset(0, 30),
          [
            Colors.black.withValues(alpha: 0.16),
            Colors.black.withValues(alpha: 0.05),
            Colors.transparent,
          ],
          const [0, 0.58, 1],
        ),
    );
    canvas.drawRect(
      const Rect.fromLTWH(8, 18, 18, 102),
      Paint()
        ..blendMode = BlendMode.multiply
        ..shader = ui.Gradient.linear(
          const Offset(8, 70),
          const Offset(28, 70),
          [
            Colors.black.withValues(alpha: 0.18),
            Colors.black.withValues(alpha: 0.04),
            Colors.transparent,
          ],
          const [0, 0.55, 1],
        ),
    );
    canvas.drawRect(
      const Rect.fromLTWH(294, 18, 18, 102),
      Paint()
        ..blendMode = BlendMode.multiply
        ..shader = ui.Gradient.linear(
          const Offset(312, 70),
          const Offset(292, 70),
          [
            Colors.black.withValues(alpha: 0.16),
            Colors.black.withValues(alpha: 0.04),
            Colors.transparent,
          ],
          const [0, 0.55, 1],
        ),
    );
    canvas.restore();
  }

  static void paintPocketOpeningLip(Canvas canvas, Path path) {
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = const Color(0xFF01020C).withValues(alpha: 0.72),
    );
    canvas.drawPath(
      path.shift(const Offset(0, 0.85)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.1
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = const Color(0xFF111842).withValues(alpha: 0.42),
    );
    canvas.drawPath(
      path.shift(const Offset(0, -0.7)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = const Color(0xFFD3D8FF).withValues(alpha: 0.045),
    );
  }

  static void paintStitchChannel(Canvas canvas, Path path) {
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.55
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = Colors.black.withValues(alpha: 0.15)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );
    canvas.drawPath(
      path.shift(const Offset(0, -0.45)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = Colors.white.withValues(alpha: 0.04),
    );
    canvas.drawPath(
      path.shift(const Offset(0, 0.55)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.9
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = Colors.black.withValues(alpha: 0.10),
    );
  }

  static void paintSaddleStitches(
    Canvas canvas,
    Path path, {
    required Color threadColor,
    required Rect bounds,
    double startOffset = 0,
  }) {
    final metrics = path.computeMetrics(forceClosed: false);
    final shadowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.46
      ..strokeCap = StrokeCap.round
      ..color = Colors.black.withValues(alpha: 0.18)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.55);
    final dentPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.038)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    var stitchIndex = 0;
    for (final metric in metrics) {
      var distance = 5.2 + startOffset;
      while (distance < metric.length - 2) {
        final tangent = metric.getTangentForOffset(distance);
        if (tangent == null) {
          distance += 10.6;
          continue;
        }

        final direction = tangent.vector;
        final normal = Offset(-direction.dy, direction.dx);
        final angle = _stitchNoise(stitchIndex, 0.31) * (math.pi / 60);
        final rawStitchDirection = Offset(
          (normal.dx * 0.9) + (direction.dx * 0.28),
          (normal.dy * 0.9) + (direction.dy * 0.28),
        );
        final stitchDirection = _rotateOffset(rawStitchDirection, angle);
        final length = 4.8 + (_stitchNoise(stitchIndex, 1.97) * 0.5);
        final half = stitchDirection * (length / 2);
        final center = tangent.position;
        final start = center - half;
        final end = center + half;

        canvas.drawCircle(start, 2.4, dentPaint);
        canvas.drawCircle(end, 2.1, dentPaint);
        canvas.drawLine(
          start + const Offset(0, 0.75),
          end + const Offset(0, 0.75),
          shadowPaint,
        );
        canvas.drawLine(
          start,
          end,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.18 + (_stitchNoise(stitchIndex, 4.2).abs() * 0.14)
            ..strokeCap = StrokeCap.round
            ..shader = ui.Gradient.linear(
              start,
              end,
              [
                Color.lerp(threadColor, Colors.black, 0.18)!
                    .withValues(alpha: 0.86),
                threadColor.withValues(alpha: 0.90),
                Color.lerp(threadColor, Colors.black, 0.24)!
                    .withValues(alpha: 0.82),
              ],
              const [0, 0.46, 1],
            ),
        );
        canvas.drawLine(
          start + (normal * 0.18),
          end + (normal * 0.18),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.42
            ..strokeCap = StrokeCap.round
            ..color = Colors.white.withValues(alpha: 0.05),
        );

        distance += 9.55 + (_stitchNoise(stitchIndex, 7.3) * 0.4);
        stitchIndex++;
      }
    }
  }

  static double _stitchNoise(int index, double salt) {
    return math.sin((index * 12.9898) + (salt * 78.233)) * 0.5 +
        math.sin((index * 3.173) + salt) * 0.18;
  }

  static Offset _rotateOffset(Offset offset, double radians) {
    final cosA = math.cos(radians);
    final sinA = math.sin(radians);
    return Offset(
      (offset.dx * cosA) - (offset.dy * sinA),
      (offset.dx * sinA) + (offset.dy * cosA),
    );
  }

  static void paintPocketCastShadow(Canvas canvas, Path path) {
    canvas.drawPath(
      path.shift(const Offset(0, 5)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.24)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
  }
}
