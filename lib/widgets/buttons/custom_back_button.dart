import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:swallet/widgets/add_card/add_card_material_tokens.dart';

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
    final tokens = AddCardMaterialTokens(widget.isDark);

    return Material(
      color: tokens.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(
          color: tokens.outlineVariant.withValues(alpha: 0.45),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: _handleTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Center(
            child: SlideTransition(
              position: _offsetAnimation,
              child: Icon(
                CupertinoIcons.chevron_left,
                color: tokens.onSurfaceVariant,
                size: 22,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
