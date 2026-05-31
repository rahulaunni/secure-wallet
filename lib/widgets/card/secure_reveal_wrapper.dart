import 'dart:async';
import 'package:flutter/material.dart';

import '../../constants/layout_constants.dart';
import 'black_secure_card.dart';
import 'package:swallet/utils/haptics.dart';

class SecureRevealWrapper extends StatefulWidget {
  final Widget child;
  final bool revealed;
  final VoidCallback onAutoLock;

  const SecureRevealWrapper({
    super.key,
    required this.child,
    required this.revealed,
    required this.onAutoLock,
  });

  @override
  State<SecureRevealWrapper> createState() => _SecureRevealWrapperState();
}

class _SecureRevealWrapperState extends State<SecureRevealWrapper>
    with SingleTickerProviderStateMixin {
  static const double _topTiltPadding = 8;

  late final AnimationController _controller;
  late final Animation<double> _anim;

  ScrollPosition? _scrollPosition;
  Timer? _timer;
  int _remainingSeconds = 60;
  bool _cvvVisible = false;
  bool _visibilityCheckScheduled = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: secureRevealAnimDuration,
    );
    _anim = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _attachScrollPosition();
  }

  @override
  void didUpdateWidget(covariant SecureRevealWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.revealed && !oldWidget.revealed) {
      _startReveal();
    } else if (!widget.revealed && oldWidget.revealed) {
      _lock();
    }
  }

  void _attachScrollPosition() {
    final nextPosition = Scrollable.maybeOf(context)?.position;
    if (identical(_scrollPosition, nextPosition)) {
      return;
    }

    _scrollPosition?.removeListener(_scheduleVisibilityCheck);
    _scrollPosition = nextPosition;
    _scrollPosition?.addListener(_scheduleVisibilityCheck);
  }

  void _startReveal() {
    SwalletHaptics.bankSelected();

    _remainingSeconds = 60;
    _cvvVisible = false;
    _controller.forward(from: 0);
    _timer?.cancel();
    _scheduleVisibilityCheck();

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_remainingSeconds <= 1) {
        t.cancel();
        widget.onAutoLock();
      } else {
        setState(() => _remainingSeconds--);
      }
    });
  }

  void _lock() {
    SwalletHaptics.changeBank();
    _timer?.cancel();
    _remainingSeconds = 60;
    _cvvVisible = false;
    _controller.reverse();
  }

  void _scheduleVisibilityCheck() {
    if (_visibilityCheckScheduled || !mounted || !widget.revealed) {
      return;
    }

    _visibilityCheckScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _visibilityCheckScheduled = false;
      if (!mounted || !widget.revealed) {
        return;
      }

      if (_isOutsideViewport()) {
        widget.onAutoLock();
      }
    });
  }

  bool _isOutsideViewport() {
    final renderObject = context.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) {
      return false;
    }

    final widgetTopLeft = renderObject.localToGlobal(Offset.zero);
    final widgetRect = widgetTopLeft & renderObject.size;
    final viewportRect = _viewportRect();

    return widgetRect.bottom <= viewportRect.top + 1 ||
        widgetRect.top >= viewportRect.bottom - 1 ||
        widgetRect.right <= viewportRect.left + 1 ||
        widgetRect.left >= viewportRect.right - 1;
  }

  Rect _viewportRect() {
    final scrollContext = Scrollable.maybeOf(context)?.context;
    final scrollRenderObject = scrollContext?.findRenderObject();

    if (scrollRenderObject is RenderBox && scrollRenderObject.hasSize) {
      return scrollRenderObject.localToGlobal(Offset.zero) &
          scrollRenderObject.size;
    }

    return Offset.zero & MediaQuery.of(context).size;
  }

  @override
  void dispose() {
    _scrollPosition?.removeListener(_scheduleVisibilityCheck);
    if (widget.revealed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onAutoLock();
      });
    }
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.of(context).size.width - 32;
        final cardHeight =
            availableWidth * (cardAspectRatioHeight / cardAspectRatioWidth);

        return AnimatedBuilder(
          animation: _anim,
          builder: (_, __) {
            final double tiltFactor = _anim.value <= 0.5
                ? (_anim.value / 0.5)
                : ((1 - _anim.value) / 0.5);

            final double tilt = secureRevealBankTilt * tiltFactor;

            return SizedBox(
              height: _topTiltPadding +
                  cardHeight +
                  (secureRevealBarHeight * _anim.value),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    top: _topTiltPadding +
                        (secureRevealSlideOffset * _anim.value),
                    left: 0,
                    right: 0,
                    child: SizedBox(
                      height: cardHeight,
                      child: BlackSecureCard(
                        remainingSeconds: _remainingSeconds,
                      ),
                    ),
                  ),
                  Positioned(
                    top: _topTiltPadding,
                    left: 0,
                    right: 0,
                    child: Transform(
                      alignment: Alignment.topCenter,
                      transform: Matrix4.identity()..rotateZ(tilt),
                      child: BankCardScope(
                        revealed: widget.revealed,
                        cvvVisible: _cvvVisible,
                        onToggleCvv: () {
                          SwalletHaptics.secureRevealToggled();
                          setState(() {
                            _cvvVisible = !_cvvVisible;
                          });
                        },
                        child: widget.child,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// ================= CVV SCOPE =================

class BankCardScope extends InheritedWidget {
  final bool revealed;
  final bool cvvVisible;
  final VoidCallback onToggleCvv;

  const BankCardScope({
    super.key,
    required this.revealed,
    required this.cvvVisible,
    required this.onToggleCvv,
    required super.child,
  });

  static BankCardScope of(BuildContext context) {
    final BankCardScope? result =
        context.dependOnInheritedWidgetOfExactType<BankCardScope>();
    assert(result != null);
    return result!;
  }

  @override
  bool updateShouldNotify(BankCardScope oldWidget) =>
      revealed != oldWidget.revealed || cvvVisible != oldWidget.cvvVisible;
}
