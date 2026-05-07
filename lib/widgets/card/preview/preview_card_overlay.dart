import 'package:flutter/material.dart';
import '../../../constants/layout_constants.dart';

class PreviewCardOverlay extends StatelessWidget {
  final Widget child;

  const PreviewCardOverlay({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;

    return Positioned(
      top: topInset + 40,
      left: 16,
      right: 16,
      height: previewCardHeight,
      child: child,
    );
  }
}
