import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:swallet/theme/swallet_theme.dart';
import 'package:swallet/widgets/add_card/add_card_material_tokens.dart';

class AddCardCTAButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;

  const AddCardCTAButton({
    super.key,
    required this.onPressed,
    this.label = 'Add Card',
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tokens = AddCardMaterialTokens(isDark);

    return SizedBox(
      height: 56,
      width: double.infinity,
      child: FilledButton(
        onPressed: onPressed,
        style: ButtonStyle(
          elevation: WidgetStateProperty.resolveWith((states) {
            return states.contains(WidgetState.pressed) ? 0 : 1;
          }),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            return states.contains(WidgetState.pressed)
                ? tokens.primary.withValues(alpha: 0.88)
                : tokens.primary;
          }),
          foregroundColor: WidgetStatePropertyAll(tokens.onPrimary),
          overlayColor: WidgetStatePropertyAll(
            tokens.onPrimary.withValues(alpha: 0.10),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: tokens.pillRadius),
          ),
          textStyle: WidgetStatePropertyAll(SwalletText.button),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label),
            const SizedBox(width: 8),
            const Icon(CupertinoIcons.arrow_right, size: 19),
          ],
        ),
      ),
    );
  }
}
