import 'package:flutter/material.dart';

enum BankPatternType {
  dualCircle,        // Pattern 1
  quadCircle,        // Pattern 2
  intersectRects,    // Pattern 3
  concentricArcs,    // Pattern 4
  rightDualCircles,  // Pattern 5
  angledTiles,       // Pattern 6
}

/* -------------------------------------------------------------------------- */
/*                               CONFIG MODELS                                 */
/* -------------------------------------------------------------------------- */

class DualCircleConfig {
  final Offset bigCenter;
  final double bigRadius;
  final Color bigColor;
  final double bigOpacity;

  final Offset smallCenter;
  final double smallRadius;
  final Color smallColor;
  final double smallOpacity;

  const DualCircleConfig({
    required this.bigCenter,
    required this.bigRadius,
    required this.bigColor,
    required this.bigOpacity,
    required this.smallCenter,
    required this.smallRadius,
    required this.smallColor,
    required this.smallOpacity,
  });
}

class QuadCircleConfig {
  final Offset center;
  final List<double> radii;
  final List<double> opacities;
  final Color color;

  const QuadCircleConfig({
    required this.center,
    required this.radii,
    required this.opacities,
    required this.color,
  }) : assert(radii.length == opacities.length);
}

class IntersectRectConfig {
  final Offset leftOffset;
  final Offset rightOffset;
  final double rectWidth;
  final double rectHeight;
  final Color color;
  final double leftOpacity;
  final double rightOpacity;

  const IntersectRectConfig({
    required this.leftOffset,
    required this.rightOffset,
    required this.rectWidth,
    required this.rectHeight,
    required this.color,
    required this.leftOpacity,
    required this.rightOpacity,
  });
}

class ConcentricArcConfig {
  final Offset center;
  final int ringCount;
  final double startRadius;
  final double gap;
  final double strokeWidth;
  final Color color;
  final double startOpacity;
  final double opacityStep;

  const ConcentricArcConfig({
    required this.center,
    required this.ringCount,
    required this.startRadius,
    required this.gap,
    required this.strokeWidth,
    required this.color,
    required this.startOpacity,
    required this.opacityStep,
  });
}

class RightDualCircleConfig {
  final Offset primaryCenter;
  final double primaryRadius;
  final double primaryOpacity;

  final Offset secondaryCenter;
  final double secondaryRadius;
  final double secondaryOpacity;

  final Color color;

  const RightDualCircleConfig({
    required this.primaryCenter,
    required this.primaryRadius,
    required this.primaryOpacity,
    required this.secondaryCenter,
    required this.secondaryRadius,
    required this.secondaryOpacity,
    required this.color,
  });
}

class AngledTileRectConfig {
  final Offset center;
  final double height;
  final List<double> widths;
  final List<double> opacities;
  final double angle;
  final Color color;

  const AngledTileRectConfig({
    required this.center,
    required this.height,
    required this.widths,
    required this.opacities,
    required this.angle,
    required this.color,
  }) : assert(widths.length == opacities.length);
}

/* -------------------------------------------------------------------------- */
/*                              PATTERN PAINTER                                */
/* -------------------------------------------------------------------------- */

class BankPatternPainter extends CustomPainter {
  final BankPatternType type;

  final DualCircleConfig? dualConfig;
  final QuadCircleConfig? quadConfig;
  final IntersectRectConfig? rectConfig;
  final ConcentricArcConfig? arcConfig;
  final RightDualCircleConfig? rightDualConfig;
  final AngledTileRectConfig? angledTileConfig;

  const BankPatternPainter.dual({required this.dualConfig})
      : type = BankPatternType.dualCircle,
        quadConfig = null,
        rectConfig = null,
        arcConfig = null,
        rightDualConfig = null,
        angledTileConfig = null;

  const BankPatternPainter.quad({required this.quadConfig})
      : type = BankPatternType.quadCircle,
        dualConfig = null,
        rectConfig = null,
        arcConfig = null,
        rightDualConfig = null,
        angledTileConfig = null;

  const BankPatternPainter.rects({required this.rectConfig})
      : type = BankPatternType.intersectRects,
        dualConfig = null,
        quadConfig = null,
        arcConfig = null,
        rightDualConfig = null,
        angledTileConfig = null;

  const BankPatternPainter.arcs({required this.arcConfig})
      : type = BankPatternType.concentricArcs,
        dualConfig = null,
        quadConfig = null,
        rectConfig = null,
        rightDualConfig = null,
        angledTileConfig = null;

  const BankPatternPainter.rightDual({required this.rightDualConfig})
      : type = BankPatternType.rightDualCircles,
        dualConfig = null,
        quadConfig = null,
        rectConfig = null,
        arcConfig = null,
        angledTileConfig = null;

  const BankPatternPainter.angledTiles({required this.angledTileConfig})
      : type = BankPatternType.angledTiles,
        dualConfig = null,
        quadConfig = null,
        rectConfig = null,
        arcConfig = null,
        rightDualConfig = null;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..isAntiAlias = true;

    switch (type) {
      case BankPatternType.dualCircle:
        _paintDual(canvas, size, paint);
        break;
      case BankPatternType.quadCircle:
        _paintQuad(canvas, size, paint);
        break;
      case BankPatternType.intersectRects:
        _paintRects(canvas, size, paint);
        break;
      case BankPatternType.concentricArcs:
        _paintArcs(canvas, size, paint);
        break;
      case BankPatternType.rightDualCircles:
        _paintRightDual(canvas, size, paint);
        break;
      case BankPatternType.angledTiles:
        _paintAngledTiles(canvas, size, paint);
        break;
    }
  }

  /* ---------------------------- Pattern 1 ---------------------------- */

  void _paintDual(Canvas canvas, Size size, Paint paint) {
    final c = dualConfig!;
    paint.style = PaintingStyle.fill;

    paint.color = c.bigColor.withValues(alpha: c.bigOpacity);
    canvas.drawCircle(
      Offset(size.width * c.bigCenter.dx, size.height * c.bigCenter.dy),
      size.width * c.bigRadius,
      paint,
    );

    paint.color = c.smallColor.withValues(alpha: c.smallOpacity);
    canvas.drawCircle(
      Offset(size.width * c.smallCenter.dx, size.height * c.smallCenter.dy),
      size.width * c.smallRadius,
      paint,
    );
  }

  /* ---------------------------- Pattern 2 ---------------------------- */

  void _paintQuad(Canvas canvas, Size size, Paint paint) {
    final c = quadConfig!;
    paint.style = PaintingStyle.fill;

    final center = Offset(
      size.width * c.center.dx,
      size.height * c.center.dy,
    );

    for (int i = 0; i < c.radii.length; i++) {
      paint.color = c.color.withValues(alpha: c.opacities[i]);
      canvas.drawCircle(
        center,
        size.width * c.radii[i],
        paint,
      );
    }
  }

  /* ---------------------------- Pattern 3 ---------------------------- */

  void _paintRects(Canvas canvas, Size size, Paint paint) {
    final c = rectConfig!;
    paint.style = PaintingStyle.fill;

    final w = size.width * c.rectWidth;
    final h = size.height * c.rectHeight;

    paint.color = c.color.withValues(alpha: c.leftOpacity);
    canvas.drawRect(
      Rect.fromLTWH(
        size.width * c.leftOffset.dx,
        size.height * c.leftOffset.dy,
        w,
        h,
      ),
      paint,
    );

    paint.color = c.color.withValues(alpha: c.rightOpacity);
    canvas.drawRect(
      Rect.fromLTWH(
        size.width * c.rightOffset.dx,
        size.height * c.rightOffset.dy,
        w,
        h,
      ),
      paint,
    );
  }

  /* ---------------------------- Pattern 4 ---------------------------- */

  void _paintArcs(Canvas canvas, Size size, Paint paint) {
    final c = arcConfig!;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = c.strokeWidth;

    final center = Offset(
      size.width * c.center.dx,
      size.height * c.center.dy,
    );

    for (int i = 0; i < c.ringCount; i++) {
      final radius = size.width * (c.startRadius + i * c.gap);
      final opacity =
          (c.startOpacity - i * c.opacityStep).clamp(0.0, 1.0);

      if (opacity <= 0) break;

      paint.color = c.color.withValues(alpha: opacity);
      canvas.drawCircle(center, radius, paint);
    }
  }

  /* ---------------------------- Pattern 5 ---------------------------- */

  void _paintRightDual(Canvas canvas, Size size, Paint paint) {
    final c = rightDualConfig!;
    paint.style = PaintingStyle.fill;

    paint.color = c.color.withValues(alpha: c.primaryOpacity);
    canvas.drawCircle(
      Offset(size.width * c.primaryCenter.dx, size.height * c.primaryCenter.dy),
      size.width * c.primaryRadius,
      paint,
    );

    paint.color = c.color.withValues(alpha: c.secondaryOpacity);
    canvas.drawCircle(
      Offset(
        size.width * c.secondaryCenter.dx,
        size.height * c.secondaryCenter.dy,
      ),
      size.width * c.secondaryRadius,
      paint,
    );
  }

  /* ---------------------------- Pattern 6 ---------------------------- */

  void _paintAngledTiles(Canvas canvas, Size size, Paint paint) {
    final c = angledTileConfig!;
    paint.style = PaintingStyle.fill;

    final center = Offset(
      size.width * c.center.dx,
      size.height * c.center.dy,
    );

    final totalWidth =
        c.widths.fold<double>(0, (s, w) => s + w) * size.width;

    double startX = center.dx - totalWidth / 2;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(c.angle);
    canvas.translate(-center.dx, -center.dy);

    for (int i = 0; i < c.widths.length; i++) {
      final w = size.width * c.widths[i];
      final h = size.height * c.height;

      paint.color = c.color.withValues(alpha: c.opacities[i]);

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            startX,
            center.dy - h / 2,
            w,
            h,
          ),
          const Radius.circular(999),
        ),
        paint,
      );

      startX += w;
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
