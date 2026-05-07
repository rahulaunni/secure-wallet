import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'package:swallet/theme/swallet_theme.dart';

class ThemeLottieToggle extends StatefulWidget {
  final bool isDark;
  final ValueChanged<bool> onChanged;

  const ThemeLottieToggle({
    super.key,
    required this.isDark,
    required this.onChanged,
  });

  @override
  State<ThemeLottieToggle> createState() => _ThemeLottieToggleState();
}

class _ThemeLottieToggleState extends State<ThemeLottieToggle>
    with SingleTickerProviderStateMixin {
  static const double _sunProgress = 0;
  static const double _moonProgress = 0.65;

  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
      value: widget.isDark ? _moonProgress : _sunProgress,
    );
  }

  @override
  void didUpdateWidget(covariant ThemeLottieToggle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isDark != oldWidget.isDark) {
      _animateTo(widget.isDark);
    }
  }

  void _animateTo(bool toDark) {
    _controller.animateTo(
      toDark ? _moonProgress : _sunProgress,
      duration: const Duration(milliseconds: 520),
      curve: Curves.easeInOutCubic,
    );
  }

  void _onTap() {
    final next = !widget.isDark;
    _animateTo(next);
    widget.onChanged(next);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = SwalletPalette(widget.isDark);

    return GestureDetector(
      onTap: _onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: palette.surfaceLow,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: palette.primary.withValues(
                alpha: widget.isDark ? 0.10 : 0.06,
              ),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: Transform.scale(
            scale: 1.58,
            child: Lottie.asset(
              'assets/lottie/theme/sun_moon_toggle.json',
              controller: _controller,
              width: 44,
              height: 44,
              fit: BoxFit.contain,
              repeat: false,
            ),
          ),
        ),
      ),
    );
  }
}
