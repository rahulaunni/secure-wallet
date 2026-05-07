import 'package:flutter/material.dart';

class AddCardMaterialTokens {
  final bool isDark;

  const AddCardMaterialTokens(this.isDark);

  Color get primary =>
      isDark ? const Color(0xFFADC6FF) : const Color(0xFF315DA8);
  Color get onPrimary => isDark ? const Color(0xFF082F6F) : Colors.white;
  Color get primaryContainer =>
      isDark ? const Color(0xFF244B8F) : const Color(0xFFD7E2FF);
  Color get onPrimaryContainer =>
      isDark ? const Color(0xFFD7E2FF) : const Color(0xFF001B3F);

  Color get surface =>
      isDark ? const Color(0xFF111318) : const Color(0xFFFCFBFF);
  Color get surfaceContainer =>
      isDark ? const Color(0xFF1B1B20) : const Color(0xFFF1F3F9);
  Color get surfaceContainerHigh =>
      isDark ? const Color(0xFF25262C) : const Color(0xFFE9ECF4);
  Color get surfaceContainerHighest =>
      isDark ? const Color(0xFF303138) : const Color(0xFFE2E6EF);
  Color get onSurface =>
      isDark ? const Color(0xFFE4E2E9) : const Color(0xFF1B1B20);
  Color get onSurfaceVariant =>
      isDark ? const Color(0xFFC5C6D0) : const Color(0xFF45464F);
  Color get outline =>
      isDark ? const Color(0xFF8F909A) : const Color(0xFF747780);
  Color get outlineVariant =>
      isDark ? const Color(0xFF45464F) : const Color(0xFFC5C6D0);

  Color get scrim => Colors.black.withValues(alpha: isDark ? 0.36 : 0.08);

  BorderRadius get containerRadius => BorderRadius.circular(28);
  BorderRadius get controlRadius => BorderRadius.circular(18);
  BorderRadius get pillRadius => BorderRadius.circular(999);
}
