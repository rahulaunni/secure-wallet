import 'package:flutter/material.dart';

class AddCardTheme {
  // ============================================================
  // INTERNAL
  // ============================================================

  static bool _isDark(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  // ============================================================
  // BANK TILE (LOGO TILE)
  // ============================================================

  /// Background behind bank logo
  static Color bankTileBackground(BuildContext context) {
    return _isDark(context)
        ? const Color.fromARGB(255, 0, 0, 0)
        : const Color.fromARGB(255, 255, 255, 255);
  }

  /// Press / tap overlay (NEW, CANONICAL)
  static Color bankTileOverlay(BuildContext context) {
    return _isDark(context)
        ? const Color.fromARGB(28, 255, 255, 255)
        : const Color.fromARGB(19, 255, 255, 255);
  }

  /// 🔁 BACKWARD COMPAT (old name)
  static Color bankTileOverlayColor(BuildContext context) {
    return bankTileOverlay(context);
  }

  /// Tile stroke / border
  static Color bankTileStroke(BuildContext context) {
    return _isDark(context)
        ? const Color.fromARGB(255, 255, 255, 255)
        : const Color.fromARGB(255, 255, 255, 255);
  }

  /// Bank name under logo (NEW)
  static Color bankNameText(BuildContext context) {
    return _isDark(context)
        ? Colors.white70
        : const Color.fromARGB(221, 255, 255, 255);
  }

  // ============================================================
  // SECTION SURFACE
  // ============================================================

  static Color sectionBackground(BuildContext context) {
    return _isDark(context)
        ? const Color(0xFF1C1C1E)
        : const Color.fromARGB(255, 0, 0, 0);
  }

  static Color handleColor(BuildContext context) {
    return _isDark(context)
        ? Colors.white.withValues(alpha: 0.18)
        : const Color.fromARGB(255, 255, 255, 255).withValues(alpha: 0.12);
  }

  // ============================================================
  // TITLES / ACTIONS
  // ============================================================

  /// "Select Bank" title
  static Color selectBankTitle(BuildContext context) {
    return _isDark(context)
        ? const Color.fromARGB(255, 9, 9, 9).withValues(alpha: 0.9)
        : const Color.fromARGB(255, 7, 7, 7);
  }

  /// Secondary action (e.g. see more)
  static Color secondaryAction(BuildContext context) {
    return Theme.of(context).colorScheme.primary;
  }
}
