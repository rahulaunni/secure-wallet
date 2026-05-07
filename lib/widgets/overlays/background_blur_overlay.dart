import 'dart:ui';
import 'package:flutter/material.dart';

class BackgroundBlurOverlay {
  static OverlayEntry? _entry;

  static void show(BuildContext context) {
    if (_entry != null) return;

    _entry = OverlayEntry(
      builder: (_) => Positioned.fill(
        child: IgnorePointer(
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 12,
              sigmaY: 12,
            ),
            child: Container(
              // very light scrim for depth
              color: Colors.black.withValues(alpha: 0.12),
            ),
          ),
        ),
      ),
    );

    // 🔒 INSERT FIRST (BEHIND EVERYTHING)
    Overlay.of(context, rootOverlay: true).insert(_entry!);
  }

  static void hide() {
    _entry?.remove();
    _entry = null;
  }
}
