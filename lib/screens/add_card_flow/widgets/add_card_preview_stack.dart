import 'package:flutter/material.dart';

import 'package:swallet/widgets/card/preview/preview_card.dart';
import 'package:swallet/models/card_type.dart';
import 'package:swallet/models/card_network.dart';

class AddCardPreviewStack extends StatelessWidget {
  final double top;
  final EdgeInsets horizontalInsets;
  final bool isDark;

  final String? bankCid;
  final bool isBankSelected;

  final String cardNumber;
  final String expiry;
  final String holderName;
  final CardNetwork? cardNetwork;
  final CardType cardType;
  final String? customBankName;
  final String? customBankLogoPath;
  final Color? customGradientStartColor;
  final Color? customGradientEndColor;
  final String? customCardImagePath;
  final Alignment customCardImageAlignment;
  final String? customCardPatternAssetPath;
  final VoidCallback? onEditVisualTap;

  // ❌ REMOVED: final VoidCallback onChangeBank;

  /// Purely visual scale (layout-safe)
  final double scale;

  const AddCardPreviewStack({
    super.key,
    required this.top,
    this.horizontalInsets = const EdgeInsets.symmetric(horizontal: 16),
    required this.isDark,
    required this.bankCid,
    required this.isBankSelected,
    required this.cardNumber,
    required this.expiry,
    required this.holderName,
    required this.cardNetwork,
    required this.cardType,
    this.customBankName,
    this.customBankLogoPath,
    this.customGradientStartColor,
    this.customGradientEndColor,
    this.customCardImagePath,
    this.customCardImageAlignment = Alignment.center,
    this.customCardPatternAssetPath,
    this.onEditVisualTap,
    // ❌ REMOVED: required this.onChangeBank,
    this.scale = 1.0,
  });

  // ===== FINAL POLISH CONSTANTS =====
  static const Duration _scaleDuration = Duration(milliseconds: 60);
  static const Curve _scaleCurve = Curves.easeInOut;
  // =================================

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: horizontalInsets.left,
      right: horizontalInsets.right,
      child: AnimatedScale(
        scale: scale,
        duration: _scaleDuration,
        curve: _scaleCurve,
        alignment: Alignment.topCenter,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PreviewCard(
              bankCid: bankCid,
              isDark: isDark,
              cardNumber: cardNumber,
              expiry: expiry,
              holderName: holderName,
              cardNetwork: cardNetwork,
              cardType: cardType == CardType.credit ? 'Credit' : 'Debit',
              customBankName: customBankName,
              customBankLogoPath: customBankLogoPath,
              customGradientStartColor: customGradientStartColor,
              customGradientEndColor: customGradientEndColor,
              customCardImagePath: customCardImagePath,
              customCardImageAlignment: customCardImageAlignment,
              customCardPatternAssetPath: customCardPatternAssetPath,
              onEditVisualTap: onEditVisualTap,
            ),

            // ❌ REMOVED: The entire "Change Bank" button block
          ],
        ),
      ),
    );
  }
}
