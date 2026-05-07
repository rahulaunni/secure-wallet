import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../constants/layout_constants.dart';
import '../../../constants/card_visuals.dart'; // ✅ Import Visual Engine
import '../../../models/card_network.dart';
import '../../../utils/card_number_format.dart';
import '../../bank/bank_logo.dart';
import '../card_details_block.dart';

class PreviewCard extends StatelessWidget {
  final String? bankCid;
  final bool isDark;

  final String cardNumber;
  final String expiry;
  final String holderName;
  final CardNetwork? cardNetwork;
  final String? customBankName;
  final String? customBankLogoPath;
  final Color? customGradientStartColor;
  final Color? customGradientEndColor;

  final String cardType;

  const PreviewCard({
    super.key,
    required this.bankCid,
    required this.isDark,
    required this.cardNumber,
    required this.expiry,
    required this.holderName,
    required this.cardNetwork,
    this.customBankName,
    this.customBankLogoPath,
    this.customGradientStartColor,
    this.customGradientEndColor,
    this.cardType = '',
  });

  String? _networkAsset(CardNetwork? network) {
    switch (network) {
      case CardNetwork.visa:
        return 'assets/images/networks/visa.png';
      case CardNetwork.mastercard:
        return 'assets/images/networks/mastercard.png';
      case CardNetwork.rupay:
        return 'assets/images/networks/rupay.png';
      case CardNetwork.amex:
        return 'assets/images/networks/amex.png';
      default:
        return null;
    }
  }

  // 🔒 Progressive star replacement
  String _progressiveMaskedNumber(String digits) {
    return CardNumberFormat.progressiveMask(digits);
  }

  @override
  Widget build(BuildContext context) {
    final bool hasBank = bankCid != null;

    // ✅ RESOLVE VISUALS (Gradient + Pattern)
    // Matches the logic used in BankCard
    final customStart = customGradientStartColor;
    final customEnd = customGradientEndColor;
    final CardVisual visual = customStart != null && customEnd != null
        ? CardVisuals.customGradient(customStart, customEnd)
        : hasBank
            ? CardVisuals.forBank(bankCid!)
            : CardVisuals.placeholder(isDark);

    final String? networkLogo = hasBank ? _networkAsset(cardNetwork) : null;

    // 🔒 ALWAYS SHOW STARS ON BANK SELECTION
    final String displayNumber = hasBank
        ? _progressiveMaskedNumber(cardNumber)
        : CardNumberFormat.standardTemplate;

    final String displayExpiry =
        hasBank && expiry.isNotEmpty ? expiry : 'MM/YY';

    final String displayName = hasBank && holderName.isNotEmpty
        ? holderName.toUpperCase()
        : 'CARD HOLDER';

    return AspectRatio(
      aspectRatio: cardAspectRatioWidth / cardAspectRatioHeight,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bankLogoMaxWidth =
              bankLogoMaxWidthForCard(constraints.maxWidth);

          return Container(
            padding: EdgeInsets.zero, // Padding is handled inside the Stack
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
                Padding(
                  padding: const EdgeInsets.all(cardPadding),
                  child: Stack(
                    children: [
                      if (hasBank)
                        Positioned(
                          top: 0,
                          left: 0,
                          child: Row(
                            children: [
                              BankLogo(
                                bankCid: bankCid!,
                                size: bankLogoHeight,
                                width: bankLogoMaxWidth,
                                customLogoPath: customBankLogoPath,
                                customLabel: customBankName,
                              ),
                              if (cardType.isNotEmpty) ...[
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
                            ],
                          ),
                        ),
                      if (networkLogo != null)
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Image.asset(
                            networkLogo,
                            height: networkLogoHeight,
                          ),
                        ),
                      Positioned(
                        top: chipTopOffset,
                        left: 0,
                        child: SvgPicture.asset(
                          'assets/images/chip.svg',
                          width: chipWidth,
                        ),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: detailsBottomOffset,
                        child: CardDetailsBlock(
                          cardNumber: displayNumber,
                          rawCardNumber:
                              displayNumber, // ✅ Satisfy required param
                          validThru: displayExpiry,
                          holderName: displayName,
                          cvv: '***',
                          showCvvToggle: false,
                          isCvvVisible: false,
                          onToggleCvv: () {},
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
