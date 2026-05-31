import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../constants/card_visuals.dart';
import '../../../constants/layout_constants.dart';
import '../../../models/card_network.dart';
import '../../../utils/adaptive_layout.dart';
import '../../../utils/card_number_format.dart';
import '../../bank/bank_logo.dart';
import '../card_details_block.dart';
import '../card_visual_asset_layer.dart';

class PreviewCard extends StatelessWidget {
  final GlobalKey? visualBoundaryKey;
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
    this.visualBoundaryKey,
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
    final assetPath = network?.assetPath;
    if (assetPath == null || assetPath.isEmpty) {
      return null;
    }
    return assetPath;
  }

  String _progressiveMaskedNumber(String digits) {
    return CardNumberFormat.progressiveMask(digits);
  }

  @override
  Widget build(BuildContext context) {
    final hasBank = bankCid != null;
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
        : hasBank
            ? CardVisuals.forBank(bankCid!)
            : CardVisuals.placeholder(isDark);
    final customImagePath = customCardImagePath?.trim();
    final customImageFile =
        customImagePath != null && customImagePath.isNotEmpty
            ? File(customImagePath)
            : null;
    final hasCustomImage =
        customImageFile != null && customImageFile.existsSync();
    final networkLogo = hasBank ? _networkAsset(cardNetwork) : null;
    final displayNumber = hasBank
        ? _progressiveMaskedNumber(cardNumber)
        : CardNumberFormat.standardTemplate;
    final displayExpiry = hasBank && expiry.isNotEmpty ? expiry : 'MM/YY';
    final displayName = hasBank && holderName.isNotEmpty
        ? holderName.toUpperCase()
        : 'CARD HOLDER';

    return AspectRatio(
      aspectRatio: cardAspectRatioWidth / cardAspectRatioHeight,
      child: LayoutBuilder(
        builder: (context, constraints) {
          const designWidth = AdaptiveLayout.phoneCardWidth;
          const designHeight =
              designWidth * (cardAspectRatioHeight / cardAspectRatioWidth);
          final bankLogoMaxWidth = bankLogoMaxWidthForCard(designWidth);
          final devicePixelRatio = MediaQuery.devicePixelRatioOf(context);
          final targetImageWidth =
              (constraints.maxWidth * devicePixelRatio).round();
          final customImage = hasCustomImage
              ? DecorationImage(
                  image: ResizeImage.resizeIfNeeded(
                    targetImageWidth,
                    null,
                    FileImage(customImageFile),
                  ),
                  fit: BoxFit.cover,
                  alignment: customCardImageAlignment,
                  filterQuality: FilterQuality.low,
                )
              : null;
          final borderRadius = BorderRadius.circular(cardBorderRadius);

          return Container(
            decoration: BoxDecoration(
              borderRadius: borderRadius,
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
                Positioned.fill(
                  child: RepaintBoundary(
                    key: visualBoundaryKey,
                    child: ClipRRect(
                      borderRadius: borderRadius,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: visual.gradient,
                          image: customImage,
                        ),
                        child: Stack(
                          children: [
                            if (customImage == null &&
                                visual.visualAssetPath != null)
                              Positioned.fill(
                                child: CardVisualAssetLayer(
                                  visual: visual,
                                  borderRadius: borderRadius,
                                ),
                              ),
                            Positioned.fill(
                              child: FittedBox(
                                fit: BoxFit.fill,
                                alignment: Alignment.topLeft,
                                child: SizedBox(
                                  width: designWidth,
                                  height: designHeight,
                                  child: Padding(
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
                                                  customLogoPath:
                                                      customBankLogoPath,
                                                  customLabel: customBankName,
                                                  useRuntimeFonts: false,
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
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                SvgPicture.asset(
                                                  networkLogo,
                                                  height: networkLogoHeight,
                                                ),
                                                if (cardType.isNotEmpty) ...[
                                                  const SizedBox(height: 5),
                                                  Text(
                                                    cardType,
                                                    textAlign: TextAlign.right,
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w500,
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
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: FittedBox(
                    fit: BoxFit.fill,
                    alignment: Alignment.topLeft,
                    child: SizedBox(
                      width: designWidth,
                      height: designHeight,
                      child: Padding(
                        padding: const EdgeInsets.all(cardPadding),
                        child: Stack(
                          children: [
                            Positioned(
                              left: 0,
                              bottom: detailsBottomOffset,
                              child: SizedBox(
                                width: designWidth - (cardPadding * 2),
                                child: CardDetailsBlock(
                                  cardNumber: displayNumber,
                                  rawCardNumber: displayNumber,
                                  validThru: displayExpiry,
                                  holderName: displayName,
                                  cvv: '***',
                                  showCvvToggle: false,
                                  isCvvVisible: false,
                                  onToggleCvv: () {},
                                ),
                              ),
                            ),
                            if (onEditVisualTap != null)
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: _PreviewCardActionButton(
                                  onTap: onEditVisualTap!,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
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
  static const String _assetPath = 'assets/icons/palette-swatch.svg';

  final VoidCallback onTap;

  const _PreviewCardActionButton({
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
        child: Center(
          child: SvgPicture.asset(
            _assetPath,
            width: 22,
            height: 22,
            colorFilter: const ColorFilter.mode(
              Colors.white,
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }
}
