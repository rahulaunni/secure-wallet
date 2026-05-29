import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../constants/card_visuals.dart';

class CardVisualAssetLayer extends StatelessWidget {
  final CardVisual visual;
  final BorderRadius borderRadius;

  const CardVisualAssetLayer({
    super.key,
    required this.visual,
    required this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final assetPath = visual.visualAssetPath;
    if (assetPath == null) {
      return const SizedBox.shrink();
    }

    final resolvedPath = CardVisuals.resolveVisualAssetPath(assetPath);
    final profile = _CardTextureProfile.fromVisual(visual);

    return RepaintBoundary(
      child: ClipRRect(
        borderRadius: borderRadius,
        child: IgnorePointer(
          child: Stack(
            fit: StackFit.expand,
            children: [
              Opacity(
                opacity: profile.baseOpacity,
                child: SvgPicture.asset(
                  resolvedPath,
                  fit: BoxFit.fill,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
              Opacity(
                opacity: profile.tintOpacity,
                child: ShaderMask(
                  blendMode: BlendMode.srcIn,
                  shaderCallback: (rect) => LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: profile.tintColors,
                    stops: const [0, 0.52, 1],
                  ).createShader(rect),
                  child: SvgPicture.asset(
                    resolvedPath,
                    fit: BoxFit.fill,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              ),
              Opacity(
                opacity: profile.silhouetteOpacity,
                child: ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    profile.silhouetteColor,
                    BlendMode.srcIn,
                  ),
                  child: SvgPicture.asset(
                    resolvedPath,
                    fit: BoxFit.fill,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              ),
              Opacity(
                opacity: profile.pressOpacity,
                child: ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    profile.pressColor,
                    profile.pressBlendMode,
                  ),
                  child: SvgPicture.asset(
                    resolvedPath,
                    fit: BoxFit.fill,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              ),
              CustomPaint(
                isComplex: true,
                willChange: false,
                painter: _PremiumTexturePainter(profile),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardTextureProfile {
  final List<Color> tintColors;
  final Color grainLight;
  final Color grainDark;
  final Color edgeShade;
  final Color topSheen;
  final Color silhouetteColor;
  final Color pressColor;
  final BlendMode pressBlendMode;
  final double baseOpacity;
  final double tintOpacity;
  final double silhouetteOpacity;
  final double pressOpacity;
  final double grainOpacity;
  final double sheenOpacity;
  final double edgeOpacity;

  const _CardTextureProfile({
    required this.tintColors,
    required this.grainLight,
    required this.grainDark,
    required this.edgeShade,
    required this.topSheen,
    required this.silhouetteColor,
    required this.pressColor,
    required this.pressBlendMode,
    required this.baseOpacity,
    required this.tintOpacity,
    required this.silhouetteOpacity,
    required this.pressOpacity,
    required this.grainOpacity,
    required this.sheenOpacity,
    required this.edgeOpacity,
  });

  factory _CardTextureProfile.fromVisual(CardVisual visual) {
    final colors = visual.gradient.colors;
    final start = colors.isNotEmpty ? colors.first : const Color(0xFF111827);
    final middle = colors.length > 2
        ? colors[1]
        : Color.lerp(start, colors.isNotEmpty ? colors.last : start, 0.5)!;
    final end = colors.length > 1 ? colors.last : const Color(0xFF020617);
    final averageLuminance = (start.computeLuminance() +
            middle.computeLuminance() +
            end.computeLuminance()) /
        3;
    final isBright = averageLuminance > 0.48;
    final isVeryDark = averageLuminance < 0.13;
    final boost = visual.visualOpacityBoost;
    final minOpacity = visual.visualMinOverlayOpacity;

    final highlight = _tuneLightness(
      Color.lerp(start, middle, isBright ? 0.42 : 0.64)!,
      isBright ? -0.08 : 0.20,
      saturationShift: isBright ? 0.02 : 0.08,
    );
    final accent = _tuneLightness(
      middle,
      isBright ? -0.12 : 0.10,
      saturationShift: 0.06,
    );
    final shadow = _tuneLightness(
      Color.lerp(end, start, 0.18)!,
      isBright ? -0.34 : -0.18,
      saturationShift: 0.05,
    );

    return _CardTextureProfile(
      tintColors: [highlight, accent, shadow],
      grainLight: Color.lerp(highlight, Colors.white, isBright ? 0.18 : 0.36)!,
      grainDark: Color.lerp(shadow, Colors.black, isBright ? 0.34 : 0.18)!,
      edgeShade: shadow,
      topSheen: Color.lerp(highlight, Colors.white, isBright ? 0.22 : 0.46)!,
      silhouetteColor: isBright
          ? Color.lerp(shadow, Colors.black, 0.24)!
          : Color.lerp(highlight, Colors.white, 0.32)!,
      pressColor: isBright
          ? Color.lerp(shadow, Colors.black, 0.18)!
          : Color.lerp(highlight, Colors.white, 0.24)!,
      pressBlendMode: isBright ? BlendMode.multiply : BlendMode.softLight,
      baseOpacity: (minOpacity * boost * (isBright ? 0.56 : 0.48)).clamp(
        0.12,
        0.28,
      ),
      tintOpacity: (minOpacity * boost * (isBright ? 2.55 : 2.85)).clamp(
        0.42,
        isVeryDark ? 0.78 : 0.68,
      ),
      silhouetteOpacity: (minOpacity * boost * (isBright ? 0.96 : 0.82)).clamp(
        0.16,
        0.34,
      ),
      pressOpacity: (minOpacity * boost * (isBright ? 0.72 : 0.62)).clamp(
        0.10,
        0.24,
      ),
      grainOpacity: isBright ? 0.052 : 0.074,
      sheenOpacity: isBright ? 0.074 : 0.10,
      edgeOpacity: isBright ? 0.22 : 0.30,
    );
  }

  static Color _tuneLightness(
    Color color,
    double lightnessShift, {
    double saturationShift = 0,
  }) {
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withSaturation((hsl.saturation + saturationShift).clamp(0.18, 0.92))
        .withLightness((hsl.lightness + lightnessShift).clamp(0.08, 0.86))
        .toColor();
  }
}

class _PremiumTexturePainter extends CustomPainter {
  final _CardTextureProfile profile;

  const _PremiumTexturePainter(this.profile);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            profile.topSheen.withValues(alpha: profile.sheenOpacity),
            profile.topSheen.withValues(alpha: 0),
            profile.edgeShade.withValues(alpha: profile.edgeOpacity),
          ],
          stops: const [0, 0.45, 1],
        ).createShader(rect),
    );

    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: Alignment.bottomRight,
          radius: 1.08,
          colors: [
            profile.edgeShade.withValues(alpha: 0),
            profile.edgeShade.withValues(alpha: profile.edgeOpacity * 0.42),
          ],
        ).createShader(rect),
    );

    _paintGrain(canvas, size);
  }

  void _paintGrain(Canvas canvas, Size size) {
    const step = 4.5;
    final lightPaint = Paint()
      ..color = profile.grainLight.withValues(alpha: profile.grainOpacity);
    final darkPaint = Paint()
      ..color = profile.grainDark.withValues(alpha: profile.grainOpacity * 0.7);

    for (double y = 1; y < size.height; y += step) {
      for (double x = 1; x < size.width; x += step) {
        final seed = ((x * 17).floor() ^ (y * 31).floor()) & 0xff;
        if (seed % 5 != 0) {
          continue;
        }

        final paint = seed.isEven ? lightPaint : darkPaint;
        final radius = seed % 3 == 0 ? 0.46 : 0.34;
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PremiumTexturePainter oldDelegate) {
    return oldDelegate.profile != profile;
  }
}
