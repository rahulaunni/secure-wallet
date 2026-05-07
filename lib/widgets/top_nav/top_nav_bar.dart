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

  /// 🔔 Emits active category IDs
  final ValueChanged<Set<String>> onSelectionChanged;

  const TopNavBar({
    super.key,
    required this.isDark,
    required this.categories,
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

    // 🔒 BASE ORDER — PROVIDED BY HOMESCREEN (NOW FINAL)
    _items = widget.categories
        .map(
          (c) => TopNavItem(
            id: c.id,
            label: c.label,
            iconPath: c.iconPath,
            iconColor: c.iconColor,
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

    // 🔔 Notify HomeScreen
    widget.onSelectionChanged(
      _items
          .where((i) => i.isActive)
          .map((i) => i.id)
          .toSet(),
    );

    // 🔒 Scroll ONLY on activation (UNCHANGED)
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
          children: _items.map((item) {
            return Padding(
              key: item.key,
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
                  key: ValueKey(item.id),
                  label: item.label,
                  iconPath: item.iconPath,
                  iconColor: item.iconColor,
                  isActive: item.isActive,
                  isDark: widget.isDark,
                  onTap: () => _onChipTap(item),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
