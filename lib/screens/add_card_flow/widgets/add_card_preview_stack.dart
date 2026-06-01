import 'package:flutter/material.dart';

import '../../../models/card_network.dart';
import '../../../models/card_type.dart';
import 'package:swallet/widgets/card/preview/preview_card.dart';

class AddCardPreviewStack extends StatelessWidget {
  final GlobalKey? visualBoundaryKey;
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
  final Color? customGradientMiddleColor;
  final Color? customGradientEndColor;
  final String? customCardImagePath;
  final Alignment customCardImageAlignment;
  final String? customCardPatternAssetPath;
  final VoidCallback? onEditVisualTap;
  final bool showSavingOverlay;

  final double scale;
  final double offsetY;

  const AddCardPreviewStack({
    super.key,
    this.visualBoundaryKey,
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
    this.customGradientMiddleColor,
    this.customGradientEndColor,
    this.customCardImagePath,
    this.customCardImageAlignment = Alignment.center,
    this.customCardPatternAssetPath,
    this.onEditVisualTap,
    this.showSavingOverlay = false,
    this.scale = 1.0,
    this.offsetY = 0.0,
  });

  static const Duration _scaleDuration = Duration(milliseconds: 60);
  static const Curve _scaleCurve = Curves.easeInOut;
  static const Duration _exitDuration = Duration(milliseconds: 980);
  static const Curve _exitCurve = Curves.easeOutCubic;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: horizontalInsets.left,
      right: horizontalInsets.right,
      child: AnimatedContainer(
        duration: _exitDuration,
        curve: _exitCurve,
        transform: Matrix4.translationValues(0, offsetY, 0),
        child: AnimatedScale(
          scale: scale,
          duration: _scaleDuration,
          curve: _scaleCurve,
          alignment: Alignment.topCenter,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                children: [
                  PreviewCard(
                    visualBoundaryKey: visualBoundaryKey,
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
                    customGradientMiddleColor: customGradientMiddleColor,
                    customGradientEndColor: customGradientEndColor,
                    customCardImagePath: customCardImagePath,
                    customCardImageAlignment: customCardImageAlignment,
                    customCardPatternAssetPath: customCardPatternAssetPath,
                    onEditVisualTap: onEditVisualTap,
                  ),
                  if (showSavingOverlay)
                    const Positioned.fill(
                      child: IgnorePointer(
                        child: _PreviewSavingOverlay(),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PreviewSavingOverlay extends StatelessWidget {
  const _PreviewSavingOverlay();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Center(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.42),
            borderRadius: BorderRadius.circular(999),
          ),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                SizedBox(width: 10),
                Text(
                  'Saving card',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
