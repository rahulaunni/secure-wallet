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
import 'package:swallet/models/card_network.dart';
import 'package:swallet/models/card_type.dart';
import 'package:swallet/screens/app_unlock/security_setup_screen.dart';
import 'package:swallet/screens/app_unlock/security_verification_screen.dart';
import 'package:swallet/utils/adaptive_layout.dart';
import 'package:swallet/utils/security_store.dart';
import 'package:swallet/widgets/add_card/add_card_material_tokens.dart';
import 'package:swallet/widgets/buttons/custom_back_button.dart';
import 'package:swallet/widgets/card/bank_card.dart';
import 'package:swallet/widgets/card/secure_reveal_wrapper.dart';
import 'package:swallet/widgets/top_nav/top_nav_constants.dart';

class PinLockScreen extends StatefulWidget {
  final VoidCallback onUnlocked;

  const PinLockScreen({
    super.key,
    required this.onUnlocked,
  });

  @override
  State<PinLockScreen> createState() => _PinLockScreenState();
}

class _PinLockScreenState extends State<PinLockScreen>
    with TickerProviderStateMixin {
  final LocalAuthentication _auth = LocalAuthentication();
  final Box _settingsBox = Hive.box(HiveBoxes.settings);
  static const int _pinLength = 4;
  static const Color _lockBgLight = Color(0xFFFAFAFC);
  static const Color _lockBgDark = Color(0xFF101114);
  static const Color _lockTitleLight = Color(0xFF141414);
  static const Color _lockTitleDark = Color(0xFFF6F7FB);
  static const Color _lockSubtitleLight = Color(0xFF787878);
  static const Color _lockSubtitleDark = Color(0xFFB5B8C2);
  static const Color _keyBgLight = Color(0xFFF4F4F4);
  static const Color _keyBgDark = Color(0xFF23242A);
  static const Color _keyTextLight = Color(0xFF121212);
  static const Color _keyTextDark = Color(0xFFF7F8FA);

  String _enteredPin = '';
  String? _tempPinForCreation;
  bool _isCreating = false;
  bool _isError = false;
  bool _isUnlocking = false;
  bool _showResetButton = false;
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
      return;
    }

    setState(() {
      _isCreating = false;
      _statusMessage = 'Enter your App PIN';
      _showResetButton = false;
    });
    _triggerBiometrics();
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

    _triggerError('Wrong PIN. Try again.');
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

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyle,
      child: Scaffold(
        backgroundColor: useClassicPinLayout ? tokens.surface : lockBackground,
        body: useClassicPinLayout
            ? _buildClassicPinContent(tokens: tokens, isStep2: isStep2)
            : _buildPinContent(
                tokens: tokens,
                isStep2: isStep2,
              ),
      ),
    );
  }

  Widget _buildPinContent({
    required AddCardMaterialTokens tokens,
    required bool isStep2,
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
        const titleToWalletGap = 24.0;
        const walletToKeypadGap = 38.0;
        const keypadHeight = 356.0;
        const verticalBreathingRoom = 48.0;
        const designContentHeight = titleHeight +
            titleToWalletGap +
            280 +
            walletToKeypadGap +
            keypadHeight;
        final widthScale = (maxWidth - 48) / sourceWidth;
        final heightScale =
            (safeHeight - verticalBreathingRoom) / designContentHeight;
        final scale = math.max(0.52, math.min(widthScale, heightScale));
        final contentWidth = sourceWidth * scale;
        final titleTop = mediaPadding.top + (24 * scale);
        final walletTop = titleTop + (titleHeight + titleToWalletGap) * scale;
        final keypadTop = walletTop + ((280 + walletToKeypadGap) * scale);
        final keypadWidth = ((80 * scale) * 3) + ((24 * scale) * 2);
        final canvasWidth = maxWidth;
        final canvasHeight = maxHeight;
        final walletLeft = (canvasWidth - contentWidth) / 2;
        final homeFirstCardTop =
            mediaPadding.top + 12 + 40 + 12 + topNavHeight + 12;

        return SizedBox(
          width: canvasWidth,
          height: canvasHeight,
          child: ValueListenableBuilder<Box<CardData>>(
            valueListenable: Hive.box<CardData>(HiveBoxes.cards).listenable(),
            builder: (context, cardsBox, _) {
              final savedCards = cardsBox.values.toList(growable: false);
              return AnimatedBuilder(
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
                          hasSavedCards: savedCards.isNotEmpty,
                          scale: scale,
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
    final cards = savedCards.take(3).toList();

    if (cards.isNotEmpty) {
      while (cards.length < 3) {
        cards.add(_fallbackCards[cards.length]);
      }
      return cards;
    }

    return _fallbackCards;
  }

  static final List<CardData> _fallbackCards = [
    const CardData(
      bankCid: 'icici',
      cardNetwork: CardNetwork.visa,
      cardType: CardType.credit,
      cardNumber: '5375000000000895',
      expiry: '11/30',
      holderName: 'Nidin George',
      cvv: '123',
    ),
    const CardData(
      bankCid: 'federal',
      cardNetwork: CardNetwork.mastercard,
      cardType: CardType.debit,
      cardNumber: '5214000000004512',
      expiry: '08/29',
      holderName: 'Nidin George',
      cvv: '456',
    ),
    const CardData(
      bankCid: 'sbi',
      cardNetwork: CardNetwork.rupay,
      cardType: CardType.credit,
      cardNumber: '6073000000000895',
      expiry: '10/28',
      holderName: 'Nidin George',
      cvv: '789',
    ),
  ];

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
                for (var i = 0; i < 3; i++)
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
    required double unlock,
    required double scale,
    required double walletTopOnCanvas,
    required double homeFirstCardTop,
    required double canvasWidth,
  }) {
    final startTop = switch (index) {
      0 => 8.38098 * scale,
      1 => 47.2382 * scale,
      _ => 83.0477 * scale,
    };
    final stackedTop = (-24 + (index * 13.0)) * scale;
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
                customGradientEndColor: card.customGradientEndColor != null
                    ? Color(card.customGradientEndColor!)
                    : null,
                onEyeTap: () {},
                onShareTap: () {},
                onDeleteTap: () {},
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
    final caption = _isError || _errorMessage.isNotEmpty
        ? _errorMessage
        : _isCreating
            ? _statusMessage
            : 'Forgot PIN?';

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
                  color: _isError ? Colors.white : Colors.white,
                  fontSize: 14 * scale,
                  height: 1,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletPinDots(double scale) {
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
            color: filled ? Colors.white : Colors.transparent,
            border: Border.all(
              color: Colors.white.withValues(alpha: filled ? 1 : 0.72),
              width: 2 * scale,
            ),
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
          final headerTopPadding = isTightHeight ? 8.0 : 16.0;

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
                      20,
                      0,
                    ),
                    child: _buildClassicHeader(tokens, isStep2),
                  ),
                  if (!isTightHeight) const Spacer(flex: 2),
                  if (isTightHeight) const SizedBox(height: 16),
                  _buildClassicLockIntro(tokens, isTightHeight),
                  SizedBox(height: isTightHeight ? 18 : 24),
                  _buildClassicPinDots(tokens),
                  SizedBox(height: isTightHeight ? 10 : 18),
                  _buildClassicErrorAndReset(tokens),
                  if (!isTightHeight) const Spacer(flex: 3),
                  if (isTightHeight) const SizedBox(height: 8),
                  if (!_isCreating &&
                      _settingsBox.get(
                        'use_biometrics',
                        defaultValue: false,
                      ))
                    _buildClassicBiometricButton(tokens),
                  SizedBox(height: isTightHeight ? 10 : 14),
                  _buildClassicNumPad(tokens, compact: isTightHeight),
                  SizedBox(height: isTightHeight ? 10 : 20),
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
              border: Border.all(
                color: tokens.outlineVariant.withValues(alpha: 0.45),
              ),
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
                color: tokens.outlineVariant,
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

  Widget _buildClassicLockIntro(
    AddCardMaterialTokens tokens,
    bool isTightHeight,
  ) {
    return AnimatedBuilder(
      animation: _shakeController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_shakeAnimation.value * 2, 0),
          child: child,
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: isTightHeight ? 72 : 78,
            height: isTightHeight ? 72 : 78,
            decoration: BoxDecoration(
              color: tokens.primary,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              CupertinoIcons.lock_fill,
              color: tokens.onPrimary,
              size: isTightHeight ? 26 : 28,
            ),
          ),
          SizedBox(height: isTightHeight ? 14 : 18),
          Text(
            _statusMessage,
            textAlign: TextAlign.center,
            style: GoogleFonts.roboto(
              fontSize: isTightHeight ? 18 : 19,
              fontWeight: FontWeight.w600,
              color: tokens.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _isCreating
                ? 'This PIN protects your saved cards on this device.'
                : 'Unlock to view your wallet.',
            textAlign: TextAlign.center,
            style: GoogleFonts.roboto(
              color: tokens.onSurfaceVariant,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassicPinDots(AddCardMaterialTokens tokens) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_pinLength, (index) {
        final filled = index < _enteredPin.length;
        final color = _isError
            ? Colors.redAccent
            : (filled ? tokens.primary : tokens.outlineVariant);

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 10),
          width: filled ? 14 : 12,
          height: filled ? 14 : 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: filled ? color : Colors.transparent,
            border: Border.all(color: color, width: 1.8),
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
                    color: Colors.redAccent,
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

  Widget _buildClassicBiometricButton(AddCardMaterialTokens tokens) {
    return FilledButton.tonalIcon(
      onPressed: _triggerBiometrics,
      style: FilledButton.styleFrom(
        backgroundColor: tokens.primaryContainer,
        foregroundColor: tokens.onPrimaryContainer,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: tokens.pillRadius),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      ),
      icon: const Icon(CupertinoIcons.person_crop_circle_fill, size: 18),
      label: Text(
        'Use biometrics',
        style: GoogleFonts.roboto(fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _buildClassicNumPad(
    AddCardMaterialTokens tokens, {
    bool compact = false,
  }) {
    final buttonSize = compact ? 60.0 : 68.0;
    final columnGap = compact ? 22.0 : 26.0;
    final rowGap = compact ? 10.0 : 12.0;
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
                SizedBox(width: buttonSize, height: buttonSize),
                _buildClassicNumButton('0', tokens, buttonSize),
                _buildClassicBackspaceButton(tokens, buttonSize),
              ],
            ),
          ],
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
    return Material(
      color: tokens.surfaceContainerHigh,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTapDown: (_) => HapticFeedback.selectionClick(),
        onTap: () => _onNumTapped(number),
        child: SizedBox(
          width: buttonSize,
          height: buttonSize,
          child: Center(
            child: Text(
              number,
              style: GoogleFonts.roboto(
                fontSize: buttonSize < 70 ? 25 : 28,
                fontWeight: FontWeight.w400,
                color: tokens.onSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildClassicBackspaceButton(
    AddCardMaterialTokens tokens,
    double buttonSize,
  ) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTapDown: (_) => HapticFeedback.selectionClick(),
        onTap: _onBackspace,
        child: SizedBox(
          width: buttonSize,
          height: buttonSize,
          child: Icon(
            CupertinoIcons.delete_left,
            color: tokens.onSurfaceVariant,
            size: buttonSize < 70 ? 25 : 28,
          ),
        ),
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
        color: isActive ? tokens.primary : tokens.surfaceContainer,
        border: Border.all(
          color: isActive ? tokens.primary : tokens.outlineVariant,
          width: 1.4,
        ),
      ),
      child: Text(
        step,
        style: GoogleFonts.roboto(
          color: isActive ? tokens.onPrimary : tokens.onSurfaceVariant,
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildNumPad(AddCardMaterialTokens tokens, {required double scale}) {
    final buttonSize = 80 * scale;
    final columnGap = 24 * scale;
    final rowGap = 12 * scale;
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildBiometricPadButton(tokens, buttonSize, scale),
              _buildNumButton('0', tokens, buttonSize, scale),
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

    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTapDown: (_) => HapticFeedback.selectionClick(),
        onTap: _triggerBiometrics,
        child: SizedBox(
          width: buttonSize,
          height: buttonSize,
          child: Icon(
            Icons.fingerprint,
            color: _isDark ? _keyTextDark : _keyTextLight,
            size: 27 * scale,
          ),
        ),
      ),
    );
  }

  Widget _buildDeletePadButton(
    AddCardMaterialTokens tokens,
    double buttonSize,
    double scale,
  ) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18 * scale),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTapDown: (_) => HapticFeedback.selectionClick(),
        onTap: _onBackspace,
        child: SizedBox(
          width: buttonSize,
          height: buttonSize,
          child: Center(
            child: Text(
              'Delete',
              style: GoogleFonts.poppins(
                color: _isDark ? _keyTextDark : _keyTextLight,
                fontSize: 16 * scale,
                height: 1,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: numbers
          .map((n) => _buildNumButton(n, tokens, buttonSize, scale))
          .toList(),
    );
  }

  Widget _buildNumButton(
    String number,
    AddCardMaterialTokens tokens,
    double buttonSize,
    double scale,
  ) {
    return Material(
      color: _isDark ? _keyBgDark : _keyBgLight,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTapDown: (_) => HapticFeedback.selectionClick(),
        onTap: () => _onNumTapped(number),
        child: SizedBox(
          width: buttonSize,
          height: buttonSize,
          child: Center(
            child: Text(
              number,
              style: GoogleFonts.poppins(
                fontSize: 24 * scale,
                height: 1,
                fontWeight: FontWeight.w500,
                color: _isDark ? _keyTextDark : _keyTextLight,
              ),
            ),
          ),
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
