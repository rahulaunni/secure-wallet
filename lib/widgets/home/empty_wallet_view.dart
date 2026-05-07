import 'package:flutter/cupertino.dart';

import 'package:swallet/theme/swallet_theme.dart';

class EmptyWalletView extends StatefulWidget {
  final bool isDark;

  const EmptyWalletView({
    super.key,
    required this.isDark,
  });

  @override
  State<EmptyWalletView> createState() => _EmptyWalletViewState();
}

class _EmptyWalletViewState extends State<EmptyWalletView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutSine,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = SwalletPalette(widget.isDark);

    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 96),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, -8 * _animation.value),
                  child: child,
                );
              },
              child: Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: palette.surfaceLow,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: palette.outline.withValues(
                      alpha: widget.isDark ? 0.85 : 1,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: palette.primary.withValues(
                        alpha: widget.isDark ? 0.12 : 0.06,
                      ),
                      blurRadius: 22,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Icon(
                  CupertinoIcons.lock_shield,
                  size: 31,
                  color: palette.primary,
                ),
              ),
            ),
            const SizedBox(height: 22),
            Text(
              'No cards yet',
              style: SwalletText.title.copyWith(color: palette.text),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first card to get started',
              textAlign: TextAlign.center,
              style: SwalletText.body.copyWith(color: palette.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
