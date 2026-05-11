import 'package:flutter/material.dart';
import 'package:swallet/theme/swallet_theme.dart';

class AddCardMaterialTokens {
  final bool isDark;

  const AddCardMaterialTokens(this.isDark);

  SwalletPalette get _palette => SwalletPalette(isDark);

  Color get primary => _palette.primary;
  Color get onPrimary => _palette.onPrimary;
  Color get primaryContainer =>
      isDark ? _palette.primaryContainer : const Color(0xFFE8EEFF);
  Color get onPrimaryContainer =>
      isDark ? _palette.onPrimaryContainer : const Color(0xFF1A3F99);
  Color get segmentedSelected =>
      isDark ? _palette.primaryContainer : const Color(0xFF2F6BFF);
  Color get onSegmentedSelected =>
      isDark ? _palette.onPrimaryContainer : Colors.white;

  Color get surface => isDark ? _palette.background : const Color(0xFFF5F5F5);
  Color get surfaceContainer =>
      isDark ? _palette.surfaceLow : const Color(0xFFEDEDED);
  Color get surfaceContainerHigh =>
      isDark ? const Color(0xFF141414) : const Color(0xFFE8E8E8);
  Color get surfaceContainerHighest =>
      isDark ? _palette.surfaceHigh : const Color(0xFFE5E5E5);
  Color get onSurface => _palette.text;
  Color get onSurfaceVariant =>
      isDark ? _palette.textMuted : const Color(0xFF9A9DA5);
  Color get outline => isDark ? _palette.textMuted : const Color(0xFF9A9DA5);
  Color get outlineVariant =>
      isDark ? _palette.outline : const Color(0xFFDADADA);

  Color get scrim => Colors.black.withValues(alpha: isDark ? 0.40 : 0.15);

  BorderRadius get containerRadius => BorderRadius.circular(32);
  BorderRadius get controlRadius => BorderRadius.circular(16);
  BorderRadius get pillRadius => BorderRadius.circular(14);
}
