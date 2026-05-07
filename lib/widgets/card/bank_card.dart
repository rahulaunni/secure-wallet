import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../constants/layout_constants.dart';
import '../../utils/card_number_format.dart';
import '../../constants/card_visuals.dart'; // ✅ Import Visual Engine
import '../bank/bank_logo.dart';
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
  final Color? customGradientEndColor;

  final VoidCallback onEyeTap;
  final VoidCallback? onShareTap;
  final VoidCallback? onDeleteTap;

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
    this.customGradientEndColor,
    // Gradient is removed from constructor; it is now resolved internally.
    required this.onEyeTap,
    this.onShareTap,
    this.onDeleteTap,
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
    final customEnd = customGradientEndColor;
    final visual = customStart != null && customEnd != null
        ? CardVisuals.customGradient(customStart, customEnd)
        : CardVisuals.forBank(bankLogo);

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
              borderRadius: BorderRadius.circular(cardBorderRadius),
              boxShadow: [
                BoxShadow(
                  color: visual.gradient.colors.first.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              children: [
                // ✅ 1. BRAND PATTERN LAYER (Behind everything)
                if (visual.patternPainter != null)
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(cardBorderRadius),
                      child: CustomPaint(
                        painter: visual.patternPainter,
                      ),
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
                            const SizedBox(width: 8),
                            Container(
                              width: bankDividerWidth,
                              height: bankDividerHeight,
                              color: Colors.white54,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              cardType,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ================= NETWORK LOGO =================
                      Positioned(
                        top: 0,
                        right: 0,
                        child: SvgPicture.asset(
                          networkLogo,
                          height: networkLogoHeight,
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

                      // ================= ACTION BUTTONS =================
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Row(
                          children: [
                            _CardActionButton(
                              icon: scope.revealed
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              onTap: onEyeTap,
                            ),
                            const SizedBox(width: 8),
                            _CardActionButton(
                              icon: scope.revealed ? Icons.share : Icons.delete,
                              onTap: scope.revealed ? onShareTap : onDeleteTap,
                            ),
                          ],
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

class _CardActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _CardActionButton({
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
