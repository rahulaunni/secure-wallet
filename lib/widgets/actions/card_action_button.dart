import 'package:flutter/material.dart';

import 'package:swallet/theme/swallet_theme.dart';

class CardActionButton extends StatelessWidget {
  final IconData icon;
  final bool isDark;
  final bool destructive;
  final VoidCallback? onTap;

  const CardActionButton({
    super.key,
    required this.icon,
    required this.isDark,
    this.destructive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final palette = SwalletPalette(isDark);
    final Color background = destructive
        ? SwalletColors.destructive.withValues(alpha: isDark ? 0.20 : 0.10)
        : (isDark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.black.withValues(alpha: 0.06));
    final Color foreground =
        destructive ? SwalletColors.destructive : palette.text;

    return Material(
      color: background,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: 52,
          height: 52,
          decoration: const BoxDecoration(shape: BoxShape.circle),
          child: Icon(
            icon,
            size: 20,
            color: foreground,
          ),
        ),
      ),
    );
  }
}
