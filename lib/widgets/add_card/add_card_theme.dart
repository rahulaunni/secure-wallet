import 'package:flutter/material.dart';
import 'package:swallet/theme/swallet_theme.dart';

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
    return SwalletPalette(_isDark(context)).surfaceLow;
  }

  /// Press / tap overlay (NEW, CANONICAL)
  static Color bankTileOverlay(BuildContext context) {
    return SwalletPalette(_isDark(context)).primary.withValues(alpha: 0.08);
  }

  /// 🔁 BACKWARD COMPAT (old name)
  static Color bankTileOverlayColor(BuildContext context) {
    return bankTileOverlay(context);
  }

  /// Tile stroke / border
  static Color bankTileStroke(BuildContext context) {
    return SwalletPalette(_isDark(context)).outline;
  }

  /// Bank name under logo (NEW)
  static Color bankNameText(BuildContext context) {
    return SwalletPalette(_isDark(context)).textMuted;
  }

  // ============================================================
  // SECTION SURFACE
  // ============================================================

  static Color sectionBackground(BuildContext context) {
    return SwalletPalette(_isDark(context)).surface;
  }

  static Color handleColor(BuildContext context) {
    return SwalletPalette(_isDark(context)).outline.withValues(alpha: 0.72);
  }

  // ============================================================
  // TITLES / ACTIONS
  // ============================================================

  /// "Select Bank" title
  static Color selectBankTitle(BuildContext context) {
    return SwalletPalette(_isDark(context)).text;
  }

  /// Secondary action (e.g. see more)
  static Color secondaryAction(BuildContext context) {
    return Theme.of(context).colorScheme.primary;
  }
}
