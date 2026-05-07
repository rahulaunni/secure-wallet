import 'package:flutter/material.dart';
import 'imported_card_gradients.dart';
import '../utils/bank_asset_resolver.dart';
import '../widgets/card/bank_pattern_painter.dart';

class CardVisual {
  final Gradient gradient;
  final String? bankLogo;
  final CustomPainter? patternPainter;

  const CardVisual({
    required this.gradient,
    this.bankLogo,
    this.patternPainter,
  });
}

class CardVisuals {
  static CardVisual customGradient(Color start, Color end) {
    return CardVisual(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [start, end],
      ),
    );
  }

  /* -------------------------------------------------------------------------- */
  /*                              BANK GRADIENTS                                 */
  /* -------------------------------------------------------------------------- */

  static const Map<String, List<Color>> _bankGradients = {
    'axis': [Color(0xFF861F41), Color(0xFF63152E)],
    'bandhan': [Color(0xFF002A54), Color(0xFFC59F58)],
    'csb': [Color(0xFFE94E1B), Color(0xFFB03209)],
    'citibank': [Color(0xFF003B70), Color(0xFF005B9A)],
    'city_union': [Color(0xFF7A1521), Color(0xFF520E16)],
    'dcb': [Color(0xFF14243E), Color(0xFF2A4B7C)],
    'dhanlaxmi': [Color(0xFF4B1858), Color(0xFF7A278F)],
    'federal': [Color(0xFF555EFF), Color(0xFF030262)],
    'hdfc': [Color(0xFF002D55), Color(0xFF004C8F)],
    'icici': [Color(0xFFF37E20), Color(0xFFB02A30)],
    'indusind': [Color(0xFF4A2C2A), Color(0xFF8B4513)],
    'idfc': [Color(0xFF9D2235), Color(0xFF5A121E)],
    'karnataka': [Color(0xFF231F20), Color(0xFFDA291C)],
    'kotak': [Color(0xFFEE1C25), Color(0xFF9B0A11)],
    'rbl': [Color(0xFF000000), Color(0xFF0058A3)],
    'south_indian': [Color(0xFFDA251C), Color(0xFFFFA000)],
    'yes': [Color(0xFF005A9C), Color(0xFF00A0E3)],
    'idbi': [Color(0xFF00796B), Color(0xFF004D40)],
    'indian_bank': [Color(0xFF005BAC), Color(0xFFF4B000)],
    'karur_vysya': [Color(0xFF00529B), Color(0xFFD71920)],
    'standard_chartered': [Color(0xFF005A32), Color(0xFF00331D)],
    'bank_of_baroda': [Color(0xFFF26522), Color(0xFFF58220)],
    'bank_of_india': [Color(0xFF0077CC), Color(0xFF005FA3)],
    'canara': [Color(0xFF0091D2), Color(0xFF00609C)],
    'central_bank': [Color(0xFF004A8F), Color(0xFF003366)],
    'indian_overseas': [Color(0xFF0083CA), Color(0xFF005B9A)],
    'punjab_national_bank': [Color(0xFFA20E37), Color(0xFF700824)],
    'sbi': [Color(0xFF280071), Color(0xFF00A5E6)],
    'uco': [Color(0xFF1565C0), Color(0xFF0D47A1)],
    'union': [Color(0xFFE31E24), Color(0xFF1D4E9E)],
    'au_small_finance': [Color(0xFF662D91), Color(0xFFF26522)],
    'tmb': [Color(0xFF673AB7), Color(0xFF9C27B0)],
    'jammu_kashmir': [Color(0xFF006837), Color(0xFF004525)],
    'punjab_sind': [Color(0xFFFFD700), Color(0xFFC5A000)],
    'bank_of_maharashtra': [Color(0xFFFFC107), Color(0xFFFF9800)],
  };

  static const Map<String, List<Color>> _countryGradients = {
    'argentina': [Color(0xFF1D4ED8), Color(0xFF38BDF8)],
    'australia': [Color(0xFF0F766E), Color(0xFF0369A1)],
    'austria': [Color(0xFFB91C1C), Color(0xFF7F1D1D)],
    'belgium': [Color(0xFF111827), Color(0xFFF59E0B)],
    'brazil': [Color(0xFF047857), Color(0xFFF59E0B)],
    'canada': [Color(0xFFB91C1C), Color(0xFF111827)],
    'chile': [Color(0xFF1D4ED8), Color(0xFFDC2626)],
    'china': [Color(0xFFB91C1C), Color(0xFFF59E0B)],
    'colombia': [Color(0xFFF59E0B), Color(0xFF1D4ED8)],
    'czech_republic': [Color(0xFF1D4ED8), Color(0xFFDC2626)],
    'denmark': [Color(0xFFDC2626), Color(0xFF991B1B)],
    'egypt': [Color(0xFF111827), Color(0xFFB91C1C)],
    'finland': [Color(0xFF1E3A8A), Color(0xFF2563EB)],
    'france': [Color(0xFF1D4ED8), Color(0xFFDC2626)],
    'germany': [Color(0xFF111827), Color(0xFFF59E0B)],
    'greece': [Color(0xFF2563EB), Color(0xFF0F172A)],
    'hungary': [Color(0xFF047857), Color(0xFFB91C1C)],
    'indonesia': [Color(0xFFDC2626), Color(0xFF7F1D1D)],
    'ireland': [Color(0xFF047857), Color(0xFFF97316)],
    'israel': [Color(0xFF1D4ED8), Color(0xFF0F172A)],
    'italy': [Color(0xFF047857), Color(0xFFDC2626)],
    'japan': [Color(0xFFB91C1C), Color(0xFF111827)],
    'kenya': [Color(0xFF111827), Color(0xFF047857)],
    'malaysia': [Color(0xFF1D4ED8), Color(0xFFDC2626)],
    'mexico': [Color(0xFF047857), Color(0xFFDC2626)],
    'morocco': [Color(0xFFB91C1C), Color(0xFF047857)],
    'netherlands': [Color(0xFFF97316), Color(0xFF1D4ED8)],
    'new_zealand': [Color(0xFF0F172A), Color(0xFF2563EB)],
    'nigeria': [Color(0xFF047857), Color(0xFF111827)],
    'norway': [Color(0xFF1D4ED8), Color(0xFFDC2626)],
    'oman': [Color(0xFF047857), Color(0xFFB91C1C)],
    'pakistan': [Color(0xFF047857), Color(0xFF065F46)],
    'peru': [Color(0xFFB91C1C), Color(0xFF7F1D1D)],
    'philippines': [Color(0xFF1D4ED8), Color(0xFFDC2626)],
    'poland': [Color(0xFFDC2626), Color(0xFF991B1B)],
    'portugal': [Color(0xFF047857), Color(0xFFB91C1C)],
    'qatar': [Color(0xFF7F1D4F), Color(0xFF4C102F)],
    'saudi_arabia': [Color(0xFF047857), Color(0xFF065F46)],
    'singapore': [Color(0xFFDC2626), Color(0xFF111827)],
    'south_africa': [Color(0xFF047857), Color(0xFFF59E0B)],
    'south_korea': [Color(0xFF1D4ED8), Color(0xFFDC2626)],
    'spain': [Color(0xFFDC2626), Color(0xFFF59E0B)],
    'sweden': [Color(0xFF1D4ED8), Color(0xFFF59E0B)],
    'switzerland': [Color(0xFFDC2626), Color(0xFF991B1B)],
    'thailand': [Color(0xFF1D4ED8), Color(0xFFDC2626)],
    'turkey': [Color(0xFFDC2626), Color(0xFF7F1D1D)],
    'uae': [Color(0xFF047857), Color(0xFF111827)],
    'united_kingdom': [Color(0xFF1D4ED8), Color(0xFFDC2626)],
    'united_states': [Color(0xFF1D4ED8), Color(0xFFB91C1C)],
    'vietnam': [Color(0xFFDC2626), Color(0xFFF59E0B)],
  };

  /* -------------------------------------------------------------------------- */
  /*                         HIGHLIGHT OVERRIDES (LOCKED)                        */
  /* -------------------------------------------------------------------------- */

  static const Map<String, Color> _bankHighlightOverrides = {
    // Pattern 1 — Dual Circles (top-right / bottom-right)
    'axis': Color(0xFF3C0414),
    'rbl': Color(0xFF010F2A),
    'bandhan': Color(0xFF9A96A0),
    'idbi': Color(0xFFD6DBA3),

    // Pattern 2 — Quad Circles (top-left)
    'icici': Color(0xFFFFB37A),
    'kotak': Color(0xFFFF9A9A),
    'union': Color(0xFFFF9E9E),
    'au_small_finance': Color(0xFFD6A3FF),

    // Pattern 3 — Intersecting Rectangles
    'sbi': Color(0xFFB08CFF),
    'bank_of_baroda': Color(0xFFFFB28E),
    'south_indian': Color(0xFFFFC76A),

    // Pattern 4 — Concentric Arcs
    'yes': Color(0xFF6097C7),
    'dhanlaxmi': Color(0xFFAA45A3),
    'indusind': Color(0xFF755433),
    'karnataka': Color(0xFF943B3B),

    // Pattern 5 — Right Dual Circles
    'dcb': Color(0xFF5C7CA8),
    'canara': Color(0xFF52C8FF),
    'tmb': Color(0xFF2D0134),
    'jammu_kashmir': Color(0xFF19DB81),

    // Pattern 6 — Angled Tiles
    'federal': Color(0xFF6E78FF),
    'citibank': Color(0xFF78B4FF),
    'uco': Color.fromARGB(255, 1, 16, 64),
    'hdfc': Color.fromARGB(255, 106, 181, 255),
  };

  static Color _highlight(String cid, List<Color> g) {
    return _bankHighlightOverrides[cid] ??
        Color.lerp(g.first, const Color(0xFF1E1E1E), 0.6)!;
  }

  /* -------------------------------------------------------------------------- */
  /*                           PATTERN CONFIGS                                   */
  /* -------------------------------------------------------------------------- */

  static DualCircleConfig _dual(Color h) => DualCircleConfig(
        bigCenter: const Offset(1.0, -0.3),
        bigRadius: 0.65,
        bigColor: h,
        bigOpacity: 0.55,
        smallCenter: const Offset(0.0, 1.25),
        smallRadius: 0.45,
        smallColor: h,
        smallOpacity: 0.25,
      );

  static QuadCircleConfig _quad(Color h) => QuadCircleConfig(
        center: const Offset(-0.1, -0.1),
        radii: const [0.45, 0.60, 0.75, 0.90],
        opacities: const [0.16, 0.16, 0.10, 0.06],
        color: h,
      );

  static IntersectRectConfig _rect(Color h) => IntersectRectConfig(
        leftOffset: const Offset(-0.25, 0.0),
        rightOffset: const Offset(0.50, 0.50),
        rectWidth: 0.75,
        rectHeight: 0.50,
        color: h,
        leftOpacity: 0.18,
        rightOpacity: 0.14,
      );

  static ConcentricArcConfig _arcs(Color h) => ConcentricArcConfig(
        center: const Offset(-0.10, -0.05),
        ringCount: 40,
        startRadius: 0.15,
        gap: 0.025,
        strokeWidth: 1.5,
        color: h,
        startOpacity: 0.50,
        opacityStep: 0.012,
      );

  static RightDualCircleConfig _rightDual(Color h) => RightDualCircleConfig(
        primaryCenter: const Offset(0.95, 0.50),
        primaryRadius: 0.40,
        primaryOpacity: 0.25,
        secondaryCenter: const Offset(0.925, 0.70),
        secondaryRadius: 0.30,
        secondaryOpacity: 0.20,
        color: h,
      );

  static AngledTileRectConfig _angledTiles(Color h) => AngledTileRectConfig(
        center: const Offset(0.5, 0.5),
        height: 2,
        widths: const [0.30, 0.30, 0.30, 0.30],
        opacities: const [0.35, 0.25, 0.15, 0.10],
        angle: -0.28,
        color: h,
      );

  /* -------------------------------------------------------------------------- */
  /*                               RESOLVER                                      */
  /* -------------------------------------------------------------------------- */

  static CardVisual forBank(String cid) {
    final resolved = BankAssetResolver.resolveCid(cid);
    final colors = _colorsForBank(cid, resolved);
    if (colors == null) return placeholder(false);

    final h = _highlight(resolved, colors);
    CustomPainter? painter;

    if (['axis', 'rbl', 'bandhan', 'idbi'].contains(resolved)) {
      painter = BankPatternPainter.dual(dualConfig: _dual(h));
    } else if ([
      'icici',
      'kotak',
      'union',
      'au_small_finance',
    ].contains(resolved)) {
      painter = BankPatternPainter.quad(quadConfig: _quad(h));
    } else if (['sbi', 'bank_of_baroda', 'south_indian'].contains(resolved)) {
      painter = BankPatternPainter.rects(rectConfig: _rect(h));
    } else if ([
      'yes',
      'dhanlaxmi',
      'indusind',
      'karnataka',
    ].contains(resolved)) {
      painter = BankPatternPainter.arcs(arcConfig: _arcs(h));
    } else if (['dcb', 'canara', 'tmb', 'jammu_kashmir'].contains(resolved)) {
      painter = BankPatternPainter.rightDual(
        rightDualConfig: _rightDual(h),
      );
    } else if (['federal', 'citibank', 'uco', 'hdfc'].contains(resolved)) {
      painter = BankPatternPainter.angledTiles(
        angledTileConfig: _angledTiles(h),
      );
    } else {
      painter = null; // Gradient only
    }

    return CardVisual(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: colors,
      ),
      bankLogo: BankAssetResolver.logoPath(cid),
      patternPainter: painter,
    );
  }

  static List<Color>? _colorsForBank(String cid, String resolved) {
    final directColors = _bankGradients[cid] ?? _bankGradients[resolved];
    if (directColors != null) {
      return directColors;
    }

    final importedColors =
        importedBankGradients[cid] ?? importedBankGradients[resolved];
    if (importedColors != null) {
      return importedColors;
    }

    final countryId = _countryIdFromBankId(resolved);
    if (countryId != null) {
      return _countryGradients[countryId];
    }

    return null;
  }

  static String? _countryIdFromBankId(String cid) {
    final separatorIndex = cid.indexOf('__');
    if (separatorIndex <= 0) {
      return null;
    }

    return cid.substring(0, separatorIndex);
  }

  static CardVisual placeholder(bool isDark) {
    return CardVisual(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isDark
            ? const [Color(0xFF2C2C2E), Color(0xFF1C1C1E)]
            : const [Color(0xFF555555), Color(0xFF333333)],
      ),
    );
  }
}
