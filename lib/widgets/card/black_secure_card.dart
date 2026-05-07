import 'package:flutter/material.dart';

import '../../constants/layout_constants.dart';
import '../../theme/swallet_theme.dart';

class BlackSecureCard extends StatelessWidget {
  final int remainingSeconds;

  const BlackSecureCard({
    super.key,
    required this.remainingSeconds,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final palette = SwalletPalette(isDark);

    return Container(
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(blackCardBorderRadius),
        border: Border.all(
          color: palette.outline.withValues(alpha: 0.64),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SizedBox(
              height: secureRevealBarHeight,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Text(
                    'Securely locking in 00:${remainingSeconds.toString().padLeft(2, '0')}s',
                    style: secureRevealTextStyle.copyWith(
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      color: palette.text,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
