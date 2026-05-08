import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

enum CreativeBankPatternMotif {
  guilloche,
  contour,
  waveRibbon,
  diagonalPrism,
  radialSun,
  dotConstellation,
  diamondMesh,
  circuitTrace,
  chevronVault,
  templeSteps,
  orbit,
  coinStack,
  lotusMandala,
  infinityLoop,
  peacockEye,
  facetedShard,
  wovenBraid,
  skylineBars,
  portalArcs,
  hexBloom,
  magneticField,
  monsoonTopo,
  boldDiagonalBands,
  cornerArcBands,
  softWavePlanes,
  crescentSweep,
  foldedPlanes,
  splitOvalPlanes,
  ribbonSweep,
  stackedPanels,
  lensGlow,
  steppedDiagonal,
  figmaPurpleOrbs,
  figmaCoralDiagonals,
  figmaBlueBubbles,
  figmaMintChevrons,
  figmaVioletArcs,
  figmaLimeSlashes,
  figmaEmeraldBlocks,
  figmaNoirRings,
  figmaBronzeArcs,
  figmaGoldSplit,
  figmaSoftVerticalStripes,
  figmaRedLiquid,
}

class CreativeBankPatternRecipe {
  final String name;
  final CreativeBankPatternMotif motif;
  final Offset anchor;
  final double scale;
  final double density;
  final double opacity;
  final double strokeWidth;
  final double angle;
  final bool alternate;
  final int seed;

  const CreativeBankPatternRecipe({
    required this.name,
    required this.motif,
    required this.anchor,
    required this.scale,
    required this.density,
    required this.opacity,
    required this.strokeWidth,
    required this.angle,
    required this.alternate,
    required this.seed,
  });
}

class CreativeBankPatternPainter extends CustomPainter {
  final CreativeBankPatternRecipe recipe;
  final Color primary;
  final Color secondary;
  final CreativeBankPatternMotif? motifOverride;

  const CreativeBankPatternPainter({
    required this.recipe,
    required this.primary,
    required this.secondary,
    this.motifOverride,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..isAntiAlias = true
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final motif = motifOverride ?? recipe.motif;

    canvas.save();
    canvas.clipRect(Offset.zero & size);
    if (!_isFigmaMotif(motif)) {
      _rotateCanvas(canvas, size, recipe.angle);
    }

    switch (motif) {
      case CreativeBankPatternMotif.guilloche:
        _paintGuilloche(canvas, size, paint);
        break;
      case CreativeBankPatternMotif.contour:
        _paintContour(canvas, size, paint);
        break;
      case CreativeBankPatternMotif.waveRibbon:
        _paintWaveRibbon(canvas, size, paint);
        break;
      case CreativeBankPatternMotif.diagonalPrism:
        _paintDiagonalPrism(canvas, size, paint);
        break;
      case CreativeBankPatternMotif.radialSun:
        _paintRadialSun(canvas, size, paint);
        break;
      case CreativeBankPatternMotif.dotConstellation:
        _paintDotConstellation(canvas, size, paint);
        break;
      case CreativeBankPatternMotif.diamondMesh:
        _paintDiamondMesh(canvas, size, paint);
        break;
      case CreativeBankPatternMotif.circuitTrace:
        _paintCircuitTrace(canvas, size, paint);
        break;
      case CreativeBankPatternMotif.chevronVault:
        _paintChevronVault(canvas, size, paint);
        break;
      case CreativeBankPatternMotif.templeSteps:
        _paintTempleSteps(canvas, size, paint);
        break;
      case CreativeBankPatternMotif.orbit:
        _paintOrbit(canvas, size, paint);
        break;
      case CreativeBankPatternMotif.coinStack:
        _paintCoinStack(canvas, size, paint);
        break;
      case CreativeBankPatternMotif.lotusMandala:
        _paintLotusMandala(canvas, size, paint);
        break;
      case CreativeBankPatternMotif.infinityLoop:
        _paintInfinityLoop(canvas, size, paint);
        break;
      case CreativeBankPatternMotif.peacockEye:
        _paintPeacockEye(canvas, size, paint);
        break;
      case CreativeBankPatternMotif.facetedShard:
        _paintFacetedShard(canvas, size, paint);
        break;
      case CreativeBankPatternMotif.wovenBraid:
        _paintWovenBraid(canvas, size, paint);
        break;
      case CreativeBankPatternMotif.skylineBars:
        _paintSkylineBars(canvas, size, paint);
        break;
      case CreativeBankPatternMotif.portalArcs:
        _paintPortalArcs(canvas, size, paint);
        break;
      case CreativeBankPatternMotif.hexBloom:
        _paintHexBloom(canvas, size, paint);
        break;
      case CreativeBankPatternMotif.magneticField:
        _paintMagneticField(canvas, size, paint);
        break;
      case CreativeBankPatternMotif.monsoonTopo:
        _paintMonsoonTopo(canvas, size, paint);
        break;
      case CreativeBankPatternMotif.boldDiagonalBands:
        _paintBoldDiagonalBands(canvas, size, paint);
        break;
      case CreativeBankPatternMotif.cornerArcBands:
        _paintCornerArcBands(canvas, size, paint);
        break;
      case CreativeBankPatternMotif.softWavePlanes:
        _paintSoftWavePlanes(canvas, size, paint);
        break;
      case CreativeBankPatternMotif.crescentSweep:
        _paintCrescentSweep(canvas, size, paint);
        break;
      case CreativeBankPatternMotif.foldedPlanes:
        _paintFoldedPlanes(canvas, size, paint);
        break;
      case CreativeBankPatternMotif.splitOvalPlanes:
        _paintSplitOvalPlanes(canvas, size, paint);
        break;
      case CreativeBankPatternMotif.ribbonSweep:
        _paintRibbonSweep(canvas, size, paint);
        break;
      case CreativeBankPatternMotif.stackedPanels:
        _paintStackedPanels(canvas, size, paint);
        break;
      case CreativeBankPatternMotif.lensGlow:
        _paintLensGlow(canvas, size, paint);
        break;
      case CreativeBankPatternMotif.steppedDiagonal:
        _paintSteppedDiagonal(canvas, size, paint);
        break;
      case CreativeBankPatternMotif.figmaPurpleOrbs:
        _paintFigmaPurpleOrbs(canvas, size, paint);
        break;
      case CreativeBankPatternMotif.figmaCoralDiagonals:
        _paintFigmaCoralDiagonals(canvas, size, paint);
        break;
      case CreativeBankPatternMotif.figmaBlueBubbles:
        _paintFigmaBlueBubbles(canvas, size, paint);
        break;
      case CreativeBankPatternMotif.figmaMintChevrons:
        _paintFigmaMintChevrons(canvas, size, paint);
        break;
      case CreativeBankPatternMotif.figmaVioletArcs:
        _paintFigmaVioletArcs(canvas, size, paint);
        break;
      case CreativeBankPatternMotif.figmaLimeSlashes:
        _paintFigmaLimeSlashes(canvas, size, paint);
        break;
      case CreativeBankPatternMotif.figmaEmeraldBlocks:
        _paintFigmaEmeraldBlocks(canvas, size, paint);
        break;
      case CreativeBankPatternMotif.figmaNoirRings:
        _paintFigmaNoirRings(canvas, size, paint);
        break;
      case CreativeBankPatternMotif.figmaBronzeArcs:
        _paintFigmaBronzeArcs(canvas, size, paint);
        break;
      case CreativeBankPatternMotif.figmaGoldSplit:
        _paintFigmaGoldSplit(canvas, size, paint);
        break;
      case CreativeBankPatternMotif.figmaSoftVerticalStripes:
        _paintFigmaSoftVerticalStripes(canvas, size, paint);
        break;
      case CreativeBankPatternMotif.figmaRedLiquid:
        _paintFigmaRedLiquid(canvas, size, paint);
        break;
    }

    canvas.restore();
  }

  bool _isFigmaMotif(CreativeBankPatternMotif motif) {
    return switch (motif) {
      CreativeBankPatternMotif.figmaPurpleOrbs ||
      CreativeBankPatternMotif.figmaCoralDiagonals ||
      CreativeBankPatternMotif.figmaBlueBubbles ||
      CreativeBankPatternMotif.figmaMintChevrons ||
      CreativeBankPatternMotif.figmaVioletArcs ||
      CreativeBankPatternMotif.figmaLimeSlashes ||
      CreativeBankPatternMotif.figmaEmeraldBlocks ||
      CreativeBankPatternMotif.figmaNoirRings ||
      CreativeBankPatternMotif.figmaBronzeArcs ||
      CreativeBankPatternMotif.figmaGoldSplit ||
      CreativeBankPatternMotif.figmaSoftVerticalStripes ||
      CreativeBankPatternMotif.figmaRedLiquid =>
        true,
      _ => false,
    };
  }

  void _rotateCanvas(Canvas canvas, Size size, double angle) {
    if (angle == 0) return;
    final center = Offset(size.width / 2, size.height / 2);
    canvas
      ..translate(center.dx, center.dy)
      ..rotate(angle)
      ..translate(-center.dx, -center.dy);
  }

  Offset _anchor(Size size) {
    return Offset(
        size.width * recipe.anchor.dx, size.height * recipe.anchor.dy);
  }

  double _min(Size size) => math.min(size.width, size.height);

  Color _mixColor(int index) => index.isEven ? primary : secondary;

  Offset _pt(Size size, double baseW, double baseH, double x, double y) {
    return Offset(size.width * x / baseW, size.height * y / baseH);
  }

  Rect _rect(
    Size size,
    double baseW,
    double baseH,
    double x,
    double y,
    double width,
    double height,
  ) {
    return Rect.fromLTWH(
      size.width * x / baseW,
      size.height * y / baseH,
      size.width * width / baseW,
      size.height * height / baseH,
    );
  }

  void _drawSvgRotatedRRect(
    Canvas canvas,
    Paint paint,
    Size size, {
    required double baseW,
    required double baseH,
    required double x,
    required double y,
    required double width,
    required double height,
    required double radius,
    required double angleDeg,
  }) {
    final origin = _pt(size, baseW, baseH, x, y);
    canvas.save();
    canvas.translate(origin.dx, origin.dy);
    canvas.rotate(angleDeg * math.pi / 180);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          0,
          0,
          size.width * width / baseW,
          size.height * height / baseH,
        ),
        Radius.circular(size.width * radius / baseW),
      ),
      paint,
    );
    canvas.restore();
  }

  void _paintGuilloche(Canvas canvas, Size size, Paint paint) {
    final center = _anchor(size);
    final base = _min(size) * recipe.scale;
    final loops = (10 + recipe.density * 14).round();
    const steps = 180;

    paint
      ..style = PaintingStyle.stroke
      ..strokeWidth = recipe.strokeWidth
      ..blendMode = BlendMode.srcOver;

    for (var ring = 0; ring < loops; ring++) {
      final phase = (recipe.seed + ring) * 0.37;
      final rx = base * (0.30 + ring / loops * 0.58);
      final ry = base * (0.16 + ring / loops * 0.36);
      final path = Path();

      for (var i = 0; i <= steps; i++) {
        final t = (math.pi * 2 * i) / steps;
        final wobble = math.sin(t * (3 + recipe.seed % 5) + phase) * rx * 0.10;
        final x =
            center.dx + math.cos(t) * rx + math.cos(t * 5 + phase) * wobble;
        final y = center.dy + math.sin(t * 2 + phase * 0.2) * ry;
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }

      paint.color = _mixColor(ring).withValues(
        alpha: (recipe.opacity * (1 - ring / (loops * 1.35))).clamp(0.02, 0.30),
      );
      canvas.drawPath(path, paint);
    }
  }

  void _paintContour(Canvas canvas, Size size, Paint paint) {
    final center = _anchor(size);
    final count = (9 + recipe.density * 16).round();
    paint
      ..style = PaintingStyle.stroke
      ..strokeWidth = recipe.strokeWidth;

    for (var i = 0; i < count; i++) {
      final inset = _min(size) * (0.03 + i * 0.035 * recipe.scale);
      final rect = Rect.fromCenter(
        center: center,
        width: size.width * recipe.scale - inset,
        height: size.height * (0.72 + recipe.scale * 0.28) - inset * 0.6,
      );
      if (rect.width <= 0 || rect.height <= 0) break;
      paint.color = _mixColor(i).withValues(
        alpha: recipe.opacity * (1 - i / (count + 3)),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(_min(size) * 0.12)),
        paint,
      );
    }
  }

  void _paintWaveRibbon(Canvas canvas, Size size, Paint paint) {
    final lines = (8 + recipe.density * 18).round();
    final amplitude = size.height * (0.045 + recipe.scale * 0.035);
    final gap = size.height / (lines + 1);
    paint
      ..style = PaintingStyle.stroke
      ..strokeWidth = recipe.strokeWidth;

    for (var row = 0; row < lines; row++) {
      final y = gap * (row + 1);
      final phase = (recipe.seed * 0.23) + row * 0.45;
      final path = Path()..moveTo(-size.width * 0.1, y);
      for (var x = -size.width * 0.1; x <= size.width * 1.1; x += 8) {
        final wave =
            math.sin((x / size.width) * math.pi * (2.2 + recipe.scale) + phase);
        path.lineTo(x, y + wave * amplitude);
      }
      paint.color = _mixColor(row).withValues(
        alpha: recipe.opacity * (recipe.alternate ? 0.82 : 1),
      );
      canvas.drawPath(path, paint);
    }
  }

  void _paintDiagonalPrism(Canvas canvas, Size size, Paint paint) {
    final count = (5 + recipe.density * 12).round();
    final bandWidth = size.width * (0.11 + recipe.scale * 0.025);
    paint.style = PaintingStyle.fill;

    for (var i = 0; i < count; i++) {
      final left = -size.width * 0.35 + i * bandWidth * 0.86;
      final rect = Rect.fromLTWH(
        left,
        -size.height * 0.55,
        bandWidth,
        size.height * 2.1,
      );
      paint.color = _mixColor(i).withValues(
        alpha: recipe.opacity * (i.isEven ? 0.62 : 0.34),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(size.width * 0.04)),
        paint,
      );
    }
  }

  void _paintRadialSun(Canvas canvas, Size size, Paint paint) {
    final center = _anchor(size);
    final rays = (18 + recipe.density * 28).round();
    final radius = size.width * (0.38 + recipe.scale * 0.25);
    paint
      ..style = PaintingStyle.stroke
      ..strokeWidth = recipe.strokeWidth;

    for (var i = 0; i < rays; i++) {
      final t = (math.pi * 2 * i / rays) + recipe.seed * 0.04;
      final start = center + Offset(math.cos(t), math.sin(t)) * radius * 0.25;
      final end = center + Offset(math.cos(t), math.sin(t)) * radius;
      paint.color = _mixColor(i).withValues(
        alpha: recipe.opacity * (0.35 + (i % 4) * 0.12),
      );
      canvas.drawLine(start, end, paint);
    }

    paint
      ..style = PaintingStyle.fill
      ..color = primary.withValues(alpha: recipe.opacity * 0.55);
    canvas.drawCircle(center, radius * 0.17, paint);
  }

  void _paintDotConstellation(Canvas canvas, Size size, Paint paint) {
    final cols = (8 + recipe.density * 10).round();
    final rows = (4 + recipe.density * 7).round();
    final rng = math.Random(recipe.seed);
    paint.style = PaintingStyle.fill;

    for (var row = 0; row < rows; row++) {
      for (var col = 0; col < cols; col++) {
        final x = (col + 0.5) * size.width / cols;
        final y = (row + 0.5) * size.height / rows;
        final jitter = Offset(
          (rng.nextDouble() - 0.5) * size.width / cols * 0.55,
          (rng.nextDouble() - 0.5) * size.height / rows * 0.55,
        );
        final radius = _min(size) * (0.009 + rng.nextDouble() * 0.018);
        paint.color = _mixColor(row + col).withValues(
          alpha: recipe.opacity * (0.45 + rng.nextDouble() * 0.35),
        );
        canvas.drawCircle(Offset(x, y) + jitter, radius, paint);
      }
    }
  }

  void _paintDiamondMesh(Canvas canvas, Size size, Paint paint) {
    final gap = _min(size) * (0.16 - recipe.density * 0.035).clamp(0.07, 0.16);
    paint
      ..style = PaintingStyle.stroke
      ..strokeWidth = recipe.strokeWidth
      ..color = primary.withValues(alpha: recipe.opacity * 0.70);

    for (var x = -size.width; x < size.width * 2; x += gap) {
      canvas.drawLine(Offset(x, -size.height),
          Offset(x + size.height, size.height * 2), paint);
      canvas.drawLine(Offset(x, size.height * 2),
          Offset(x + size.height, -size.height), paint);
    }

    paint
      ..style = PaintingStyle.fill
      ..color = secondary.withValues(alpha: recipe.opacity * 0.18);
    for (var x = gap; x < size.width; x += gap * 2) {
      for (var y = gap; y < size.height; y += gap * 2) {
        canvas.drawCircle(Offset(x, y), gap * 0.08, paint);
      }
    }
  }

  void _paintCircuitTrace(Canvas canvas, Size size, Paint paint) {
    final lanes = (5 + recipe.density * 8).round();
    final rng = math.Random(recipe.seed);
    paint
      ..style = PaintingStyle.stroke
      ..strokeWidth = recipe.strokeWidth;

    for (var lane = 0; lane < lanes; lane++) {
      final path = Path();
      var x = -size.width * 0.05;
      var y = size.height * (0.12 + lane / lanes * 0.78);
      path.moveTo(x, y);
      for (var step = 0; step < 5; step++) {
        x += size.width * (0.13 + rng.nextDouble() * 0.12);
        path.lineTo(x, y);
        y += (rng.nextBool() ? 1 : -1) *
            size.height *
            (0.04 + rng.nextDouble() * 0.08);
        path.lineTo(x, y);
      }
      path.lineTo(size.width * 1.08, y);
      paint.color = _mixColor(lane).withValues(alpha: recipe.opacity * 0.58);
      canvas.drawPath(path, paint);

      paint
        ..style = PaintingStyle.fill
        ..color = secondary.withValues(alpha: recipe.opacity * 0.55);
      canvas.drawCircle(
          Offset(x.clamp(0, size.width), y.clamp(0, size.height)), 3.5, paint);
      paint.style = PaintingStyle.stroke;
    }
  }

  void _paintChevronVault(Canvas canvas, Size size, Paint paint) {
    final count = (6 + recipe.density * 12).round();
    final gap = size.width / (count + 2);
    paint
      ..style = PaintingStyle.stroke
      ..strokeWidth = recipe.strokeWidth * 1.25;

    for (var i = 0; i < count; i++) {
      final x = gap * (i + 1);
      final h = size.height * (0.28 + (i % 3) * 0.08);
      final midY = size.height * (recipe.alternate ? 0.42 : 0.58);
      final path = Path()
        ..moveTo(x - gap * 0.55, midY - h * 0.5)
        ..lineTo(x, midY)
        ..lineTo(x - gap * 0.55, midY + h * 0.5);
      paint.color = _mixColor(i)
          .withValues(alpha: recipe.opacity * (0.42 + i / count * 0.28));
      canvas.drawPath(path, paint);
    }
  }

  void _paintTempleSteps(Canvas canvas, Size size, Paint paint) {
    final steps = (5 + recipe.density * 10).round();
    final base = _anchor(size);
    paint.style = PaintingStyle.fill;

    for (var i = 0; i < steps; i++) {
      final width = size.width * (0.18 + i * 0.055 * recipe.scale);
      final height = size.height * (0.035 + recipe.scale * 0.012);
      final rect = Rect.fromCenter(
        center: Offset(base.dx, base.dy + i * height * 1.3),
        width: width,
        height: height,
      );
      paint.color =
          _mixColor(i).withValues(alpha: recipe.opacity * (0.65 - i * 0.025));
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(height / 2)),
        paint,
      );
    }
  }

  void _paintOrbit(Canvas canvas, Size size, Paint paint) {
    final center = _anchor(size);
    final rings = (5 + recipe.density * 9).round();
    paint
      ..style = PaintingStyle.stroke
      ..strokeWidth = recipe.strokeWidth;

    for (var i = 0; i < rings; i++) {
      final rect = Rect.fromCenter(
        center: center,
        width: size.width * recipe.scale * (0.25 + i * 0.095),
        height: size.height * recipe.scale * (0.12 + i * 0.048),
      );
      paint.color =
          _mixColor(i).withValues(alpha: recipe.opacity * (0.72 - i * 0.045));
      canvas.drawOval(rect, paint);
    }

    paint
      ..style = PaintingStyle.fill
      ..color = secondary.withValues(alpha: recipe.opacity * 0.58);
    canvas.drawCircle(
      center + Offset(size.width * recipe.scale * 0.26, -size.height * 0.06),
      _min(size) * 0.025,
      paint,
    );
  }

  void _paintCoinStack(Canvas canvas, Size size, Paint paint) {
    final center = _anchor(size);
    final count = (5 + recipe.density * 9).round();
    paint
      ..style = PaintingStyle.stroke
      ..strokeWidth = recipe.strokeWidth;

    for (var i = 0; i < count; i++) {
      final rect = Rect.fromCenter(
        center:
            center + Offset(i * size.width * 0.025, i * size.height * 0.035),
        width: size.width * (0.36 + recipe.scale * 0.12),
        height: size.height * (0.22 + recipe.scale * 0.06),
      );
      paint.color =
          _mixColor(i).withValues(alpha: recipe.opacity * (0.68 - i * 0.035));
      canvas.drawOval(rect, paint);
    }
  }

  void _paintLotusMandala(Canvas canvas, Size size, Paint paint) {
    final center = _anchor(size);
    final petals = (10 + recipe.density * 12).round();
    final radius = _min(size) * recipe.scale * 0.56;
    paint.style = PaintingStyle.fill;

    for (var layer = 0; layer < 3; layer++) {
      final layerRadius = radius * (1 - layer * 0.20);
      for (var i = 0; i < petals; i++) {
        final t = math.pi * 2 * i / petals + layer * 0.12;
        final petalCenter =
            center + Offset(math.cos(t), math.sin(t)) * layerRadius * 0.42;
        final rect = Rect.fromCenter(
          center: petalCenter,
          width: layerRadius * 0.28,
          height: layerRadius * 0.74,
        );
        canvas.save();
        canvas.translate(petalCenter.dx, petalCenter.dy);
        canvas.rotate(t);
        canvas.translate(-petalCenter.dx, -petalCenter.dy);
        paint.color = _mixColor(i + layer).withValues(
          alpha: recipe.opacity * (0.42 - layer * 0.08),
        );
        canvas.drawOval(rect, paint);
        canvas.restore();
      }
    }
  }

  void _paintInfinityLoop(Canvas canvas, Size size, Paint paint) {
    final center = _anchor(size);
    final width = size.width * recipe.scale * 0.72;
    final height = size.height * recipe.scale * 0.40;
    final paths = (5 + recipe.density * 7).round();

    paint
      ..style = PaintingStyle.stroke
      ..strokeWidth = recipe.strokeWidth * 1.2;

    for (var loop = 0; loop < paths; loop++) {
      final inset = loop * _min(size) * 0.026;
      final path = Path();
      const steps = 160;
      for (var i = 0; i <= steps; i++) {
        final t = (math.pi * 2 * i) / steps;
        final denom = 1 + math.sin(t) * math.sin(t);
        final x = center.dx + math.cos(t) * (width - inset) / denom;
        final y =
            center.dy + math.sin(t) * math.cos(t) * (height - inset) / denom;
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      paint.color = _mixColor(loop).withValues(
        alpha: recipe.opacity * (0.68 - loop * 0.065),
      );
      canvas.drawPath(path, paint);
    }
  }

  void _paintPeacockEye(Canvas canvas, Size size, Paint paint) {
    final center = _anchor(size);
    final featherCount = (6 + recipe.density * 9).round();
    paint.style = PaintingStyle.stroke;

    for (var i = 0; i < featherCount; i++) {
      final t = -math.pi * 0.75 + i * math.pi * 1.5 / featherCount;
      final end = center +
          Offset(math.cos(t), math.sin(t)) * size.width * recipe.scale * 0.52;
      final control = center +
          Offset(math.cos(t - 0.55), math.sin(t - 0.55)) *
              size.width *
              recipe.scale *
              0.35;
      final path = Path()
        ..moveTo(center.dx, center.dy)
        ..quadraticBezierTo(control.dx, control.dy, end.dx, end.dy);
      paint
        ..strokeWidth = recipe.strokeWidth
        ..color = _mixColor(i).withValues(alpha: recipe.opacity * 0.70);
      canvas.drawPath(path, paint);

      paint
        ..style = PaintingStyle.fill
        ..color = _mixColor(i + 1).withValues(alpha: recipe.opacity * 0.48);
      canvas.drawOval(
        Rect.fromCenter(
          center: end,
          width: _min(size) * 0.12,
          height: _min(size) * 0.07,
        ),
        paint,
      );
      paint.style = PaintingStyle.stroke;
    }
  }

  void _paintFacetedShard(Canvas canvas, Size size, Paint paint) {
    final rng = math.Random(recipe.seed);
    final count = (8 + recipe.density * 14).round();
    paint.style = PaintingStyle.fill;

    for (var i = 0; i < count; i++) {
      final cx = size.width * (rng.nextDouble() * 1.1 - 0.05);
      final cy = size.height * (rng.nextDouble() * 1.1 - 0.05);
      final w = size.width * (0.12 + rng.nextDouble() * 0.28) * recipe.scale;
      final h = size.height * (0.10 + rng.nextDouble() * 0.24) * recipe.scale;
      final path = Path()
        ..moveTo(cx, cy - h * 0.5)
        ..lineTo(cx + w * 0.55, cy - h * 0.15)
        ..lineTo(cx + w * 0.28, cy + h * 0.54)
        ..lineTo(cx - w * 0.52, cy + h * 0.28)
        ..close();
      paint.color = _mixColor(i).withValues(
        alpha: recipe.opacity * (0.18 + rng.nextDouble() * 0.32),
      );
      canvas.drawPath(path, paint);
    }
  }

  void _paintWovenBraid(Canvas canvas, Size size, Paint paint) {
    final strands = (5 + recipe.density * 8).round();
    final step = size.width / (strands + 1);
    paint
      ..style = PaintingStyle.stroke
      ..strokeWidth = recipe.strokeWidth * 2.0;

    for (var i = 0; i < strands; i++) {
      final x = step * (i + 1);
      final path = Path()..moveTo(x, -size.height * 0.08);
      for (var y = -size.height * 0.08; y < size.height * 1.1; y += 12) {
        final wave =
            math.sin(y / size.height * math.pi * 4 + i * 0.70 + recipe.seed);
        path.lineTo(x + wave * step * 0.35, y);
      }
      paint.color = _mixColor(i).withValues(alpha: recipe.opacity * 0.62);
      canvas.drawPath(path, paint);
    }
  }

  void _paintSkylineBars(Canvas canvas, Size size, Paint paint) {
    final count = (10 + recipe.density * 18).round();
    final width = size.width / count;
    final rng = math.Random(recipe.seed);
    paint.style = PaintingStyle.fill;

    for (var i = 0; i < count; i++) {
      final h = size.height * (0.20 + rng.nextDouble() * 0.62);
      final left = i * width;
      final top = recipe.alternate ? 0.0 : size.height - h;
      paint.color = _mixColor(i).withValues(
        alpha: recipe.opacity * (0.25 + rng.nextDouble() * 0.35),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(left + width * 0.16, top, width * 0.56, h),
          Radius.circular(width * 0.28),
        ),
        paint,
      );
    }
  }

  void _paintPortalArcs(Canvas canvas, Size size, Paint paint) {
    final center = _anchor(size);
    final count = (7 + recipe.density * 14).round();
    paint
      ..style = PaintingStyle.stroke
      ..strokeWidth = recipe.strokeWidth * 1.35;

    for (var i = 0; i < count; i++) {
      final w = size.width * recipe.scale * (0.20 + i * 0.055);
      final h = size.height * recipe.scale * (0.30 + i * 0.050);
      final rect = Rect.fromCenter(center: center, width: w, height: h);
      paint.color = _mixColor(i).withValues(
        alpha: recipe.opacity * (0.72 - i * 0.035),
      );
      canvas.drawArc(rect, math.pi, math.pi, false, paint);
      canvas.drawLine(
        Offset(center.dx - w / 2, center.dy),
        Offset(center.dx - w / 2, center.dy + h * 0.28),
        paint,
      );
      canvas.drawLine(
        Offset(center.dx + w / 2, center.dy),
        Offset(center.dx + w / 2, center.dy + h * 0.28),
        paint,
      );
    }
  }

  void _paintHexBloom(Canvas canvas, Size size, Paint paint) {
    final center = _anchor(size);
    final rings = (3 + recipe.density * 5).round();
    final unit = _min(size) * 0.075 * recipe.scale;
    paint
      ..style = PaintingStyle.stroke
      ..strokeWidth = recipe.strokeWidth;

    for (var ring = 0; ring < rings; ring++) {
      final cells = ring == 0 ? 1 : ring * 6;
      for (var i = 0; i < cells; i++) {
        final t = cells == 1 ? 0.0 : math.pi * 2 * i / cells;
        final pos = center +
            Offset(math.cos(t), math.sin(t)) * unit * ring.toDouble() * 1.6;
        paint.color = _mixColor(i + ring).withValues(
          alpha: recipe.opacity * (0.70 - ring * 0.08),
        );
        _drawPolygon(canvas, paint, pos, unit, 6, math.pi / 6);
      }
    }
  }

  void _paintMagneticField(Canvas canvas, Size size, Paint paint) {
    final left = Offset(size.width * 0.26, size.height * 0.50);
    final right = Offset(size.width * 0.74, size.height * 0.50);
    final lines = (8 + recipe.density * 14).round();
    paint
      ..style = PaintingStyle.stroke
      ..strokeWidth = recipe.strokeWidth;

    for (var i = 0; i < lines; i++) {
      final spread = (i - lines / 2) / lines;
      final path = Path()
        ..moveTo(left.dx, left.dy + spread * size.height * 0.72)
        ..cubicTo(
          size.width * 0.34,
          size.height * (0.08 + spread * 0.25),
          size.width * 0.66,
          size.height * (0.92 + spread * 0.25),
          right.dx,
          right.dy - spread * size.height * 0.72,
        );
      paint.color = _mixColor(i).withValues(
        alpha: recipe.opacity * (0.45 + (lines - i).abs() / lines * 0.16),
      );
      canvas.drawPath(path, paint);
    }
  }

  void _paintMonsoonTopo(Canvas canvas, Size size, Paint paint) {
    final bands = (8 + recipe.density * 15).round();
    paint
      ..style = PaintingStyle.stroke
      ..strokeWidth = recipe.strokeWidth;

    for (var band = 0; band < bands; band++) {
      final yBase = size.height * (band + 0.5) / bands;
      final path = Path();
      for (var x = -size.width * 0.08; x <= size.width * 1.08; x += 8) {
        final n1 =
            math.sin(x / size.width * math.pi * 2.6 + band + recipe.seed);
        final n2 = math.sin(x / size.width * math.pi * 7.2 + band * 0.5);
        final y = yBase + (n1 * 0.65 + n2 * 0.35) * size.height * 0.035;
        if (x <= -size.width * 0.07) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      paint.color = _mixColor(band).withValues(alpha: recipe.opacity * 0.58);
      canvas.drawPath(path, paint);
    }
  }

  void _drawPolygon(
    Canvas canvas,
    Paint paint,
    Offset center,
    double radius,
    int sides,
    double rotation,
  ) {
    final path = Path();
    for (var i = 0; i <= sides; i++) {
      final t = rotation + math.pi * 2 * i / sides;
      final point = center + Offset(math.cos(t), math.sin(t)) * radius;
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    canvas.drawPath(path, paint);
  }

  void _paintBoldDiagonalBands(Canvas canvas, Size size, Paint paint) {
    final count = (3 + recipe.density * 4).round();
    final bandWidth = size.width * (0.20 + recipe.scale * 0.05);
    paint.style = PaintingStyle.fill;

    canvas.save();
    canvas.rotate(-0.78 + recipe.angle * 0.35);
    canvas.translate(-size.width * 0.62, size.height * 0.05);
    for (var i = 0; i < count; i++) {
      final x = i * bandWidth * 0.92;
      final rect = Rect.fromLTWH(
        x,
        -size.height * 0.85,
        bandWidth,
        size.height * 2.5,
      );
      paint.color = _mixColor(i).withValues(
        alpha: recipe.opacity * (0.92 - i * 0.12),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(size.width * 0.02)),
        paint,
      );
    }
    canvas.restore();
  }

  void _paintCornerArcBands(Canvas canvas, Size size, Paint paint) {
    final center = Offset(
      size.width * recipe.anchor.dx,
      size.height * recipe.anchor.dy,
    );
    final count = (3 + recipe.density * 5).round();
    paint.style = PaintingStyle.fill;

    for (var i = count - 1; i >= 0; i--) {
      final radius = size.width * recipe.scale * (0.28 + i * 0.17);
      paint.color = _mixColor(i).withValues(
        alpha: recipe.opacity * (0.34 + (count - i) * 0.08),
      );
      canvas.drawCircle(center, radius, paint);
    }

    paint.color = Colors.black.withValues(alpha: 0.05);
    canvas.drawCircle(center, size.width * recipe.scale * 0.17, paint);
  }

  void _paintSoftWavePlanes(Canvas canvas, Size size, Paint paint) {
    final count = (3 + recipe.density * 4).round();
    paint.style = PaintingStyle.fill;

    for (var i = 0; i < count; i++) {
      final top = size.height * (-0.12 + i * 0.18);
      final depth = size.height * (0.34 + recipe.scale * 0.05);
      final path = Path()
        ..moveTo(-size.width * 0.08, top)
        ..cubicTo(
          size.width * 0.22,
          top + depth * (recipe.alternate ? 0.9 : 0.35),
          size.width * 0.62,
          top - depth * 0.20,
          size.width * 1.08,
          top + depth * 0.48,
        )
        ..lineTo(size.width * 1.08, top + depth * 1.18)
        ..cubicTo(
          size.width * 0.64,
          top + depth * 0.54,
          size.width * 0.25,
          top + depth * 1.20,
          -size.width * 0.08,
          top + depth * 0.55,
        )
        ..close();
      paint.color = _mixColor(i).withValues(
        alpha: recipe.opacity * (0.78 - i * 0.10),
      );
      canvas.drawPath(path, paint);
    }
  }

  void _paintCrescentSweep(Canvas canvas, Size size, Paint paint) {
    final center = _anchor(size);
    final radius = size.width * recipe.scale * 0.68;
    paint.style = PaintingStyle.fill;

    for (var i = 0; i < 4; i++) {
      final rect = Rect.fromCircle(
        center: center + Offset(i * size.width * 0.06, i * size.height * 0.03),
        radius: radius * (1 - i * 0.16),
      );
      paint.color = _mixColor(i).withValues(
        alpha: recipe.opacity * (0.50 - i * 0.07),
      );
      canvas.drawArc(rect, -math.pi * 0.05, math.pi * 1.12, true, paint);
    }
  }

  void _paintFoldedPlanes(Canvas canvas, Size size, Paint paint) {
    final rng = math.Random(recipe.seed);
    final count = (4 + recipe.density * 5).round();
    paint.style = PaintingStyle.fill;

    for (var i = 0; i < count; i++) {
      final x = size.width * (rng.nextDouble() * 0.85 - 0.15);
      final y = size.height * (rng.nextDouble() * 0.65 - 0.10);
      final w = size.width * (0.30 + rng.nextDouble() * 0.32) * recipe.scale;
      final h = size.height * (0.28 + rng.nextDouble() * 0.28) * recipe.scale;
      final path = Path()
        ..moveTo(x, y)
        ..lineTo(x + w, y + h * 0.12)
        ..lineTo(x + w * 0.72, y + h)
        ..lineTo(x - w * 0.20, y + h * 0.72)
        ..close();
      paint.color = _mixColor(i).withValues(
        alpha: recipe.opacity * (0.30 + rng.nextDouble() * 0.32),
      );
      canvas.drawPath(path, paint);
    }
  }

  void _paintSplitOvalPlanes(Canvas canvas, Size size, Paint paint) {
    final center = _anchor(size);
    final count = (3 + recipe.density * 4).round();
    paint.style = PaintingStyle.fill;

    for (var i = count - 1; i >= 0; i--) {
      final rect = Rect.fromCenter(
        center: center + Offset(i * size.width * 0.03, i * size.height * 0.02),
        width: size.width * recipe.scale * (0.58 + i * 0.18),
        height: size.height * recipe.scale * (0.72 + i * 0.20),
      );
      paint.color = _mixColor(i).withValues(
        alpha: recipe.opacity * (0.35 + (count - i) * 0.08),
      );
      canvas.drawOval(rect, paint);
    }

    paint.color = Colors.black.withValues(alpha: 0.08);
    canvas.drawRect(
      Rect.fromLTWH(
          center.dx, -size.height * 0.1, size.width, size.height * 1.2),
      paint,
    );
  }

  void _paintRibbonSweep(Canvas canvas, Size size, Paint paint) {
    paint.style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(-size.width * 0.1, size.height * 0.20)
      ..cubicTo(
        size.width * 0.28,
        -size.height * 0.18,
        size.width * 0.55,
        size.height * 0.35,
        size.width * 1.1,
        size.height * 0.02,
      )
      ..lineTo(size.width * 1.1, size.height * 0.32)
      ..cubicTo(
        size.width * 0.58,
        size.height * 0.62,
        size.width * 0.32,
        size.height * 0.12,
        -size.width * 0.1,
        size.height * 0.50,
      )
      ..close();
    paint.color = primary.withValues(alpha: recipe.opacity * 0.80);
    canvas.drawPath(path, paint);

    final second = Path()
      ..moveTo(-size.width * 0.1, size.height * 0.58)
      ..cubicTo(
        size.width * 0.28,
        size.height * 0.28,
        size.width * 0.62,
        size.height * 0.92,
        size.width * 1.1,
        size.height * 0.52,
      )
      ..lineTo(size.width * 1.1, size.height * 0.78)
      ..cubicTo(
        size.width * 0.60,
        size.height * 1.08,
        size.width * 0.28,
        size.height * 0.52,
        -size.width * 0.1,
        size.height * 0.82,
      )
      ..close();
    paint.color = secondary.withValues(alpha: recipe.opacity * 0.52);
    canvas.drawPath(second, paint);
  }

  void _paintStackedPanels(Canvas canvas, Size size, Paint paint) {
    final count = (4 + recipe.density * 5).round();
    final panelHeight = size.height * (0.18 + recipe.scale * 0.03);
    paint.style = PaintingStyle.fill;

    for (var i = 0; i < count; i++) {
      final rect = Rect.fromLTWH(
        -size.width * 0.12 + i * size.width * 0.07,
        size.height * (0.10 + i * 0.13),
        size.width * 1.10,
        panelHeight,
      );
      canvas.save();
      canvas.translate(rect.center.dx, rect.center.dy);
      canvas.rotate(-0.18 + recipe.angle * 0.20);
      canvas.translate(-rect.center.dx, -rect.center.dy);
      paint.color = _mixColor(i).withValues(
        alpha: recipe.opacity * (0.72 - i * 0.08),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(size.width * 0.035)),
        paint,
      );
      canvas.restore();
    }
  }

  void _paintLensGlow(Canvas canvas, Size size, Paint paint) {
    final center = _anchor(size);
    const count = 5;
    paint.style = PaintingStyle.fill;

    for (var i = count; i >= 0; i--) {
      final radius = size.width * recipe.scale * (0.12 + i * 0.12);
      paint.color = _mixColor(i).withValues(
        alpha: recipe.opacity * (0.12 + (count - i) * 0.035),
      );
      canvas.drawCircle(center, radius, paint);
    }

    paint.color = secondary.withValues(alpha: recipe.opacity * 0.26);
    canvas.drawOval(
      Rect.fromCenter(
        center: center + Offset(size.width * 0.16, -size.height * 0.05),
        width: size.width * 0.34,
        height: size.height * 0.18,
      ),
      paint,
    );
  }

  void _paintSteppedDiagonal(Canvas canvas, Size size, Paint paint) {
    final count = (4 + recipe.density * 6).round();
    final stepW = size.width * (0.17 + recipe.scale * 0.025);
    final stepH = size.height * (0.16 + recipe.scale * 0.020);
    paint.style = PaintingStyle.fill;

    for (var i = 0; i < count; i++) {
      final path = Path()
        ..moveTo(-size.width * 0.05 + i * stepW * 0.68, size.height * 1.05)
        ..lineTo(size.width * 0.22 + i * stepW * 0.68, size.height * 1.05)
        ..lineTo(size.width * 0.56 + i * stepW * 0.68, -size.height * 0.08)
        ..lineTo(size.width * 0.30 + i * stepW * 0.68, -size.height * 0.08)
        ..close();
      paint.color = _mixColor(i).withValues(
        alpha: recipe.opacity * (0.72 - i * 0.08),
      );
      canvas.drawPath(path, paint);

      if (recipe.alternate) {
        paint.color = Colors.white.withValues(alpha: recipe.opacity * 0.05);
        canvas.drawRect(
          Rect.fromLTWH(i * stepW * 0.60, i * stepH * 0.35, stepW, stepH),
          paint,
        );
      }
    }
  }

  void _paintFigmaPurpleOrbs(Canvas canvas, Size size, Paint paint) {
    paint.style = PaintingStyle.fill;
    final glow = Color.lerp(primary, Colors.white, 0.45)!;

    final lowerCenter =
        Offset(size.width * (170.5 / 350), size.height * (229.5 / 220));
    final lowerRadius = size.width * (189.5 / 350);
    paint.shader = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        glow.withValues(alpha: 0.34),
        Colors.white.withValues(alpha: 0),
      ],
      stops: const [0, 0.35],
    ).createShader(
      Rect.fromCircle(center: lowerCenter, radius: lowerRadius),
    );
    canvas.drawCircle(lowerCenter, lowerRadius, paint);
    paint.shader = null;

    paint.color =
        Color.lerp(secondary, Colors.white, 0.62)!.withValues(alpha: 0.26);
    canvas.drawCircle(
      Offset(size.width * (263 / 350), size.height * (-27 / 220)),
      size.width * (130 / 350),
      paint,
    );
  }

  void _paintFigmaCoralDiagonals(Canvas canvas, Size size, Paint paint) {
    paint.style = PaintingStyle.fill;
    final bands = [
      (-95.614, 81.6357, 108.699, 248.892, 0.05),
      (-18.0, 3.01428, 103.0, 334.0, 0.20),
      (65.0, -57.4685, 122.0, 431.0, 0.30),
      (215.0, -51.9675, 94.0, 389.0, 0.35),
    ];

    for (final band in bands) {
      final (x, y, width, height, alpha) = band;
      paint.color = Colors.white.withValues(alpha: alpha);
      _drawSvgRotatedRRect(
        canvas,
        paint,
        size,
        baseW: 350,
        baseH: 220,
        x: x,
        y: y,
        width: width,
        height: height,
        radius: 0,
        angleDeg: -33.61,
      );
    }
  }

  void _paintFigmaBlueBubbles(Canvas canvas, Size size, Paint paint) {
    paint.style = PaintingStyle.fill;
    final circles = [
      (80.0, 151.0, 77.0, 45.0, 88.0, 97.0, 172.0),
      (145.0, 94.0, 55.0, 113.0, 52.0, 153.0, 112.0),
      (150.0, 132.0, 43.0, 122.0, 96.0, 153.0, 150.0),
      (223.0, 140.0, 80.0, 258.0, 70.0, 199.0, 164.0),
    ];
    for (final circle in circles) {
      final (x, y, r, x1, y1, x2, y2) = circle;
      final center = _pt(size, 350, 220, x, y);
      final radius = size.width * r / 350;
      final light = Color.lerp(primary, Colors.white, 0.58)!;
      final shade = Color.lerp(secondary, Colors.black, 0.18)!;
      paint.shader = ui.Gradient.linear(
        _pt(size, 350, 220, x1, y1),
        _pt(size, 350, 220, x2, y2),
        [
          light.withValues(alpha: 0.64),
          shade.withValues(alpha: 0.22),
          Colors.white.withValues(alpha: 0),
        ],
        const [0, 0.68, 1],
      );
      canvas.drawCircle(center, radius, paint);
    }
    paint.shader = null;
  }

  void _paintFigmaMintChevrons(Canvas canvas, Size size, Paint paint) {
    paint.style = PaintingStyle.fill;
    void drawMatrixBlock({
      required double x,
      required double y,
      required double width,
      required double height,
      required double alpha,
    }) {
      const a = 0.707107;
      const b = -0.707107;
      const c = -0.707107;
      const d = -0.707107;
      Offset point(double px, double py) => _pt(
            size,
            336,
            200,
            x + a * px + c * py,
            y + b * px + d * py,
          );

      final bounds = Path()
        ..moveTo(point(0, 0).dx, point(0, 0).dy)
        ..lineTo(point(width, 0).dx, point(width, 0).dy)
        ..lineTo(point(width, height).dx, point(width, height).dy)
        ..lineTo(point(0, height).dx, point(0, height).dy)
        ..close();
      final high = Color.lerp(primary, Colors.white, 0.32)!;
      final low = Color.lerp(secondary, Colors.white, 0.58)!;
      paint.shader = LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [
          high.withValues(alpha: alpha * 0.62),
          low.withValues(alpha: alpha * 0.24),
        ],
      ).createShader(Offset.zero & size);
      canvas.drawPath(bounds, paint);
      paint.shader = null;
    }

    drawMatrixBlock(
      x: -10.4856,
      y: 291.477,
      width: 301.174,
      height: 215.688,
      alpha: 0.95,
    );
    drawMatrixBlock(
      x: 338.019,
      y: 235.981,
      width: 159.99,
      height: 114.578,
      alpha: 0.80,
    );
  }

  void _paintFigmaVioletArcs(Canvas canvas, Size size, Paint paint) {
    paint.style = PaintingStyle.fill;
    final topCenter = _pt(size, 336, 200, 70.5, 20.5);
    final topRadius = size.width * 126.5 / 336;
    paint.shader = LinearGradient(
      begin: Alignment.centerRight,
      end: Alignment.topLeft,
      colors: [
        Colors.white.withValues(alpha: 0.10),
        Colors.white.withValues(alpha: 0),
      ],
    ).createShader(Rect.fromCircle(center: topCenter, radius: topRadius));
    canvas.drawCircle(topCenter, topRadius, paint);
    paint.shader = null;

    paint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2 * size.width / 336
      ..color = Colors.white.withValues(alpha: 0.34);
    canvas.drawCircle(topCenter, topRadius, paint);

    final bottomCenter = _pt(size, 336, 200, 227.5, 189.5);
    final bottomRadius = size.width * 137.5 / 336;
    paint
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withValues(alpha: 0.40),
          Colors.white.withValues(alpha: 0),
        ],
        stops: const [0, 0.52],
      ).createShader(Rect.fromCircle(
        center: bottomCenter,
        radius: bottomRadius,
      ));
    canvas.drawCircle(bottomCenter, bottomRadius, paint);
    paint.shader = null;

    paint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2 * size.width / 336
      ..color = Colors.white.withValues(alpha: 0.32);
    canvas.drawCircle(bottomCenter, size.width * 136.5 / 336, paint);
  }

  void _paintFigmaLimeSlashes(Canvas canvas, Size size, Paint paint) {
    paint.style = PaintingStyle.fill;
    final pale = Color.lerp(primary, Colors.white, 0.72)!;
    final mid = Color.lerp(primary, secondary, 0.50)!;
    final bright = Color.lerp(secondary, Colors.white, 0.62)!;
    final slashes = [
      (
        99.4918,
        134.392,
        54.0,
        263.0,
        pale,
        0.64,
        false,
      ),
      (
        174.155,
        105.716,
        54.0,
        263.0,
        mid,
        0.58,
        false,
      ),
      (
        71.9858,
        7.54053,
        54.0,
        360.0,
        Colors.white,
        0.52,
        false,
      ),
      (
        169.917,
        -11.9916,
        54.0,
        206.0,
        bright,
        0.72,
        true,
      ),
    ];

    for (final slash in slashes) {
      final (x, y, width, height, color, alpha, invert) = slash;
      final origin = _pt(size, 336, 200, x, y);
      final rect = Rect.fromLTWH(
        0,
        0,
        size.width * width / 336,
        size.height * height / 200,
      );
      paint.shader = LinearGradient(
        begin: invert ? Alignment.topCenter : Alignment.bottomCenter,
        end: invert ? Alignment.bottomCenter : Alignment.topCenter,
        colors: [
          color.withValues(alpha: alpha),
          color.withValues(alpha: 0),
        ],
      ).createShader(rect);
      canvas.save();
      canvas.translate(origin.dx, origin.dy);
      canvas.rotate(-68.5442 * math.pi / 180);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          rect,
          Radius.circular(size.width * 27 / 336),
        ),
        paint,
      );
      canvas.restore();
      paint.shader = null;
    }
  }

  void _paintFigmaEmeraldBlocks(Canvas canvas, Size size, Paint paint) {
    paint.style = PaintingStyle.fill;
    double sx(double value) => size.width * value / 336;
    double sy(double value) => size.height * value / 200;

    Path blockOne() => Path()
      ..moveTo(sx(207), sy(59))
      ..lineTo(sx(90.0697), sy(59))
      ..cubicTo(sx(81.9904), sy(59), sx(74.2101), sy(62.0561), sx(68.2907),
          sy(67.5549))
      ..lineTo(sx(-10.779), sy(141.005))
      ..cubicTo(
          sx(-17.2968), sy(147.06), sx(-21), sy(155.554), sx(-21), sy(164.451))
      ..lineTo(sx(-21), sy(178.5))
      ..cubicTo(
          sx(-21), sy(196.173), sx(-6.67311), sy(210.5), sx(11), sy(210.5))
      ..lineTo(sx(155.62), sy(210.5))
      ..cubicTo(sx(165.341), sy(210.5), sx(174.535), sy(206.081), sx(180.608),
          sy(198.49))
      ..lineTo(sx(211.988), sy(159.265))
      ..cubicTo(
          sx(216.527), sy(153.591), sx(219), sy(146.541), sx(219), sy(139.275))
      ..lineTo(sx(219), sy(71))
      ..cubicTo(sx(219), sy(64.3726), sx(213.627), sy(59), sx(207), sy(59))
      ..close();

    Path blockTwo() => Path()
      ..moveTo(sx(308), sy(71))
      ..lineTo(sx(191.07), sy(71))
      ..cubicTo(
          sx(182.99), sy(71), sx(175.21), sy(74.0561), sx(169.291), sy(79.5549))
      ..lineTo(sx(90.221), sy(153.005))
      ..cubicTo(
          sx(83.7032), sy(159.06), sx(80), sy(167.554), sx(80), sy(176.451))
      ..lineTo(sx(80), sy(190.5))
      ..cubicTo(sx(80), sy(208.173), sx(94.3269), sy(222.5), sx(112), sy(222.5))
      ..lineTo(sx(256.62), sy(222.5))
      ..cubicTo(sx(266.341), sy(222.5), sx(275.535), sy(218.081), sx(281.608),
          sy(210.49))
      ..lineTo(sx(312.988), sy(171.265))
      ..cubicTo(
          sx(317.527), sy(165.591), sx(320), sy(158.541), sx(320), sy(151.275))
      ..lineTo(sx(320), sy(83))
      ..cubicTo(sx(320), sy(76.3726), sx(314.627), sy(71), sx(308), sy(71))
      ..close();

    paint.color = Colors.black.withValues(alpha: 0.24);
    canvas.drawPath(blockOne(), paint);
    paint.color =
        Color.lerp(secondary, Colors.white, 0.25)!.withValues(alpha: 0.20);
    canvas.drawPath(blockTwo(), paint);
  }

  void _paintFigmaNoirRings(Canvas canvas, Size size, Paint paint) {
    paint.style = PaintingStyle.fill;
    final rings = [
      (363.727, 185.239, 90.5),
      (347.492, 173.559, 110.5),
      (331.257, 161.879, 130.5),
      (314.21, 149.615, 151.5),
      (296.465, 137.465, 173.0),
    ];
    for (final ring in rings) {
      final (x, y, r) = ring;
      paint.color = const Color(0xFFD9D9D9).withValues(alpha: 0.04);
      canvas.drawCircle(
        _pt(size, 336, 200, x, y),
        size.width * r / 336,
        paint,
      );
    }
  }

  void _paintFigmaBronzeArcs(Canvas canvas, Size size, Paint paint) {
    paint.style = PaintingStyle.fill;
    final bigCenter = _pt(size, 336, 200, 47, 100);
    final bigRadius = size.width * 218 / 336;
    final warm = Color.lerp(primary, Colors.white, 0.24)!;
    final deep = Color.lerp(secondary, Colors.black, 0.20)!;
    paint.shader = LinearGradient(
      begin: Alignment.centerRight,
      end: Alignment.centerLeft,
      colors: [
        warm.withValues(alpha: 0.76),
        deep.withValues(alpha: 0),
      ],
    ).createShader(Rect.fromCircle(center: bigCenter, radius: bigRadius));
    canvas.drawCircle(bigCenter, bigRadius, paint);
    paint.shader = null;

    final smallCenter = _pt(size, 336, 200, 296, 238);
    final smallRadius = size.width * 103 / 336;
    paint.shader = LinearGradient(
      begin: Alignment.centerRight,
      end: Alignment.centerLeft,
      colors: [
        warm.withValues(alpha: 0.42),
        deep.withValues(alpha: 0),
      ],
    ).createShader(Rect.fromCircle(center: smallCenter, radius: smallRadius));
    canvas.drawCircle(smallCenter, smallRadius, paint);
    paint.shader = null;
  }

  void _paintFigmaGoldSplit(Canvas canvas, Size size, Paint paint) {
    paint.style = PaintingStyle.fill;
    final high = Color.lerp(primary, Colors.white, 0.22)!;
    final low = Color.lerp(secondary, Colors.black, 0.26)!;
    final splitY = size.height * 0.415;
    final ledgeHeight = size.height * 0.055;
    final ledgeWidth = size.width * 0.78;

    paint.color = high.withValues(alpha: 0.92);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, splitY), paint);
    paint.color = low.withValues(alpha: 0.96);
    canvas.drawRect(
      Rect.fromLTWH(0, splitY, size.width, size.height - splitY),
      paint,
    );

    paint.shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.black.withValues(alpha: 0.00),
        Colors.black.withValues(alpha: 0.18),
        Colors.black.withValues(alpha: 0.00),
      ],
      stops: const [0, 0.28, 1],
    ).createShader(
      Rect.fromLTWH(0, splitY - ledgeHeight * 0.28, ledgeWidth, ledgeHeight),
    );
    canvas.drawRect(
      Rect.fromLTWH(0, splitY - ledgeHeight * 0.28, ledgeWidth, ledgeHeight),
      paint,
    );
    paint.shader = null;

    paint.shader = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        Colors.white.withValues(alpha: 0.00),
        Colors.white.withValues(alpha: 0.10),
        Colors.white.withValues(alpha: 0.00),
      ],
      stops: const [0, 0.72, 1],
    ).createShader(Rect.fromLTWH(0, splitY - 1, ledgeWidth, 2));
    canvas.drawRect(Rect.fromLTWH(0, splitY - 1, ledgeWidth, 2), paint);
    paint.shader = null;
  }

  void _paintFigmaSoftVerticalStripes(Canvas canvas, Size size, Paint paint) {
    paint.style = PaintingStyle.fill;
    paint.color = Colors.white.withValues(alpha: 0.86);
    canvas.drawRect(Offset.zero & size, paint);
    final colors = [
      Color.lerp(primary, Colors.white, 0.10)!,
      Color.lerp(primary, secondary, 0.32)!,
      Color.lerp(primary, Colors.white, 0.56)!,
      Color.lerp(secondary, Colors.white, 0.70)!,
      Color.lerp(secondary, Colors.white, 0.86)!,
    ];
    const stripeWidth = 64.2;
    for (var i = 0; i < colors.length; i++) {
      paint.color = colors[i].withValues(alpha: 0.92);
      canvas.drawRect(
        _rect(size, 321, 202.57, i * stripeWidth, 0, stripeWidth + 0.5, 202.57),
        paint,
      );
    }
  }

  void _paintFigmaRedLiquid(Canvas canvas, Size size, Paint paint) {
    paint.style = PaintingStyle.fill;
    paint.color =
        Color.lerp(secondary, Colors.white, 0.20)!.withValues(alpha: 0.62);
    _drawSvgRotatedRRect(
      canvas,
      paint,
      size,
      baseW: 338,
      baseH: 203,
      x: -50.2394,
      y: -54.4368,
      width: 240.186,
      height: 155.887,
      radius: 45.7699,
      angleDeg: -19.5232,
    );
    _drawSvgRotatedRRect(
      canvas,
      paint,
      size,
      baseW: 338,
      baseH: 203,
      x: 147.031,
      y: 153.688,
      width: 192.717,
      height: 125.078,
      radius: 36.7241,
      angleDeg: -10.0066,
    );
  }

  @override
  bool shouldRepaint(covariant CreativeBankPatternPainter oldDelegate) {
    return oldDelegate.recipe != recipe ||
        oldDelegate.primary != primary ||
        oldDelegate.secondary != secondary ||
        oldDelegate.motifOverride != motifOverride;
  }
}
