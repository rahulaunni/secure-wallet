class AddCardLayoutConstants {
  // ============================================================
  // GRID LAYOUT
  // ============================================================

  static const int bankGridColumns = 4;
  static const double bankGridSpacing = 4;
  static const double bankGridRunSpacing = 12;
  static const double bankGridAspectRatio = 0.78;

  // ============================================================
  // BANK BUTTON (LOGO TILE)
  // ============================================================

  /// Square button size
  static const double bankButtonSize = 64;

  /// Button corner radius (circular)
  static const double bankButtonRadius = 32;

  /// Space between button and bank name
  static const double bankNameSpacing = 6;

  // ============================================================
  // BANK ICON
  // ============================================================

  /// Logo size inside button
  static const double bankIconSize = 32;

  // ============================================================
  // BUTTON STROKE
  // ============================================================

  /// Border width for bank button
  static const double buttonStrokeWidth = 1.5;

  // ============================================================
  // BANK SECTION LAYOUT
  // ============================================================

  /// Height factor relative to screen height
  static const double bankSectionHeightFactor = 0.60;

  /// Absolute minimum height safeguard
  static const double bankSectionMinHeight = 320;

  /// Container radius (matches form section)
  static const double sectionRadius = 40;

  /// Inner padding of section container
  static const double sectionPadding = 16;

  /// Bottom spacing from screen
  static const double sectionBottomInset = 16;

  /// Gap between preview card and section
  static const double previewToSectionGap = 40;
}
