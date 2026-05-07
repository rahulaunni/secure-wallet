import 'dart:ui';
import 'package:flutter/material.dart';

class AddCardBackground extends StatelessWidget {
  final bool isDark;

  const AddCardBackground({
    super.key,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          color: Colors.black.withValues(
            alpha: isDark ? 0.35 : 0.12,
          ),
        ),
      ),
    );
  }
}
