import 'package:flutter/material.dart';

class DeletingListItemWrapper extends StatefulWidget {
  final bool isDeleting;
  final Widget child;

  const DeletingListItemWrapper({
    super.key,
    required this.isDeleting,
    required this.child,
  });

  @override
  State<DeletingListItemWrapper> createState() => _DeletingListItemWrapperState();
}

class _DeletingListItemWrapperState extends State<DeletingListItemWrapper>
    with SingleTickerProviderStateMixin {
  static const Duration _deleteDuration = Duration(milliseconds: 1100);
  static const Curve _curve = Cubic(0.22, 1, 0.36, 1);

  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: _deleteDuration,
      value: widget.isDeleting ? 1 : 0,
    );
  }

  @override
  void didUpdateWidget(covariant DeletingListItemWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isDeleting == oldWidget.isDeleting) {
      return;
    }

    if (widget.isDeleting) {
      _controller.forward(from: 0);
    } else {
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _phase(double start, double end) {
    final value = _controller.value;
    if (value <= start) return 0;
    if (value >= end) return 1;
    final t = (value - start) / (end - start);
    return _curve.transform(t);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        final exitProgress = _phase(0.0, 0.38);
        final messageProgress = _phase(0.18, 0.56);
        final collapseProgress = _phase(0.56, 1.0);

        return ClipRect(
          child: Align(
            alignment: Alignment.topCenter,
            heightFactor: (1 - collapseProgress).clamp(0.0, 1.0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth.isFinite
                    ? constraints.maxWidth
                    : MediaQuery.sizeOf(context).width;
                final exitOffset = -(width + 40) * exitProgress;

                return Stack(
                  alignment: Alignment.center,
                  children: [
                    Opacity(
                      opacity: messageProgress,
                      child: const _DeletedMessageChip(),
                    ),
                    Transform.translate(
                      offset: Offset(exitOffset, 0),
                      child: child,
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _DeletedMessageChip extends StatelessWidget {
  const _DeletedMessageChip();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Text(
          'Card deleted',
          style: TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
