import 'package:flutter/material.dart';

import '../../theme/swallet_theme.dart';
import '../actions/card_action_button.dart';
import '../card/bank_card.dart';
import '../card/secure_reveal_wrapper.dart';

class SwipeActionsTutorialOverlay extends StatefulWidget {
  final bool isDark;
  final VoidCallback onDone;

  const SwipeActionsTutorialOverlay({
    super.key,
    required this.isDark,
    required this.onDone,
  });

  @override
  State<SwipeActionsTutorialOverlay> createState() =>
      _SwipeActionsTutorialOverlayState();
}

class _SwipeActionsTutorialOverlayState
    extends State<SwipeActionsTutorialOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _cardOffset;
  late final Animation<double> _actionOpacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();

    _cardOffset = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween<double>(0), weight: 18),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: -1).chain(
          CurveTween(curve: Curves.easeOutCubic),
        ),
        weight: 28,
      ),
      TweenSequenceItem(tween: ConstantTween<double>(-1), weight: 34),
      TweenSequenceItem(
        tween: Tween<double>(begin: -1, end: 0).chain(
          CurveTween(curve: Curves.easeInOutCubic),
        ),
        weight: 20,
      ),
    ]).animate(_controller);

    _actionOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween<double>(0), weight: 16),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: 1).chain(
          CurveTween(curve: Curves.easeOut),
        ),
        weight: 24,
      ),
      TweenSequenceItem(tween: ConstantTween<double>(1), weight: 42),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1, end: 0).chain(
          CurveTween(curve: Curves.easeIn),
        ),
        weight: 18,
      ),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = SwalletPalette(widget.isDark);
    final media = MediaQuery.of(context);
    final maxWidth = media.size.width >= 600 ? 420.0 : media.size.width - 32;

    return Material(
      color: Colors.black.withValues(alpha: widget.isDark ? 0.76 : 0.58),
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
              decoration: BoxDecoration(
                color: palette.surface,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: palette.outline.withValues(alpha: 0.72),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.28),
                    blurRadius: 34,
                    offset: const Offset(0, 18),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _AnimatedSwipeDemo(
                    isDark: widget.isDark,
                    cardOffset: _cardOffset,
                    actionOpacity: _actionOpacity,
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Swipe left',
                    textAlign: TextAlign.center,
                    style: SwalletText.title.copyWith(
                      color: palette.text,
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Reveal Edit and Delete for each saved card.',
                    textAlign: TextAlign.center,
                    style: SwalletText.body.copyWith(
                      color: palette.textMuted,
                      height: 1.32,
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton(
                      onPressed: widget.onDone,
                      child: const Text('OK'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedSwipeDemo extends StatelessWidget {
  static const double _sourceCardWidth = 340;

  final bool isDark;
  final Animation<double> cardOffset;
  final Animation<double> actionOpacity;

  const _AnimatedSwipeDemo({
    required this.isDark,
    required this.cardOffset,
    required this.actionOpacity,
  });

  @override
  Widget build(BuildContext context) {
    const buttonSize = 52.0;
    const buttonGap = 8.0;
    const buttonInset = 12.0;
    const cardActionGap = 12.0;
    const sourceActionWidth = buttonInset + (buttonSize * 2) + buttonGap;

    return LayoutBuilder(
      builder: (context, constraints) {
        final demoScale = ((constraints.maxWidth - 118) / _sourceCardWidth)
            .clamp(0.62, 0.84)
            .toDouble();
        final scaledActionWidth = sourceActionWidth * demoScale;
        final scaledButtonInset = buttonInset * demoScale;
        final scaledCardActionGap = cardActionGap * demoScale;
        final openOffset = scaledActionWidth + scaledCardActionGap;
        final cardWidth = _sourceCardWidth * demoScale;
        final cardHeight = cardWidth * 17 / 29;
        const sourceCardHeight = _sourceCardWidth * 17 / 29;

        return SizedBox(
          height: cardHeight + 20,
          child: AnimatedBuilder(
            animation: cardOffset,
            builder: (context, _) {
              final progress = (-cardOffset.value).clamp(0.0, 1.0);
              final scale = 1.0 - (0.035 * progress);
              final horizontalOffset = -openOffset * progress;

              return Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.centerRight,
                children: [
                  Opacity(
                    opacity: actionOpacity.value,
                    child: Padding(
                      padding: EdgeInsets.only(right: scaledButtonInset),
                      child: Transform.scale(
                        scale: demoScale,
                        alignment: Alignment.centerRight,
                        child: _TutorialActionButtonsAnchor(isDark: isDark),
                      ),
                    ),
                  ),
                  Transform.translate(
                    offset: Offset(horizontalOffset, 0),
                    child: Transform.scale(
                      scale: scale,
                      child: SizedBox(
                        width: cardWidth,
                        height: cardHeight,
                        child: FittedBox(
                          fit: BoxFit.fill,
                          child: SizedBox(
                            width: _sourceCardWidth,
                            height: sourceCardHeight,
                            child: BankCardScope(
                              revealed: false,
                              cvvVisible: false,
                              onToggleCvv: () {},
                              child: BankCard(
                                bankLogo: 'hdfc_bank',
                                networkLogo: 'assets/images/networks/visa.svg',
                                cardType: 'Credit',
                                cardNumber: '4242424242424242',
                                validThru: '12/30',
                                holderName: 'SWALLET USER',
                                cvv: '123',
                                customGradientStartColor:
                                    const Color(0xFF1D4ED8),
                                customGradientMiddleColor:
                                    const Color(0xFF0F766E),
                                customGradientEndColor: const Color(0xFF111827),
                                onEyeTap: () {},
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _TutorialActionButtonsAnchor extends StatelessWidget {
  final bool isDark;

  const _TutorialActionButtonsAnchor({
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CardActionButton(
          icon: Icons.edit_rounded,
          isDark: isDark,
        ),
        const SizedBox(width: 8),
        CardActionButton(
          icon: Icons.delete_rounded,
          isDark: isDark,
          destructive: true,
        ),
      ],
    );
  }
}
