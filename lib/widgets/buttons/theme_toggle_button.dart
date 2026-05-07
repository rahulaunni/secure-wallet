import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:swallet/widgets/add_card/add_card_material_tokens.dart';

class ThemeToggleButton extends StatelessWidget {
  final bool isDark;
  final VoidCallback onTap;

  const ThemeToggleButton({
    super.key,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AddCardMaterialTokens(isDark);

    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: tokens.surfaceContainer,
        boxShadow: [
          BoxShadow(
            color: tokens.primary.withValues(alpha: isDark ? 0.10 : 0.06),
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
          onTap: onTap,
          child: SizedBox(
            width: 44,
            height: 44,
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 280),
                switchInCurve: Curves.easeInOutCubic,
                switchOutCurve: Curves.easeInOutCubic,
                transitionBuilder: (child, animation) {
                  final rotate = Tween<double>(begin: -0.35, end: 0).animate(
                    CurvedAnimation(
                        parent: animation, curve: Curves.easeOutCubic),
                  );
                  return RotationTransition(
                    turns: rotate,
                    child: ScaleTransition(
                      scale: animation,
                      child: FadeTransition(opacity: animation, child: child),
                    ),
                  );
                },
                child: Icon(
                  isDark
                      ? CupertinoIcons.moon_fill
                      : CupertinoIcons.sun_max_fill,
                  key: ValueKey(isDark),
                  size: 22,
                  color: tokens.onSurface,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
