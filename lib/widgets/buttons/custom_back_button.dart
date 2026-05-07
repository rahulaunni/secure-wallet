import 'package:flutter/material.dart';

import 'package:swallet/theme/swallet_theme.dart';
import 'package:swallet/utils/size_config.dart';

class CustomBackButton extends StatefulWidget {
  final bool isDark;
  final VoidCallback? onTap;

  const CustomBackButton({
    super.key,
    required this.isDark,
    this.onTap,
  });

  @override
  State<CustomBackButton> createState() => _CustomBackButtonState();
}

class _CustomBackButtonState extends State<CustomBackButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-0.2, 0),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    await _controller.forward();
    await _controller.reverse();

    if (widget.onTap != null) {
      widget.onTap!();
      return;
    }

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final palette = SwalletPalette(widget.isDark);

    return Semantics(
      button: true,
      label: 'Back',
      child: Tooltip(
        message: 'Back',
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(r(16)),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: _handleTap,
            borderRadius: BorderRadius.circular(r(16)),
            child: SizedBox(
              width: w(40),
              height: w(40),
              child: Center(
                child: SlideTransition(
                  position: _offsetAnimation,
                  child: Icon(
                    Icons.arrow_back,
                    color: palette.text,
                    size: w(24),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
