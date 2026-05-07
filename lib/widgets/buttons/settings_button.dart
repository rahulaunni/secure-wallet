import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:swallet/widgets/add_card/add_card_material_tokens.dart';

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
                color: tokens.onSurfaceVariant,
                size: 23,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
