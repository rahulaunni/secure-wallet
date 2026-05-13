import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../constants/layout_constants.dart';
import '../../../utils/card_number_format.dart';
import '../../bank/bank_logo.dart';
import '../card_details_block.dart';

class PreviewCardVisual extends StatelessWidget {
  final Gradient gradient;
  final String bankCid;
  final String cardType;
  final String networkLogo;

  /// Digits only (no spaces)
  final String cardNumber;

  final bool showBankBrand;
  final bool showNetwork;

  const PreviewCardVisual({
    super.key,
    required this.gradient,
    required this.bankCid,
    required this.cardType,
    required this.networkLogo,
    required this.cardNumber,
    required this.showBankBrand,
    required this.showNetwork,
  });

  String _buildMaskedCardNumber(String digits) {
    return CardNumberFormat.progressiveMask(digits);
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: cardAspectRatioWidth / cardAspectRatioHeight,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bankLogoMaxWidth =
              bankLogoMaxWidthForCard(constraints.maxWidth);

          return Container(
            padding: const EdgeInsets.all(cardPadding),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(cardBorderRadius),
            ),
            child: Stack(
              children: [
                // ================= BANK HEADER =================
                Positioned(
                  top: 0,
                  left: 0,
                  child: Opacity(
                    opacity: showBankBrand ? 1 : 0,
                    child: Row(
                      children: [
                        BankLogo(
                          bankCid: bankCid,
                          size: bankLogoHeight,
                          width: bankLogoMaxWidth,
                        ),
                      ],
                    ),
                  ),
                ),

                // ================= NETWORK LOGO + TYPE =================
                Positioned(
                  top: 0,
                  right: 0,
                  child: Opacity(
                    opacity: showNetwork ? 1 : 0,
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
                    cardNumber: _buildMaskedCardNumber(cardNumber),
                    rawCardNumber: _buildMaskedCardNumber(cardNumber),
                    validThru: 'MM/YY',
                    holderName: 'CARD HOLDER',
                    cvv: '***',
                    showCvvToggle: false,
                    isCvvVisible: false,
                    onToggleCvv: () {},
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
