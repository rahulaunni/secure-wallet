import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:swallet/theme/swallet_theme.dart';

import 'top_nav_constants.dart';

class FilterChipItem extends StatefulWidget {
  final String label;
  final String iconPath;
  final Color iconColor;
  final bool isActive;
  final bool isDark;
  final VoidCallback onTap;

  const FilterChipItem({
    super.key,
    required this.label,
    required this.iconPath,
    required this.iconColor,
    required this.isActive,
    required this.isDark,
    required this.onTap,
  });

  @override
  State<FilterChipItem> createState() => _FilterChipItemState();
}

class _FilterChipItemState extends State<FilterChipItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _bgColorAnimation;
  late Animation<Color?> _borderColorAnimation;
  late Animation<Color?> _textColorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: chipAnimDuration,
    );

    _setupAnimations();

    if (widget.isActive) {
      _controller.value = 1;
    }
  }

  @override
  void didUpdateWidget(covariant FilterChipItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }

    if (widget.isDark != oldWidget.isDark) {
      _setupAnimations();
    }
  }

  void _setupAnimations() {
    final palette = SwalletPalette(widget.isDark);
    final activeBg = palette.surfaceHigh;
    final inactiveBg = palette.background;
    final activeStroke = activeBg;
    final inactiveStroke = palette.outline.withValues(alpha: 0.90);
    final activeText = palette.text;
    final inactiveText = palette.text;

    _bgColorAnimation = ColorTween(begin: inactiveBg, end: activeBg)
        .animate(CurvedAnimation(parent: _controller, curve: chipAnimCurve));

    _borderColorAnimation = ColorTween(begin: inactiveStroke, end: activeStroke)
        .animate(CurvedAnimation(parent: _controller, curve: chipAnimCurve));

    _textColorAnimation = ColorTween(begin: inactiveText, end: activeText)
        .animate(CurvedAnimation(parent: _controller, curve: chipAnimCurve));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(chipRadius),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(chipRadius),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Container(
                height: chipHeight,
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(
                  horizontal: chipHorizontalPadding,
                ),
                decoration: BoxDecoration(
                  color: _bgColorAnimation.value,
                  borderRadius: BorderRadius.circular(chipRadius),
                  border: Border.all(
                    color: _borderColorAnimation.value!,
                    width: chipBorderWidth,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      widget.iconPath,
                      width: chipIconSize,
                      height: chipIconSize,
                      colorFilter: ColorFilter.mode(
                        widget.iconColor,
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.label,
                      style: SwalletText.body.copyWith(
                        color: _textColorAnimation.value,
                        fontWeight:
                            widget.isActive ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
