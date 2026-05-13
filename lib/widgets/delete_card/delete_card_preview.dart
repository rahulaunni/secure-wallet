import 'package:flutter/material.dart';

import '../../constants/layout_constants.dart';
import '../../models/card_data.dart';
import '../../models/card_type.dart';
import '../../utils/adaptive_layout.dart';
import '../card/bank_card.dart';
import '../card/secure_reveal_wrapper.dart';

class DeleteCardPreview extends StatelessWidget {
  final CardData card;
  final bool isDark;

  const DeleteCardPreview({
    super.key,
    required this.card,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    const fullWidth = AdaptiveLayout.phoneCardWidth;
    const aspect = cardAspectRatioWidth / cardAspectRatioHeight;
    const fullHeight = fullWidth / aspect;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite
            ? constraints.maxWidth.clamp(0.0, fullWidth).toDouble()
            : fullWidth;
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
                    cardType:
                        card.cardType == CardType.credit ? 'Credit' : 'Debit',
                    cardNumber: card.cardNumber,
                    validThru: card.expiry,
                    holderName: card.holderName,
                    cvv: card.cvv,
                    customBankName: card.customBankName,
                    customBankLogoPath: card.customBankLogoPath,
                    customGradientStartColor:
                        card.customGradientStartColor != null
                            ? Color(card.customGradientStartColor!)
                            : null,
                    customGradientMiddleColor:
                        card.customGradientMiddleColor != null
                            ? Color(card.customGradientMiddleColor!)
                            : null,
                    customGradientEndColor: card.customGradientEndColor != null
                        ? Color(card.customGradientEndColor!)
                        : null,
                    customCardImagePath: card.customCardVisualMode == 1
                        ? card.customCardImagePath
                        : null,
                    customCardPatternAssetPath: card.customCardVisualMode == 0
                        ? card.customCardPatternAssetPath
                        : null,
                    customCardImageAlignment: Alignment(
                      card.customCardImageAlignmentX ?? 0,
                      card.customCardImageAlignmentY ?? 0,
                    ),
                    showActions: false,
                    onEyeTap: () {},
                    onShareTap: () {},
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
