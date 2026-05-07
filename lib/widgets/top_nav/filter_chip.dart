import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:swallet/widgets/add_card/add_card_material_tokens.dart';

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
  late Animation<double> _dotSizeAnimation;
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
    final tokens = AddCardMaterialTokens(widget.isDark);
    final activeBg = tokens.primaryContainer;
    final inactiveBg = tokens.surfaceContainer;
    final activeStroke = tokens.primary.withValues(alpha: 0.34);
    final inactiveStroke = tokens.outlineVariant.withValues(alpha: 0.45);
    final activeText = tokens.onPrimaryContainer;
    final inactiveText = tokens.onSurfaceVariant;

    _bgColorAnimation = ColorTween(begin: inactiveBg, end: activeBg)
        .animate(CurvedAnimation(parent: _controller, curve: chipAnimCurve));

    _borderColorAnimation = ColorTween(begin: inactiveStroke, end: activeStroke)
        .animate(CurvedAnimation(parent: _controller, curve: chipAnimCurve));

    _textColorAnimation = ColorTween(begin: inactiveText, end: activeText)
        .animate(CurvedAnimation(parent: _controller, curve: chipAnimCurve));

    _dotSizeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 1, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AddCardMaterialTokens(widget.isDark);

    return RepaintBoundary(
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(chipHeight / 2),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(chipHeight / 2),
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
                  borderRadius: BorderRadius.circular(chipHeight / 2),
                  border: Border.all(
                    color: _borderColorAnimation.value!,
                    width: chipBorderWidth,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizeTransition(
                      sizeFactor: _dotSizeAnimation,
                      axis: Axis.horizontal,
                      axisAlignment: -1,
                      child: SizedBox(
                        height: chipHeight,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: chipDotSize,
                              height: chipDotSize,
                              decoration: BoxDecoration(
                                color: tokens.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: chipDotSpacing),
                          ],
                        ),
                      ),
                    ),
                    Text(
                      widget.label,
                      style: GoogleFonts.roboto(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _textColorAnimation.value,
                      ),
                    ),
                    const SizedBox(width: 8),
                    SvgPicture.asset(
                      widget.iconPath,
                      width: chipIconSize,
                      height: chipIconSize,
                      colorFilter: ColorFilter.mode(
                        widget.isActive
                            ? tokens.onPrimaryContainer
                            : widget.iconColor.withValues(alpha: 0.86),
                        BlendMode.srcIn,
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
