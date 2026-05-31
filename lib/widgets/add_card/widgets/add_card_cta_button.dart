import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:swallet/theme/swallet_theme.dart';
import 'package:swallet/widgets/add_card/add_card_material_tokens.dart';

class AddCardCTAButton extends StatelessWidget {
  final FutureOr<void> Function()? onPressed;
  final String label;
  final bool isLoading;

  const AddCardCTAButton({
    super.key,
    required this.onPressed,
    this.label = 'Add Card',
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tokens = AddCardMaterialTokens(isDark);
    final handlePress = onPressed == null || isLoading
        ? null
        : () {
            final result = onPressed!.call();
            if (result is Future<void>) {
              unawaited(result);
            }
          };

    return SizedBox(
      height: 56,
      width: double.infinity,
      child: FilledButton(
        onPressed: handlePress,
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
            if (isLoading) ...[
              SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  valueColor: AlwaysStoppedAnimation<Color>(tokens.onPrimary),
                ),
              ),
              const SizedBox(width: 10),
            ],
            Text(isLoading ? 'Saving...' : label),
            if (!isLoading) ...[
              const SizedBox(width: 8),
              const Icon(CupertinoIcons.arrow_right, size: 19),
            ],
          ],
        ),
      ),
    );
  }
}
