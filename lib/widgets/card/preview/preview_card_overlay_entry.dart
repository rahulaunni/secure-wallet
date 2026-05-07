import 'package:flutter/material.dart';
import '../../../constants/layout_constants.dart';


class PreviewCardOverlayEntry {
  static OverlayEntry? _entry;

  static void show({
    required BuildContext context,
    required Widget child,
  }) {
    if (_entry != null) return;

    final topInset = MediaQuery.of(context).padding.top;

    _entry = OverlayEntry(
      builder: (_) => Positioned(
        top: topInset + 12,
        left: 16,
        right: 16,
        height: previewCardHeight,
        child: Material(
          color: Colors.transparent,
          child: child,
        ),
      ),
    );

    Overlay.of(context, rootOverlay: true).insert(_entry!);
  }

  static void hide() {
    _entry?.remove();
    _entry = null;
  }
}
