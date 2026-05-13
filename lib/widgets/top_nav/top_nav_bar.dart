import 'package:flutter/material.dart';

import 'top_nav_constants.dart';
import 'filter_chip.dart';
import 'top_nav_category.dart';

class TopNavItem {
  final String id;
  final String label;
  final String iconPath;
  final Color iconColor;
  bool isActive;
  final GlobalKey key;

  TopNavItem({
    required this.id,
    required this.label,
    required this.iconPath,
    required this.iconColor,
    this.isActive = false,
    required this.key,
  });
}

class TopNavBar extends StatefulWidget {
  final bool isDark;
  final List<TopNavCategory> categories;
  final Animation<double>? introAnimation;
  final ValueChanged<Set<String>> onSelectionChanged;

  const TopNavBar({
    super.key,
    required this.isDark,
    required this.categories,
    this.introAnimation,
    required this.onSelectionChanged,
  });

  @override
  State<TopNavBar> createState() => _TopNavBarState();
}

class _TopNavBarState extends State<TopNavBar> {
  final ScrollController _scrollController = ScrollController();

  late final List<TopNavItem> _items;

  @override
  void initState() {
    super.initState();
    _items = widget.categories
        .map(
          (category) => TopNavItem(
            id: category.id,
            label: category.label,
            iconPath: category.iconPath,
            iconColor: category.iconColor,
            key: GlobalKey(),
          ),
        )
        .toList();
  }

  void _onChipTap(TopNavItem item) {
    final wasInactive = !item.isActive;

    setState(() {
      item.isActive = !item.isActive;
    });

    widget.onSelectionChanged(
      _items.where((chip) => chip.isActive).map((chip) => chip.id).toSet(),
    );

    if (wasInactive) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final ctx = item.key.currentContext;
        if (ctx != null) {
          Scrollable.ensureVisible(
            ctx,
            duration: chipAnimDuration,
            curve: chipAnimCurve,
            alignment: 0.1,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final introAnimation = widget.introAnimation;

    return SizedBox(
      height: topNavHeight,
      child: SingleChildScrollView(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(
          horizontal: topNavHorizontalPadding,
        ),
        child: Row(
          children: [
            for (var index = 0; index < _items.length; index++)
              _IntroChip(
                key: _items[index].key,
                index: index,
                totalCount: _items.length,
                animation: introAnimation,
                child: Padding(
                  padding: const EdgeInsets.only(
                    right: topNavChipSpacing,
                  ),
                  child: AnimatedSwitcher(
                    duration: chipAnimDuration,
                    transitionBuilder: (child, animation) {
                      return SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.15, 0),
                          end: Offset.zero,
                        ).animate(animation),
                        child: FadeTransition(
                          opacity: animation,
                          child: child,
                        ),
                      );
                    },
                    child: FilterChipItem(
                      key: ValueKey(_items[index].id),
                      label: _items[index].label,
                      iconPath: _items[index].iconPath,
                      iconColor: _items[index].iconColor,
                      isActive: _items[index].isActive,
                      isDark: widget.isDark,
                      onTap: () => _onChipTap(_items[index]),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _IntroChip extends StatelessWidget {
  static const Curve _settleCurve = Cubic(0.22, 1, 0.36, 1);

  final int index;
  final int totalCount;
  final Animation<double>? animation;
  final Widget child;

  const _IntroChip({
    super.key,
    required this.index,
    required this.totalCount,
    required this.animation,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final animation = this.animation;
    if (animation == null || animation.value >= 1) {
      return child;
    }

    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) {
        final visibleTotal = totalCount.clamp(1, 8);
        final cappedIndex = index.clamp(0, visibleTotal - 1);
        final start = (0.46 + (cappedIndex * 0.075)).clamp(0.0, 0.82);
        final end =
            (start + 0.38 + (0.012 * (8 - visibleTotal))).clamp(start, 1.0);
        final progress = ((animation.value - start) / (end - start))
            .clamp(0.0, 1.0)
            .toDouble();
        final eased = _settleCurve.transform(progress);
        final settle = Curves.easeOutBack.transform(progress);

        return Opacity(
          opacity: eased,
          child: Transform.translate(
            offset: Offset(34 * (1 - eased), 0),
            child: Transform.scale(
              scale: 0.94 + (0.06 * settle),
              alignment: Alignment.centerLeft,
              child: child,
            ),
          ),
        );
      },
    );
  }
}
