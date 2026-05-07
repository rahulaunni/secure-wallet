import 'package:flutter/material.dart';
import 'package:swallet/theme/swallet_theme.dart';

class AddCardMaterialTokens {
  final bool isDark;

  const AddCardMaterialTokens(this.isDark);

  SwalletPalette get _palette => SwalletPalette(isDark);

  Color get primary => _palette.primary;
  Color get onPrimary => _palette.onPrimary;
  Color get primaryContainer => _palette.primaryContainer;
  Color get onPrimaryContainer => _palette.onPrimaryContainer;

  Color get surface => _palette.background;
  Color get surfaceContainer => _palette.surfaceLow;
  Color get surfaceContainerHigh =>
      isDark ? const Color(0xFF141414) : const Color(0xFFEAEAEA);
  Color get surfaceContainerHighest => _palette.surfaceHigh;
  Color get onSurface => _palette.text;
  Color get onSurfaceVariant => _palette.textMuted;
  Color get outline => _palette.textMuted;
  Color get outlineVariant => _palette.outline;

  Color get scrim => Colors.black.withValues(alpha: isDark ? 0.40 : 0.15);

  BorderRadius get containerRadius => BorderRadius.circular(32);
  BorderRadius get controlRadius => BorderRadius.circular(16);
  BorderRadius get pillRadius => BorderRadius.circular(14);
}
