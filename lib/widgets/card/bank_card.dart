import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../constants/layout_constants.dart';
import '../../utils/card_number_format.dart';
import '../../constants/card_visuals.dart'; // ✅ Import Visual Engine
import '../bank/bank_logo.dart';
import 'card_visual_asset_layer.dart';
import 'card_details_block.dart';
import 'secure_reveal_wrapper.dart';

class BankCard extends StatelessWidget {
  final String bankLogo; // This acts as the Bank CID (e.g., 'hdfc', 'axis')
  final String networkLogo;
  final String cardType;
  final String cardNumber;
  final String validThru;
  final String holderName;
  final String cvv;
  final String? customBankName;
  final String? customBankLogoPath;
  final Color? customGradientStartColor;
  final Color? customGradientMiddleColor;
  final Color? customGradientEndColor;
  final String? customCardImagePath;
  final Alignment customCardImageAlignment;
  final String? customCardPatternAssetPath;
  final bool showActions;

  final VoidCallback onEyeTap;
  final VoidCallback? onShareTap;

  const BankCard({
    super.key,
    required this.bankLogo,
    required this.networkLogo,
    required this.cardType,
    required this.cardNumber,
    required this.validThru,
    required this.holderName,
    required this.cvv,
    this.customBankName,
    this.customBankLogoPath,
    this.customGradientStartColor,
    this.customGradientMiddleColor,
    this.customGradientEndColor,
    this.customCardImagePath,
    this.customCardImageAlignment = Alignment.center,
    this.customCardPatternAssetPath,
    this.showActions = true,
    // Gradient is removed from constructor; it is now resolved internally.
    required this.onEyeTap,
    this.onShareTap,
  });

  /// ---------------- MASKED FORMAT ----------------
  String get masked {
    return CardNumberFormat.masked(cardNumber);
  }

  /// ---------------- REVEALED FORMAT ----------------
  String _formatCardNumber(String digits) {
    return CardNumberFormat.format(digits);
  }

  @override
  Widget build(BuildContext context) {
    final scope = BankCardScope.of(context);

    // ✅ RESOLVE VISUALS (Gradient + Pattern)
    final customStart = customGradientStartColor;
    final customMiddle = customGradientMiddleColor;
    final customEnd = customGradientEndColor;
    final visual = customStart != null && customEnd != null
        ? CardVisuals.customGradient(
            customStart,
            customEnd,
            middle: customMiddle,
            visualAssetPath: customCardPatternAssetPath,
          )
        : CardVisuals.forBank(bankLogo);
    final customImagePath = customCardImagePath?.trim();
    final customImageFile =
        customImagePath != null && customImagePath.isNotEmpty
            ? File(customImagePath)
            : null;
    final customImage = customImageFile != null && customImageFile.existsSync()
        ? DecorationImage(
            image: FileImage(customImageFile),
            fit: BoxFit.cover,
            alignment: customCardImageAlignment,
          )
        : null;

    // ================= SECURITY LOGIC (LOCKED) =================
    final bool showCvv = scope.revealed && scope.cvvVisible;

    final String displayNumber = showCvv
        ? masked
        : scope.revealed
            ? _formatCardNumber(cardNumber)
            : masked;

    final String displayCvv = showCvv ? cvv : '***';
    // ===========================================================

    return AspectRatio(
      aspectRatio: cardAspectRatioWidth / cardAspectRatioHeight,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bankLogoMaxWidth =
              bankLogoMaxWidthForCard(constraints.maxWidth);

          return Container(
            padding: EdgeInsets
                .zero, // Padding is handled inside Stack for full-bleed background
            decoration: BoxDecoration(
              gradient: visual.gradient, // ✅ Use Brand Gradient
              image: customImage,
              borderRadius: BorderRadius.circular(cardBorderRadius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.16),
                  blurRadius: 16,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: Stack(
              children: [
                // ✅ 1. BRAND SVG VISUAL LAYER (Behind everything)
                if (customImage == null && visual.visualAssetPath != null)
                  Positioned.fill(
                    child: CardVisualAssetLayer(
                      visual: visual,
                      borderRadius: BorderRadius.circular(cardBorderRadius),
                    ),
                  ),

                // ✅ 2. CONTENT PADDING CONTAINER
                // (We re-add padding here so content doesn't touch edges)
                Padding(
                  padding: const EdgeInsets.all(cardPadding),
                  child: Stack(
                    children: [
                      // ================= BANK HEADER =================
                      Positioned(
                        top: 0,
                        left: 0,
                        child: Row(
                          children: [
                            BankLogo(
                              bankCid: bankLogo,
                              size: bankLogoHeight,
                              width: bankLogoMaxWidth,
                              customLogoPath: customBankLogoPath,
                              customLabel: customBankName,
                            ),
                          ],
                        ),
                      ),

                      // ================= NETWORK LOGO + TYPE =================
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            SvgPicture.asset(
                              networkLogo,
                              height: networkLogoHeight,
                            ),
                            const SizedBox(height: 5),
                            Text(
                              cardType,
                              textAlign: TextAlign.right,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                height: 1,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ================= CHIP =================
                      Positioned(
                        top: chipTopOffset,
                        left: 0,
                        child: SvgPicture.asset(
                          'assets/images/chip.svg',
                          width: chipWidth,
                        ),
                      ),

                      // ================= CARD DETAILS =================
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: detailsBottomOffset,
                        child: CardDetailsBlock(
                          cardNumber: displayNumber,
                          rawCardNumber: cardNumber,
                          validThru: validThru,
                          holderName: holderName,
                          cvv: displayCvv,
                          showCvvToggle: scope.revealed,
                          isCvvVisible: scope.cvvVisible,
                          onToggleCvv: scope.onToggleCvv,
                        ),
                      ),

                      if (showActions)
                        // ================= CARD ACTIONS =================
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: _CardActions(
                            revealed: scope.revealed,
                            onEyeTap: onEyeTap,
                            onShareTap: onShareTap,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ================= ACTION BUTTON =================

class _CardActions extends StatefulWidget {
  static const double _buttonSize = 44;
  static const double _buttonGap = 8;

  final bool revealed;
  final VoidCallback onEyeTap;
  final VoidCallback? onShareTap;

  const _CardActions({
    required this.revealed,
    required this.onEyeTap,
    this.onShareTap,
  });

  @override
  State<_CardActions> createState() => _CardActionsState();
}

class _CardActionsState extends State<_CardActions>
    with TickerProviderStateMixin {
  static const Curve _iosSettleCurve = Cubic(0.22, 1, 0.36, 1);
  static const Duration _eyeDelay = Duration(milliseconds: 110);
  static const Duration _eyeDuration = Duration(milliseconds: 260);
  static const Duration _shareDelay = Duration(milliseconds: 120);
  static const Duration _shareDuration = Duration(milliseconds: 260);

  late final AnimationController _eyeController;
  late final AnimationController _shareController;
  late final Animation<double> _eyeAnimation;
  late final Animation<double> _shareAnimation;
  Future<void>? _eyeSequence;
  Future<void>? _shareSequence;

  @override
  void initState() {
    super.initState();
    _eyeController = AnimationController(
      vsync: this,
      duration: _eyeDuration,
    );
    _shareController = AnimationController(
      vsync: this,
      duration: _shareDuration,
      value: widget.revealed ? 1 : 0,
    );
    _eyeAnimation = CurvedAnimation(
      parent: _eyeController,
      curve: _iosSettleCurve,
      reverseCurve: Curves.easeInCubic,
    );
    _shareAnimation = CurvedAnimation(
      parent: _shareController,
      curve: _iosSettleCurve,
      reverseCurve: Curves.easeInCubic,
    );
    _startEyeEntrance();
  }

  @override
  void didUpdateWidget(covariant _CardActions oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.revealed == oldWidget.revealed) return;

    if (widget.revealed) {
      final sequence = Future<void>.delayed(_shareDelay);
      _shareSequence = sequence;
      sequence.then((_) {
        if (!mounted || _shareSequence != sequence || !widget.revealed) {
          return;
        }
        _shareController.forward();
      });
    } else {
      _shareSequence = null;
      _shareController.reverse();
    }
  }

  @override
  void dispose() {
    _eyeController.dispose();
    _shareController.dispose();
    super.dispose();
  }

  void _startEyeEntrance() {
    final sequence = Future<void>.delayed(_eyeDelay);
    _eyeSequence = sequence;
    sequence.then((_) {
      if (!mounted || _eyeSequence != sequence) return;
      _eyeController.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: (_CardActions._buttonSize * 2) + _CardActions._buttonGap,
      height: _CardActions._buttonSize,
      child: Align(
        alignment: Alignment.centerRight,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _eyeAnimation,
              builder: (context, child) {
                final entrance = _eyeAnimation.value;
                return IgnorePointer(
                  ignoring: entrance < 0.98,
                  child: Opacity(
                    opacity: entrance,
                    child: Transform.scale(
                      scale: 0.72 + (0.28 * entrance),
                      alignment: Alignment.center,
                      child: child,
                    ),
                  ),
                );
              },
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                switchInCurve: _iosSettleCurve,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(
                      scale: Tween<double>(begin: 0.92, end: 1).animate(
                        CurvedAnimation(
                          parent: animation,
                          curve: _iosSettleCurve,
                        ),
                      ),
                      child: child,
                    ),
                  );
                },
                child: _CardActionButton(
                  key: ValueKey(widget.revealed),
                  icon:
                      widget.revealed ? Icons.visibility_off : Icons.visibility,
                  onTap: widget.onEyeTap,
                ),
              ),
            ),
            AnimatedBuilder(
              animation: _shareAnimation,
              builder: (context, child) {
                final progress = _shareAnimation.value;
                return SizedBox(
                  width: (_CardActions._buttonGap + _CardActions._buttonSize) *
                      progress,
                  height: _CardActions._buttonSize,
                  child: ClipRect(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: IgnorePointer(
                        ignoring: !widget.revealed,
                        child: Opacity(
                          opacity: progress,
                          child: Transform.translate(
                            offset: Offset(10 * (1 - progress), 0),
                            child: Transform.scale(
                              scale: 0.72 + (0.28 * progress),
                              alignment: Alignment.center,
                              child: child,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
              child: _CardActionButton(
                icon: Icons.share,
                onTap: widget.onShareTap,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _CardActionButton({
    super.key,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black26,
        ),
        child: Icon(
          icon,
          size: 20,
          color: Colors.white,
        ),
      ),
    );
  }
}
