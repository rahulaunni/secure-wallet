import 'package:flutter/material.dart';

import 'package:swallet/screens/add_card_flow/constants/add_card_layout_constants.dart';
import 'package:swallet/widgets/add_card/add_card_material_tokens.dart';

class BankSelectionContainer extends StatelessWidget {
  final Widget child;

  const BankSelectionContainer({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tokens = AddCardMaterialTokens(isDark);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: tokens.containerRadius,
        border: Border.all(
          color: tokens.outlineVariant.withValues(alpha: isDark ? 0.24 : 0.55),
        ),
        boxShadow: [
          BoxShadow(
            color: tokens.scrim,
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AddCardLayoutConstants.sectionPadding),
        child: child,
      ),
    );
  }
}
