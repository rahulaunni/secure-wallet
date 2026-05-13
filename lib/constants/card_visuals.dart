import 'package:flutter/material.dart';
import 'imported_card_gradients.dart';
import '../utils/bank_asset_resolver.dart';
import '../widgets/card/creative_bank_pattern_painter.dart';

class _CardVisualAsset {
  final String path;
  final String name;

  const _CardVisualAsset({
    required this.path,
    required this.name,
  });
}

class CardVisual {
  final Gradient gradient;
  final String? bankLogo;
  final String? visualAssetPath;
  final List<Color> visualColors;
  final double visualOpacityBoost;
  final double visualMinOverlayOpacity;

  const CardVisual({
    required this.gradient,
    this.bankLogo,
    this.visualAssetPath,
    this.visualColors = const [],
    this.visualOpacityBoost = 1,
    this.visualMinOverlayOpacity = 0.18,
  });
}

class CardVisuals {
  static CardVisual customGradient(
    Color start,
    Color end, {
    Color? middle,
    String? visualAssetPath,
    bool previewBoost = false,
  }) {
    return CardVisual(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [start, middle ?? Color.lerp(start, end, 0.5)!, end],
      ),
      visualAssetPath: visualAssetPath,
      visualColors: _visualColorsForBank(
        [start, middle ?? Color.lerp(start, end, 0.5)!, end],
        end,
      ),
      visualOpacityBoost:
          visualAssetPath == null ? 1 : (previewBoost ? 1.25 : 1.1),
      visualMinOverlayOpacity:
          visualAssetPath == null ? 0.18 : (previewBoost ? 0.22 : 0.18),
    );
  }

  static List<String> get customVisualAssetPaths => [
        for (final asset in _visualAssets) asset.path,
      ];

  static String customVisualAssetName(String assetPath) {
    final resolved = resolveVisualAssetPath(assetPath);
    for (final asset in _visualAssets) {
      if (asset.path == resolved) {
        return asset.name;
      }
    }

    return 'Pattern';
  }

  static List<Color> editableGradientColorsForBank(String cid) {
    final colors = forBank(cid).gradient.colors;
    if (colors.isEmpty) {
      return const [Color(0xFF111827), Color(0xFF1F4F9A), Color(0xFF2563EB)];
    }

    return [
      colors.first,
      colors.length > 2
          ? colors[1]
          : Color.lerp(colors.first, colors.last, 0.5)!,
      colors.length > 1 ? colors.last : colors.first,
    ];
  }

  static String resolveVisualAssetPath(String assetPath) {
    return _legacyVisualAssetPaths[assetPath] ?? assetPath;
  }

  /* -------------------------------------------------------------------------- */
  /*                              BANK GRADIENTS                                 */
  /* -------------------------------------------------------------------------- */

  static const Map<String, List<Color>> _bankGradients = {
    'axis': [Color(0xFFAE275F), Color(0xFF7C123F), Color(0xFF3F071F)],
    'bandhan': [Color(0xFF0A3152), Color(0xFFA71E1F), Color(0xFFEF3B23)],
    'csb': [Color(0xFFD40000), Color(0xFF0000AA), Color(0xFFFFD400)],
    'citibank': [Color(0xFF003B70), Color(0xFF005B9A), Color(0xFFD9261C)],
    'city_union': [Color(0xFF2E3192), Color(0xFFEC0677), Color(0xFF181A61)],
    'dcb': [Color(0xFF2C4190), Color(0xFF17235E), Color(0xFF4D65C4)],
    'dhanlaxmi': [Color(0xFF4B1858), Color(0xFF7A278F), Color(0xFF2A0D32)],
    'federal': [Color(0xFF004E96), Color(0xFF006DB8), Color(0xFFFAA61A)],
    'hdfc': [Color(0xFF004C8F), Color(0xFF002D55), Color(0xFFED232A)],
    'icici': [Color(0xFFAE282E), Color(0xFFF06321), Color(0xFF6E171C)],
    'indusind': [Color(0xFF98272A), Color(0xFF4A2C2A), Color(0xFFC98A2E)],
    'idfc': [Color(0xFFBC8CBF), Color(0xFFF16669), Color(0xFFF79448)],
    'karnataka': [Color(0xFF853A93), Color(0xFF5D2868), Color(0xFFB66AC2)],
    'kotak': [Color(0xFF003874), Color(0xFFED1C24), Color(0xFF001E3F)],
    'rbl': [Color(0xFF1C2E66), Color(0xFFED1C24), Color(0xFF0A1638)],
    'south_indian': [Color(0xFFDA251C), Color(0xFFFFA000), Color(0xFF84140F)],
    'yes': [Color(0xFF005192), Color(0xFF0B87C9), Color(0xFFC4261B)],
    'idbi': [Color(0xFF00836C), Color(0xFF004D40), Color(0xFFF58220)],
    'indian_bank': [Color(0xFF005BAC), Color(0xFF003B75), Color(0xFFF4B035)],
    'karur_vysya': [Color(0xFF00854A), Color(0xFF005A32), Color(0xFFE7E514)],
    'standard_chartered': [
      Color(0xFF0072CE),
      Color(0xFF006F3B),
      Color(0xFF003A70)
    ],
    'bank_of_baroda': [Color(0xFFF15A29), Color(0xFFF58220), Color(0xFF9B2D14)],
    'bank_of_india': [Color(0xFF005AA2), Color(0xFF00AEEA), Color(0xFFEE7A00)],
    'canara': [Color(0xFF0072BC), Color(0xFF004C8F), Color(0xFFFFB500)],
    'central_bank': [Color(0xFF176FC1), Color(0xFF0E3E78), Color(0xFFCE0F3E)],
    'indian_overseas': [
      Color(0xFF0083CA),
      Color(0xFF005B9A),
      Color(0xFF003D6E)
    ],
    'punjab_national_bank': [
      Color(0xFF9E173B),
      Color(0xFF6C0E27),
      Color(0xFFFAB90C)
    ],
    'sbi': [Color(0xFF292075), Color(0xFF00779E), Color(0xFF00A9E0)],
    'uco': [Color(0xFF1565C0), Color(0xFF0D47A1), Color(0xFFFFC107)],
    'union': [Color(0xFFE31E24), Color(0xFF1D4E9E), Color(0xFF0D2C66)],
    'au_small_finance': [
      Color(0xFF671773),
      Color(0xFFF47920),
      Color(0xFF360B3D)
    ],
    'tmb': [Color(0xFF673AB7), Color(0xFF3F1B7A), Color(0xFF9C27B0)],
    'jammu_kashmir': [Color(0xFF0084C4), Color(0xFF68B92E), Color(0xFFDE4019)],
    'punjab_sind': [Color(0xFF007C3D), Color(0xFFB31F31), Color(0xFFFBED21)],
    'bank_of_maharashtra': [Color(0xFF0E88D3), Color(0xFF075E9B)],
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
    'axis': Color(0xFFEB1165),
    'bandhan': Color(0xFFEF3B23),
    'au_small_finance': Color(0xFFF47920),
    'bank_of_baroda': Color(0xFFF58220),
    'bank_of_india': Color(0xFF00AEEA),
    'bank_of_maharashtra': Color(0xFF8EDCFF),
    'canara': Color(0xFFFFB500),
    'central_bank': Color(0xFFCE0F3E),
    'citibank': Color(0xFFD9261C),
    'city_union': Color(0xFFEC0677),
    'csb': Color(0xFFFFD400),
    'federal': Color(0xFFFAA61A),
    'hdfc': Color(0xFFED232A),
    'icici': Color(0xFFF06321),
    'idbi': Color(0xFFF58220),
    'indian_bank': Color(0xFFF4B035),
    'indusind': Color(0xFFC98A2E),
    'jammu_kashmir': Color(0xFF68B92E),
    'karur_vysya': Color(0xFFE7E514),
    'kotak': Color(0xFFED1C24),
    'punjab_sind': Color(0xFFFBED21),
    'punjab_national_bank': Color(0xFFFAB90C),
    'rbl': Color(0xFFED1C24),
    'sbi': Color(0xFF00A9E0),
    'south_indian': Color(0xFFFFA000),
    'standard_chartered': Color(0xFF0072CE),
    'uco': Color(0xFFFFC107),
    'union': Color(0xFFE31E24),
    'yes': Color(0xFFC4261B),
  };

  static Color _highlight(String cid, List<Color> g) {
    return _bankHighlightOverrides[cid] ??
        Color.lerp(g.first, Colors.white, 0.26)!;
  }

  /* -------------------------------------------------------------------------- */
  /*                         CREATIVE OVERLAY RECIPES                            */
  /* -------------------------------------------------------------------------- */

  static const Map<String, String> _bankPatternIds = {
    'au_small_finance': 'p01',
    'axis': 'p02',
    'bandhan': 'p03',
    'bank_of_baroda': 'p04',
    'bank_of_india': 'p05',
    'bank_of_maharashtra': 'p06',
    'canara': 'p07',
    'central_bank': 'p08',
    'citibank': 'p09',
    'city_union': 'p10',
    'csb': 'p11',
    'dcb': 'p12',
    'dhanlaxmi': 'p13',
    'federal': 'p14',
    'hdfc': 'p15',
    'icici': 'p16',
    'idbi': 'p17',
    'idfc': 'p18',
    'indian_bank': 'p19',
    'indian_overseas': 'p20',
    'indusind': 'p21',
    'jammu_kashmir': 'p22',
    'karnataka': 'p23',
    'karur_vysya': 'p24',
    'kotak': 'p25',
    'punjab_sind': 'p26',
    'punjab_national_bank': 'p27',
    'rbl': 'p28',
    'south_indian': 'p29',
    'standard_chartered': 'p30',
    'sbi': 'p31',
    'tmb': 'p32',
    'uco': 'p33',
    'union': 'p34',
    'yes': 'p35',
  };

  static const Map<String, CreativeBankPatternRecipe> _patternRecipes = {
    'p01': CreativeBankPatternRecipe(
      name: 'violet-orange faceted flame',
      motif: CreativeBankPatternMotif.guilloche,
      anchor: Offset(0.80, 0.22),
      scale: 1.06,
      density: 0.62,
      opacity: 0.34,
      strokeWidth: 1.6,
      angle: -0.22,
      alternate: true,
      seed: 101,
    ),
    'p02': CreativeBankPatternRecipe(
      name: 'maroon diagonal reserve bands',
      motif: CreativeBankPatternMotif.boldDiagonalBands,
      anchor: Offset(0.92, 0.24),
      scale: 1.02,
      density: 0.80,
      opacity: 0.36,
      strokeWidth: 1.2,
      angle: 0.10,
      alternate: false,
      seed: 102,
    ),
    'p03': CreativeBankPatternRecipe(
      name: 'navy-gold crescent sweep',
      motif: CreativeBankPatternMotif.crescentSweep,
      anchor: Offset(0.12, 0.06),
      scale: 1.18,
      density: 0.64,
      opacity: 0.28,
      strokeWidth: 1.5,
      angle: -0.05,
      alternate: true,
      seed: 103,
    ),
    'p04': CreativeBankPatternRecipe(
      name: 'baroda orange corner arcs',
      motif: CreativeBankPatternMotif.cornerArcBands,
      anchor: Offset(1.02, 0.48),
      scale: 0.98,
      density: 0.72,
      opacity: 0.30,
      strokeWidth: 1.5,
      angle: 0,
      alternate: false,
      seed: 104,
    ),
    'p05': CreativeBankPatternRecipe(
      name: 'boi blue folded planes',
      motif: CreativeBankPatternMotif.foldedPlanes,
      anchor: Offset(0.50, 0.50),
      scale: 0.96,
      density: 0.58,
      opacity: 0.24,
      strokeWidth: 1.0,
      angle: 0.10,
      alternate: false,
      seed: 105,
    ),
    'p06': CreativeBankPatternRecipe(
      name: 'maharashtra stepped diagonal',
      motif: CreativeBankPatternMotif.steppedDiagonal,
      anchor: Offset(0.83, 0.06),
      scale: 0.92,
      density: 0.72,
      opacity: 0.32,
      strokeWidth: 1.2,
      angle: -0.12,
      alternate: true,
      seed: 106,
    ),
    'p07': CreativeBankPatternRecipe(
      name: 'canara soft wave planes',
      motif: CreativeBankPatternMotif.contour,
      anchor: Offset(0.50, 0.50),
      scale: 0.94,
      density: 0.76,
      opacity: 0.27,
      strokeWidth: 1.4,
      angle: -0.10,
      alternate: true,
      seed: 107,
    ),
    'p08': CreativeBankPatternRecipe(
      name: 'central stacked ledger panels',
      motif: CreativeBankPatternMotif.waveRibbon,
      anchor: Offset(0.50, 0.50),
      scale: 0.88,
      density: 0.60,
      opacity: 0.30,
      strokeWidth: 1.5,
      angle: 0.02,
      alternate: false,
      seed: 108,
    ),
    'p09': CreativeBankPatternRecipe(
      name: 'citi blue portal arcs',
      motif: CreativeBankPatternMotif.diagonalPrism,
      anchor: Offset(0.82, 0.05),
      scale: 1.04,
      density: 0.66,
      opacity: 0.31,
      strokeWidth: 1.3,
      angle: -0.18,
      alternate: true,
      seed: 109,
    ),
    'p10': CreativeBankPatternRecipe(
      name: 'city union split oval crest',
      motif: CreativeBankPatternMotif.radialSun,
      anchor: Offset(0.50, 0.50),
      scale: 0.90,
      density: 0.70,
      opacity: 0.34,
      strokeWidth: 2.0,
      angle: 0.04,
      alternate: false,
      seed: 110,
    ),
    'p11': CreativeBankPatternRecipe(
      name: 'csb ember folded planes',
      motif: CreativeBankPatternMotif.foldedPlanes,
      anchor: Offset(0.50, 0.50),
      scale: 1.08,
      density: 0.54,
      opacity: 0.34,
      strokeWidth: 1.0,
      angle: -0.32,
      alternate: true,
      seed: 111,
    ),
    'p12': CreativeBankPatternRecipe(
      name: 'dcb midnight lens glow',
      motif: CreativeBankPatternMotif.lensGlow,
      anchor: Offset(0.50, 0.50),
      scale: 0.92,
      density: 0.76,
      opacity: 0.32,
      strokeWidth: 1.0,
      angle: 0,
      alternate: false,
      seed: 112,
    ),
    'p13': CreativeBankPatternRecipe(
      name: 'dhanlaxmi orchid crescent',
      motif: CreativeBankPatternMotif.dotConstellation,
      anchor: Offset(0.14, 0.22),
      scale: 0.92,
      density: 0.72,
      opacity: 0.34,
      strokeWidth: 1.1,
      angle: -0.08,
      alternate: true,
      seed: 113,
    ),
    'p14': CreativeBankPatternRecipe(
      name: 'federal electric ribbon sweep',
      motif: CreativeBankPatternMotif.diamondMesh,
      anchor: Offset(0.50, 0.50),
      scale: 1.08,
      density: 0.66,
      opacity: 0.31,
      strokeWidth: 1.6,
      angle: 0.22,
      alternate: false,
      seed: 114,
    ),
    'p15': CreativeBankPatternRecipe(
      name: 'hdfc blue portal shield',
      motif: CreativeBankPatternMotif.portalArcs,
      anchor: Offset(0.90, 0.16),
      scale: 1.00,
      density: 0.72,
      opacity: 0.30,
      strokeWidth: 1.6,
      angle: 0.10,
      alternate: false,
      seed: 115,
    ),
    'p16': CreativeBankPatternRecipe(
      name: 'icici copper split ovals',
      motif: CreativeBankPatternMotif.circuitTrace,
      anchor: Offset(0.10, 0.92),
      scale: 1.10,
      density: 0.84,
      opacity: 0.30,
      strokeWidth: 1.4,
      angle: 0,
      alternate: true,
      seed: 116,
    ),
    'p17': CreativeBankPatternRecipe(
      name: 'idbi teal lens flow',
      motif: CreativeBankPatternMotif.lensGlow,
      anchor: Offset(0.06, 0.16),
      scale: 1.00,
      density: 0.62,
      opacity: 0.28,
      strokeWidth: 1.4,
      angle: 0.18,
      alternate: false,
      seed: 117,
    ),
    'p18': CreativeBankPatternRecipe(
      name: 'idfc ruby diagonal glass',
      motif: CreativeBankPatternMotif.boldDiagonalBands,
      anchor: Offset(0.50, 0.50),
      scale: 0.98,
      density: 0.64,
      opacity: 0.30,
      strokeWidth: 1.0,
      angle: 0.26,
      alternate: false,
      seed: 118,
    ),
    'p19': CreativeBankPatternRecipe(
      name: 'indian bank blue-gold corner arcs',
      motif: CreativeBankPatternMotif.chevronVault,
      anchor: Offset(0.50, 0.50),
      scale: 1.00,
      density: 0.72,
      opacity: 0.26,
      strokeWidth: 1.1,
      angle: -0.06,
      alternate: true,
      seed: 119,
    ),
    'p20': CreativeBankPatternRecipe(
      name: 'iob sea ribbon sweep',
      motif: CreativeBankPatternMotif.templeSteps,
      anchor: Offset(0.50, 0.50),
      scale: 1.04,
      density: 0.72,
      opacity: 0.28,
      strokeWidth: 1.3,
      angle: -0.02,
      alternate: true,
      seed: 120,
    ),
    'p21': CreativeBankPatternRecipe(
      name: 'indusind bronze stacked panels',
      motif: CreativeBankPatternMotif.stackedPanels,
      anchor: Offset(0.12, 0.18),
      scale: 1.12,
      density: 0.58,
      opacity: 0.34,
      strokeWidth: 1.4,
      angle: 0.30,
      alternate: false,
      seed: 121,
    ),
    'p22': CreativeBankPatternRecipe(
      name: 'jk emerald soft waves',
      motif: CreativeBankPatternMotif.orbit,
      anchor: Offset(0.18, 0.92),
      scale: 1.20,
      density: 0.64,
      opacity: 0.31,
      strokeWidth: 1.4,
      angle: -0.18,
      alternate: true,
      seed: 122,
    ),
    'p23': CreativeBankPatternRecipe(
      name: 'karnataka red faceted planes',
      motif: CreativeBankPatternMotif.coinStack,
      anchor: Offset(0.50, 0.50),
      scale: 0.88,
      density: 0.76,
      opacity: 0.27,
      strokeWidth: 1.0,
      angle: -0.44,
      alternate: true,
      seed: 123,
    ),
    'p24': CreativeBankPatternRecipe(
      name: 'karur vysya folded blue-red',
      motif: CreativeBankPatternMotif.lotusMandala,
      anchor: Offset(0.50, 0.50),
      scale: 0.94,
      density: 0.60,
      opacity: 0.26,
      strokeWidth: 1.0,
      angle: 0.18,
      alternate: false,
      seed: 124,
    ),
    'p25': CreativeBankPatternRecipe(
      name: 'kotak crimson lens arc',
      motif: CreativeBankPatternMotif.lensGlow,
      anchor: Offset(0.50, 0.50),
      scale: 0.92,
      density: 0.84,
      opacity: 0.33,
      strokeWidth: 2.1,
      angle: -0.05,
      alternate: true,
      seed: 125,
    ),
    'p26': CreativeBankPatternRecipe(
      name: 'punjab sind gold stepped field',
      motif: CreativeBankPatternMotif.infinityLoop,
      anchor: Offset(0.72, 0.10),
      scale: 1.10,
      density: 0.72,
      opacity: 0.30,
      strokeWidth: 1.4,
      angle: -0.08,
      alternate: true,
      seed: 126,
    ),
    'p27': CreativeBankPatternRecipe(
      name: 'pnb garnet corner sweep',
      motif: CreativeBankPatternMotif.peacockEye,
      anchor: Offset(0.88, 0.72),
      scale: 1.04,
      density: 0.86,
      opacity: 0.35,
      strokeWidth: 1.2,
      angle: 0.04,
      alternate: false,
      seed: 127,
    ),
    'p28': CreativeBankPatternRecipe(
      name: 'rbl midnight skyline',
      motif: CreativeBankPatternMotif.facetedShard,
      anchor: Offset(0.50, 0.50),
      scale: 0.88,
      density: 0.82,
      opacity: 0.32,
      strokeWidth: 1.4,
      angle: 0.08,
      alternate: false,
      seed: 128,
    ),
    'p29': CreativeBankPatternRecipe(
      name: 'south indian warm ribbon',
      motif: CreativeBankPatternMotif.wovenBraid,
      anchor: Offset(0.94, 0.88),
      scale: 0.94,
      density: 0.74,
      opacity: 0.32,
      strokeWidth: 1.4,
      angle: 0,
      alternate: false,
      seed: 129,
    ),
    'p30': CreativeBankPatternRecipe(
      name: 'standard chartered green waves',
      motif: CreativeBankPatternMotif.skylineBars,
      anchor: Offset(0.86, 0.52),
      scale: 1.18,
      density: 0.66,
      opacity: 0.30,
      strokeWidth: 1.5,
      angle: -0.28,
      alternate: true,
      seed: 130,
    ),
    'p31': CreativeBankPatternRecipe(
      name: 'sbi blue keyhole portal',
      motif: CreativeBankPatternMotif.portalArcs,
      anchor: Offset(0.50, 0.50),
      scale: 1.10,
      density: 0.88,
      opacity: 0.31,
      strokeWidth: 1.5,
      angle: -0.20,
      alternate: true,
      seed: 131,
    ),
    'p32': CreativeBankPatternRecipe(
      name: 'tmb violet crescent arcs',
      motif: CreativeBankPatternMotif.hexBloom,
      anchor: Offset(0.50, 0.50),
      scale: 0.88,
      density: 0.88,
      opacity: 0.34,
      strokeWidth: 1.0,
      angle: 0,
      alternate: false,
      seed: 132,
    ),
    'p33': CreativeBankPatternRecipe(
      name: 'uco deep blue stacked panels',
      motif: CreativeBankPatternMotif.magneticField,
      anchor: Offset(0.50, 0.50),
      scale: 1.00,
      density: 0.64,
      opacity: 0.28,
      strokeWidth: 2.0,
      angle: 0.10,
      alternate: false,
      seed: 133,
    ),
    'p34': CreativeBankPatternRecipe(
      name: 'union dual-color split planes',
      motif: CreativeBankPatternMotif.monsoonTopo,
      anchor: Offset(0.74, 0.05),
      scale: 1.04,
      density: 0.84,
      opacity: 0.34,
      strokeWidth: 1.1,
      angle: 0.16,
      alternate: true,
      seed: 134,
    ),
    'p35': CreativeBankPatternRecipe(
      name: 'yes cyan faceted glass',
      motif: CreativeBankPatternMotif.boldDiagonalBands,
      anchor: Offset(0.50, 0.50),
      scale: 1.12,
      density: 0.58,
      opacity: 0.28,
      strokeWidth: 1.0,
      angle: 0.42,
      alternate: false,
      seed: 135,
    ),
    'p36': CreativeBankPatternRecipe(
        name: 'reserve diagonal bands one',
        motif: CreativeBankPatternMotif.boldDiagonalBands,
        anchor: Offset(0.18, 0.78),
        scale: 0.92,
        density: 0.70,
        opacity: 0.30,
        strokeWidth: 1.1,
        angle: -0.12,
        alternate: false,
        seed: 136),
    'p37': CreativeBankPatternRecipe(
        name: 'reserve corner arcs one',
        motif: CreativeBankPatternMotif.cornerArcBands,
        anchor: Offset(0.82, 0.82),
        scale: 1.08,
        density: 0.74,
        opacity: 0.28,
        strokeWidth: 1.4,
        angle: 0.16,
        alternate: true,
        seed: 137),
    'p38': CreativeBankPatternRecipe(
        name: 'reserve soft waves one',
        motif: CreativeBankPatternMotif.softWavePlanes,
        anchor: Offset(0.50, 0.50),
        scale: 0.90,
        density: 0.58,
        opacity: 0.26,
        strokeWidth: 1.5,
        angle: 0.32,
        alternate: false,
        seed: 138),
    'p39': CreativeBankPatternRecipe(
        name: 'reserve crescent one',
        motif: CreativeBankPatternMotif.crescentSweep,
        anchor: Offset(0.50, 0.50),
        scale: 0.86,
        density: 0.84,
        opacity: 0.28,
        strokeWidth: 1.0,
        angle: -0.52,
        alternate: true,
        seed: 139),
    'p40': CreativeBankPatternRecipe(
        name: 'reserve folded planes one',
        motif: CreativeBankPatternMotif.foldedPlanes,
        anchor: Offset(0.04, 0.50),
        scale: 1.00,
        density: 0.70,
        opacity: 0.28,
        strokeWidth: 1.3,
        angle: 0,
        alternate: true,
        seed: 140),
    'p41': CreativeBankPatternRecipe(
        name: 'reserve split ovals one',
        motif: CreativeBankPatternMotif.splitOvalPlanes,
        anchor: Offset(0.50, 0.50),
        scale: 0.94,
        density: 0.62,
        opacity: 0.30,
        strokeWidth: 1.0,
        angle: 0,
        alternate: false,
        seed: 141),
    'p42': CreativeBankPatternRecipe(
        name: 'reserve ribbon one',
        motif: CreativeBankPatternMotif.ribbonSweep,
        anchor: Offset(0.50, 0.50),
        scale: 0.92,
        density: 0.86,
        opacity: 0.24,
        strokeWidth: 0.9,
        angle: -0.22,
        alternate: true,
        seed: 142),
    'p43': CreativeBankPatternRecipe(
        name: 'reserve stacked panels one',
        motif: CreativeBankPatternMotif.stackedPanels,
        anchor: Offset(0.50, 0.50),
        scale: 1.00,
        density: 0.54,
        opacity: 0.30,
        strokeWidth: 1.5,
        angle: 0.12,
        alternate: true,
        seed: 143),
    'p44': CreativeBankPatternRecipe(
        name: 'reserve lens one',
        motif: CreativeBankPatternMotif.lensGlow,
        anchor: Offset(0.50, 0.50),
        scale: 0.96,
        density: 0.72,
        opacity: 0.31,
        strokeWidth: 1.8,
        angle: -0.14,
        alternate: false,
        seed: 144),
    'p45': CreativeBankPatternRecipe(
        name: 'reserve stepped diagonal one',
        motif: CreativeBankPatternMotif.steppedDiagonal,
        anchor: Offset(0.18, 0.08),
        scale: 0.88,
        density: 0.76,
        opacity: 0.31,
        strokeWidth: 1.0,
        angle: -0.20,
        alternate: false,
        seed: 145),
    'p46': CreativeBankPatternRecipe(
        name: 'reserve diagonal bands two',
        motif: CreativeBankPatternMotif.boldDiagonalBands,
        anchor: Offset(0.52, 0.10),
        scale: 1.22,
        density: 0.56,
        opacity: 0.30,
        strokeWidth: 1.3,
        angle: 0.44,
        alternate: true,
        seed: 146),
    'p47': CreativeBankPatternRecipe(
        name: 'reserve corner arcs two',
        motif: CreativeBankPatternMotif.cornerArcBands,
        anchor: Offset(0.10, 0.80),
        scale: 0.96,
        density: 0.82,
        opacity: 0.29,
        strokeWidth: 1.4,
        angle: 0.12,
        alternate: false,
        seed: 147),
    'p48': CreativeBankPatternRecipe(
        name: 'reserve soft waves two',
        motif: CreativeBankPatternMotif.softWavePlanes,
        anchor: Offset(0.50, 0.50),
        scale: 1.20,
        density: 0.78,
        opacity: 0.28,
        strokeWidth: 1.2,
        angle: -0.38,
        alternate: true,
        seed: 148),
    'p49': CreativeBankPatternRecipe(
        name: 'reserve folded planes two',
        motif: CreativeBankPatternMotif.foldedPlanes,
        anchor: Offset(0.54, 0.54),
        scale: 1.08,
        density: 0.90,
        opacity: 0.28,
        strokeWidth: 1.0,
        angle: 0.20,
        alternate: true,
        seed: 149),
    'p50': CreativeBankPatternRecipe(
        name: 'reserve ribbon two',
        motif: CreativeBankPatternMotif.ribbonSweep,
        anchor: Offset(0.50, 0.50),
        scale: 0.86,
        density: 0.90,
        opacity: 0.27,
        strokeWidth: 1.2,
        angle: -0.24,
        alternate: false,
        seed: 150),
  };

  static int get creativePatternCount => _bankPatternIds.length;

  static bool hasCreativePatternForBank(String cid) {
    final resolved = BankAssetResolver.resolveCid(cid);
    final shortId = _shortIdForBank(cid, resolved);
    return _bankPatternIds.containsKey(shortId);
  }

  static const Map<String, CreativeBankPatternMotif> _fixedFigmaMotifs = {
    'axis': CreativeBankPatternMotif.figmaPurpleOrbs,
    'hdfc': CreativeBankPatternMotif.figmaCoralDiagonals,
    'bandhan': CreativeBankPatternMotif.figmaBlueBubbles,
    'bank_of_baroda': CreativeBankPatternMotif.figmaMintChevrons,
    'bank_of_india': CreativeBankPatternMotif.figmaVioletArcs,
    'bank_of_maharashtra': CreativeBankPatternMotif.figmaLimeSlashes,
    'idbi': CreativeBankPatternMotif.figmaEmeraldBlocks,
    'dcb': CreativeBankPatternMotif.figmaNoirRings,
    'indusind': CreativeBankPatternMotif.figmaBronzeArcs,
    'csb': CreativeBankPatternMotif.figmaGoldSplit,
    'idfc': CreativeBankPatternMotif.figmaSoftVerticalStripes,
    'kotak': CreativeBankPatternMotif.figmaRedLiquid,
  };

  static const Map<String, CreativeBankPatternMotif> _memoryMotifs = {
    'au_small_finance': CreativeBankPatternMotif.memoryAuroraLens,
    'canara': CreativeBankPatternMotif.memoryGlassDiagonal,
    'central_bank': CreativeBankPatternMotif.memoryOrbitBubble,
    'citibank': CreativeBankPatternMotif.memoryFoldedCorner,
    'city_union': CreativeBankPatternMotif.memoryRibbonBend,
    'dhanlaxmi': CreativeBankPatternMotif.memorySlantStack,
    'federal': CreativeBankPatternMotif.memorySoftCapsules,
    'icici': CreativeBankPatternMotif.memoryCornerHalo,
    'indian_bank': CreativeBankPatternMotif.memoryNestedPortal,
    'indian_overseas': CreativeBankPatternMotif.memoryLiquidWave,
    'jammu_kashmir': CreativeBankPatternMotif.memoryArcCascade,
    'karnataka': CreativeBankPatternMotif.memoryPrismWindow,
    'karur_vysya': CreativeBankPatternMotif.memoryOffsetRings,
    'punjab_sind': CreativeBankPatternMotif.memoryVaultChevron,
    'punjab_national_bank': CreativeBankPatternMotif.memoryFloatingTabs,
    'rbl': CreativeBankPatternMotif.memorySplitGlow,
    'south_indian': CreativeBankPatternMotif.memoryInsetOrbs,
    'standard_chartered': CreativeBankPatternMotif.memoryStepRibbon,
    'sbi': CreativeBankPatternMotif.memoryTiltedTiles,
    'tmb': CreativeBankPatternMotif.memoryMoonCrop,
    'uco': CreativeBankPatternMotif.memorySoftStripes,
    'union': CreativeBankPatternMotif.memoryCapsuleCross,
    'yes': CreativeBankPatternMotif.memoryConicBloom,
  };

  static CreativeBankPatternMotif? debugCreativeMotifForBank(String cid) {
    final resolved = BankAssetResolver.resolveCid(cid);
    final shortId = _shortIdForBank(cid, resolved);
    final recipeId = _bankPatternIds[shortId];
    if (recipeId == null) return null;

    return _fixedFigmaMotifs[shortId] ??
        _memoryMotifs[shortId] ??
        _patternRecipes[recipeId]?.motif;
  }

  /* -------------------------------------------------------------------------- */
  /*                               RESOLVER                                      */
  /* -------------------------------------------------------------------------- */

  static CardVisual forBank(String cid) {
    final resolved = BankAssetResolver.resolveCid(cid);
    final shortId = _shortIdForBank(cid, resolved);
    final colors = _colorsForBank(cid, resolved, shortId);
    if (colors == null) return placeholder(false);

    final h = _highlight(shortId, colors);

    return CardVisual(
      gradient: LinearGradient(
        begin: _gradientBeginForBank(shortId),
        end: _gradientEndForBank(shortId),
        colors: colors,
      ),
      bankLogo: BankAssetResolver.logoPath(cid),
      visualAssetPath: _visualAssetForBank(shortId),
      visualColors: _visualColorsForBank(colors, h),
      visualOpacityBoost: shortId == 'bank_of_baroda' ? 2.35 : 1,
      visualMinOverlayOpacity: shortId == 'bank_of_baroda' ? 0.62 : 0.22,
    );
  }

  static String _visualAssetForBank(String shortId) {
    final knownIndex = _bankPatternIds.keys.toList().indexOf(shortId);
    final styleIndex = knownIndex >= 0
        ? knownIndex % _visualAssets.length
        : _stableStyleHash(shortId) % _visualAssets.length;
    return _visualAssets[styleIndex].path;
  }

  static const List<_CardVisualAsset> _visualAssets = [
    _CardVisualAsset(
      path: 'assets/card visuals/shadow-stripes.svg',
      name: 'Shadow Stripes',
    ),
    _CardVisualAsset(
      path: 'assets/card visuals/glass-panels.svg',
      name: 'Glass Panels',
    ),
    _CardVisualAsset(
      path: 'assets/card visuals/prism-cross.svg',
      name: 'Prism Cross',
    ),
    _CardVisualAsset(
      path: 'assets/card visuals/corner-cascade.svg',
      name: 'Corner Cascade',
    ),
    _CardVisualAsset(
      path: 'assets/card visuals/rounded-blocks.svg',
      name: 'Rounded Blocks',
    ),
    _CardVisualAsset(
      path: 'assets/card visuals/diagonal-plates.svg',
      name: 'Diagonal Plates',
    ),
    _CardVisualAsset(
      path: 'assets/card visuals/liquid-orbs.svg',
      name: 'Liquid Orbs',
    ),
    _CardVisualAsset(
      path: 'assets/card visuals/corner-bubbles.svg',
      name: 'Corner Bubbles',
    ),
    _CardVisualAsset(
      path: 'assets/card visuals/glass-ribbons.svg',
      name: 'Glass Ribbons',
    ),
    _CardVisualAsset(
      path: 'assets/card visuals/neon-blocks.svg',
      name: 'Neon Blocks',
    ),
    _CardVisualAsset(
      path: 'assets/card visuals/capsule-slashes.svg',
      name: 'Capsule Slashes',
    ),
    _CardVisualAsset(
      path: 'assets/card visuals/angular-bloom.svg',
      name: 'Angular Bloom',
    ),
    _CardVisualAsset(
      path: 'assets/card visuals/radial-sweep.svg',
      name: 'Radial Sweep',
    ),
    _CardVisualAsset(
      path: 'assets/card visuals/soft-columns.svg',
      name: 'Soft Columns',
    ),
    _CardVisualAsset(
      path: 'assets/card visuals/liquid-glow.svg',
      name: 'Liquid Glow',
    ),
    _CardVisualAsset(
      path: 'assets/card visuals/orbit-rings.svg',
      name: 'Orbit Rings',
    ),
    _CardVisualAsset(
      path: 'assets/card visuals/nested-rings.svg',
      name: 'Nested Rings',
    ),
    _CardVisualAsset(
      path: 'assets/card visuals/inset-waves.svg',
      name: 'Inset Waves',
    ),
  ];

  static const Map<String, String> _legacyVisualAssetPaths = {
    'assets/card visuals/Credit Card.svg':
        'assets/card visuals/shadow-stripes.svg',
    'assets/card visuals/Frame.svg': 'assets/card visuals/glass-panels.svg',
    'assets/card visuals/Frame-1.svg': 'assets/card visuals/prism-cross.svg',
    'assets/card visuals/Frame-2.svg': 'assets/card visuals/corner-cascade.svg',
    'assets/card visuals/red.svg': 'assets/card visuals/rounded-blocks.svg',
    'assets/card visuals/style1.svg': 'assets/card visuals/shadow-stripes.svg',
    'assets/card visuals/style1-02.svg':
        'assets/card visuals/diagonal-plates.svg',
    'assets/card visuals/style1-02-1.svg':
        'assets/card visuals/liquid-orbs.svg',
    'assets/card visuals/style1-02-2.svg':
        'assets/card visuals/corner-bubbles.svg',
    'assets/card visuals/style1-02-3.svg':
        'assets/card visuals/glass-ribbons.svg',
    'assets/card visuals/style1-02-4.svg':
        'assets/card visuals/neon-blocks.svg',
    'assets/card visuals/style1-03.svg':
        'assets/card visuals/capsule-slashes.svg',
    'assets/card visuals/style1-06.svg':
        'assets/card visuals/angular-bloom.svg',
    'assets/card visuals/style1-06-1.svg':
        'assets/card visuals/radial-sweep.svg',
    'assets/card visuals/style1-07.svg': 'assets/card visuals/soft-columns.svg',
    'assets/card visuals/style1-08.svg': 'assets/card visuals/liquid-glow.svg',
    'assets/card visuals/style1-09.svg': 'assets/card visuals/orbit-rings.svg',
    'assets/card visuals/style1-09-1.svg':
        'assets/card visuals/nested-rings.svg',
    'assets/card visuals/style1-10.svg': 'assets/card visuals/inset-waves.svg',
    'assets/card visuals/style1-11.svg': 'assets/card visuals/inset-waves.svg',
    'assets/card visuals/style2.svg': 'assets/card visuals/glass-panels.svg',
    'assets/card visuals/style4.svg': 'assets/card visuals/prism-cross.svg',
    'assets/card visuals/style5.svg': 'assets/card visuals/diagonal-plates.svg',
    'assets/card visuals/style6.svg': 'assets/card visuals/corner-cascade.svg',
    'assets/card visuals/style7.svg': 'assets/card visuals/capsule-slashes.svg',
    'assets/card visuals/style8.svg': 'assets/card visuals/liquid-orbs.svg',
    'assets/card visuals/style9.svg': 'assets/card visuals/corner-bubbles.svg',
    'assets/card visuals/style10.svg': 'assets/card visuals/glass-ribbons.svg',
    'assets/card visuals/style11.svg': 'assets/card visuals/neon-blocks.svg',
    'assets/card visuals/style12.svg': 'assets/card visuals/angular-bloom.svg',
    'assets/card visuals/style13.svg': 'assets/card visuals/radial-sweep.svg',
    'assets/card visuals/style14.svg': 'assets/card visuals/orbit-rings.svg',
    'assets/card visuals/style15.svg': 'assets/card visuals/nested-rings.svg',
    'assets/card visuals/style16.svg': 'assets/card visuals/inset-waves.svg',
  };

  static int _stableStyleHash(String value) {
    var hash = 0;
    for (final codeUnit in value.codeUnits) {
      hash = ((hash * 31) + codeUnit) & 0x7fffffff;
    }
    return hash;
  }

  static List<Color> _visualColorsForBank(List<Color> colors, Color highlight) {
    final base = colors.first;
    final mid =
        colors.length > 1 ? colors[1] : Color.lerp(base, highlight, 0.4)!;
    final end = colors.last;
    final complement = _complementFor(highlight);

    return [
      Color.lerp(base, Colors.black, 0.18)!,
      base,
      mid,
      highlight,
      Color.lerp(end, Colors.white, 0.18)!,
      Color.lerp(highlight, Colors.white, 0.35)!,
      complement,
    ];
  }

  static Color _complementFor(Color color) {
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withHue((hsl.hue + 180) % 360)
        .withSaturation(hsl.saturation.clamp(0.34, 0.74))
        .withLightness(hsl.lightness.clamp(0.34, 0.68))
        .toColor();
  }

  static List<Color>? _colorsForBank(
    String cid,
    String resolved,
    String shortId,
  ) {
    final directColors = _bankGradients[cid] ??
        _bankGradients[resolved] ??
        _bankGradients[shortId];
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

  static String _shortIdForBank(String cid, String resolved) {
    if (_bankGradients.containsKey(cid) || _bankPatternIds.containsKey(cid)) {
      return cid;
    }
    if (_bankGradients.containsKey(resolved) ||
        _bankPatternIds.containsKey(resolved)) {
      return resolved;
    }

    for (final bankId in _bankPatternIds.keys) {
      if (BankAssetResolver.resolveCid(bankId) == resolved) {
        return bankId;
      }
    }

    return cid;
  }

  static Alignment _gradientBeginForBank(String cid) {
    switch (cid) {
      case 'axis':
      case 'citibank':
      case 'city_union':
        return Alignment.centerLeft;
      default:
        return Alignment.topLeft;
    }
  }

  static Alignment _gradientEndForBank(String cid) {
    switch (cid) {
      case 'axis':
      case 'citibank':
      case 'city_union':
        return Alignment.centerRight;
      default:
        return Alignment.bottomRight;
    }
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
      visualColors: isDark
          ? const [Color(0xFF2C2C2E), Color(0xFF1C1C1E)]
          : const [Color(0xFF555555), Color(0xFF333333)],
    );
  }
}
