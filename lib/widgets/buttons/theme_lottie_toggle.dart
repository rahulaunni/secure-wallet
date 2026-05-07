import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

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
  late final AnimationController _controller;

  // 🔑 SAFE RESTING PROGRESS VALUES FOR THIS LOTTIE
  static const double _sunProgress = 0.0;
  static const double _moonProgress = 0.65;

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
    final bool next = !widget.isDark;
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
    final Color backgroundColor = widget.isDark
        ? const Color(0xFF1D1E1E)
        : const Color(0xFFF2F3F5);

    return GestureDetector(
      onTap: _onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Transform.scale(
            // 🔥 THIS FIXES THE “ICON FEELS SMALL” PROBLEM
            // Because the Lottie canvas has huge internal padding
            scale: 1.6, // tweak between 1.4 → 1.8 if needed
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
