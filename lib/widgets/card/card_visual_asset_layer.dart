import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../constants/card_visuals.dart';

class CardVisualAssetLayer extends StatelessWidget {
  static const double _patternOpacity = 0.74;

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

    return ClipRRect(
      borderRadius: borderRadius,
      child: Opacity(
        opacity: _patternOpacity,
        child: SvgPicture.asset(
          CardVisuals.resolveVisualAssetPath(assetPath),
          fit: BoxFit.fill,
          width: double.infinity,
          height: double.infinity,
        ),
      ),
    );
  }
}
