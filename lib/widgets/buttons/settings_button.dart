import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:swallet/theme/swallet_theme.dart';

class SettingsButton extends StatefulWidget {
  final bool isDark;
  final VoidCallback onTap;

  const SettingsButton({
    super.key,
    required this.isDark,
    required this.onTap,
  });

  @override
  State<SettingsButton> createState() => _SettingsButtonState();
}

class _SettingsButtonState extends State<SettingsButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTap() {
    _controller.forward(from: 0);
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final palette = SwalletPalette(widget.isDark);

    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: palette.surfaceLow,
        boxShadow: [
          BoxShadow(
            color:
                palette.primary.withValues(alpha: widget.isDark ? 0.10 : 0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: _onTap,
          child: SizedBox(
            width: 44,
            height: 44,
            child: Center(
              child: RotationTransition(
                turns: CurvedAnimation(
                  parent: _controller,
                  curve: Curves.easeOutBack,
                ),
                child: Icon(
                  CupertinoIcons.settings,
                  color: palette.text,
                  size: 22,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
