import 'package:flutter/material.dart';

// ================= LAYOUT =================

const double topNavHeight = 56;
const double topNavHorizontalPadding = 16;
const double topNavChipSpacing = 6;

// ================= CHIP =================

const double chipHeight = 48;
const double chipHorizontalPadding = 14;
const double chipIconSize = 18;
const double chipBorderWidth = 1;

// ================= ACTIVE DOT =================

// Size
const double chipDotSize = 6;

// Spacing between dot and label (when active)
const double chipDotSpacing = 8;

// Colors – Light theme
const Color chipDotColorLight = Color.fromARGB(255, 0, 231, 31); // on dark chip

// Colors – Dark theme
const Color chipDotColorDark = Color.fromARGB(255, 0, 90, 225); // on white chip

// ================= ANIMATION =================

const Duration chipAnimDuration = Duration(milliseconds: 260);
const Curve chipAnimCurve = Curves.easeInOutCubic;

// ================= LIGHT THEME (FILTER CHIPS) =================

const Color chipInactiveBgLight = Color.fromARGB(255, 251, 251, 251);
const Color chipInactiveStrokeLight = Color(0xFFE0E0E0);

const Color chipActiveBgLight = Color(0xFF111111);
const Color chipActiveStrokeLight = Color(0xFF111111);

// ================= DARK THEME (FILTER CHIPS) =================

const Color chipInactiveBgDark = Color(0xFF1E1E1E);
const Color chipInactiveStrokeDark = Color(0xFF2A2A2A);

const Color chipActiveBgDark = Color(0xFFFFFFFF);
const Color chipActiveStrokeDark = Color(0xFFFFFFFF);

// ================= ADD BUTTON (LIGHT THEME) =================

// Non-active
const Color addChipBgLight = Color.fromARGB(255, 251, 251, 251);
const Color addChipStrokeLight = Color(0xFFE0E0E0);
const Color addChipIconLight = Color(0xFF111111);

// Active (future use)
const Color addChipActiveBgLight = Color(0xFF111111);
const Color addChipActiveStrokeLight = Color(0xFF111111);
const Color addChipActiveIconLight = Color(0xFFFFFFFF);

// ================= ADD BUTTON (DARK THEME) =================

// Non-active
const Color addChipBgDark = Color(0xFF262626);
const Color addChipStrokeDark = Color(0xFF3A3A3A);
const Color addChipIconDark = Color(0xFFFFFFFF);

// Active (future use)
const Color addChipActiveBgDark = Color(0xFFFFFFFF);
const Color addChipActiveStrokeDark = Color(0xFFFFFFFF);
const Color addChipActiveIconDark = Color(0xFF000000);

// ================= SHADOWS =================

final List<BoxShadow> chipInactiveShadows = [
  BoxShadow(
    color: const Color.fromARGB(255, 34, 34, 34).withValues(alpha: 0.04),
    blurRadius: 3,
    offset: const Offset(0, 0),
  ),
];

final List<BoxShadow> chipActiveShadows = [
  BoxShadow(
    color: Colors.black.withValues(alpha: 0.08),
    blurRadius: 6,
    offset: const Offset(0, 0),
  ),
];
