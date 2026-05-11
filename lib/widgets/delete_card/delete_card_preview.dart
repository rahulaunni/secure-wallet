import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../constants/layout_constants.dart';
import '../../constants/card_visuals.dart';
import '../../models/card_data.dart';
import '../../models/card_type.dart';
import '../../utils/card_number_format.dart';
import '../bank/bank_logo.dart';
import '../card/card_visual_asset_layer.dart';

class DeleteCardPreview extends StatelessWidget {
  final CardData card;
  final bool isDark;

  const DeleteCardPreview({
    super.key,
    required this.card,
    required this.isDark,
  });

  // ================= MASKED NUMBER =================
  String get _maskedNumber {
    return CardNumberFormat.masked(card.cardNumber);
  }

  @override
  Widget build(BuildContext context) {
    final customStart = card.customGradientStartColor;
    final customMiddle = card.customGradientMiddleColor;
    final customEnd = card.customGradientEndColor;
    final visual = customStart != null && customEnd != null
        ? CardVisuals.customGradient(
            Color(customStart),
            Color(customEnd),
            middle: customMiddle != null ? Color(customMiddle) : null,
            visualAssetPath: card.customCardPatternAssetPath,
          )
        : CardVisuals.forBank(card.bankCid);

    return AspectRatio(
      aspectRatio: cardAspectRatioWidth / cardAspectRatioHeight,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bankLogoMaxWidth = bankLogoMaxWidthForCard(
            constraints.maxWidth,
            padding: 14,
          );

          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: visual.gradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Stack(
              children: [
                if (visual.visualAssetPath != null)
                  Positioned.fill(
                    child: CardVisualAssetLayer(
                      visual: visual,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                Positioned(
                  top: 0,
                  left: 0,
                  child: Row(
                    children: [
                      BankLogo(
                        bankCid: card.bankCid,
                        size: bankLogoHeight,
                        width: bankLogoMaxWidth,
                        customLogoPath: card.customBankLogoPath,
                        customLabel: card.customBankName,
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 1,
                        height: 14,
                        color: Colors.white38,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        card.cardType == CardType.credit ? 'Credit' : 'Debit',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
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
                    card.cardNetwork.assetPath,
                    height: 24,
                  ),
                ),

                // ================= CHIP =================
                Positioned(
                  top: 36,
                  left: 0,
                  child: SvgPicture.asset(
                    'assets/images/chip.svg',
                    width: 34,
                  ),
                ),

                // ================= DETAILS =================
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // CARD NUMBER
                      Text(
                        _maskedNumber,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),

                      // 📉 TWEAKED: Tighter gap (8 -> 6)
                      const SizedBox(height: 6),

                      // VALID + CVV
                      Row(
                        children: [
                          Text(
                            'VALID\nTHRU',
                            style: GoogleFonts.poppins(
                              fontSize: 8,
                              height: 1.0,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            card.expiry,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              letterSpacing: 1.0,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            'CVV ***',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              letterSpacing: 1.0,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),

                      // 📉 TWEAKED: Tighter gap (6 -> 6)
                      const SizedBox(height: 6),

                      // HOLDER NAME
                      Text(
                        card.holderName.toUpperCase(),
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          letterSpacing: 1.0,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
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
