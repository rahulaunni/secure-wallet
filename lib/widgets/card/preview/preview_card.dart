import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../constants/layout_constants.dart';
import '../../../constants/card_visuals.dart'; // ✅ Import Visual Engine
import '../../../models/card_network.dart';
import '../../../utils/card_number_format.dart';
import '../../bank/bank_logo.dart';
import '../card_visual_asset_layer.dart';
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
  final Color? customGradientMiddleColor;
  final Color? customGradientEndColor;
  final String? customCardImagePath;
  final Alignment customCardImageAlignment;
  final String? customCardPatternAssetPath;
  final VoidCallback? onEditVisualTap;

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
    this.customGradientMiddleColor,
    this.customGradientEndColor,
    this.customCardImagePath,
    this.customCardImageAlignment = Alignment.center,
    this.customCardPatternAssetPath,
    this.onEditVisualTap,
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
    final customMiddle = customGradientMiddleColor;
    final customEnd = customGradientEndColor;
    final CardVisual visual = customStart != null && customEnd != null
        ? CardVisuals.customGradient(
            customStart,
            customEnd,
            middle: customMiddle,
            visualAssetPath: customCardPatternAssetPath,
          )
        : hasBank
            ? CardVisuals.forBank(bankCid!)
            : CardVisuals.placeholder(isDark);
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
                            ],
                          ),
                        ),
                      if (networkLogo != null)
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Image.asset(
                                networkLogo,
                                height: networkLogoHeight,
                              ),
                              if (cardType.isNotEmpty) ...[
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
                            ],
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
                      if (onEditVisualTap != null)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: _PreviewCardActionButton(
                            icon: Icons.tune,
                            onTap: onEditVisualTap!,
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

class _PreviewCardActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _PreviewCardActionButton({
    required this.icon,
    required this.onTap,
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
