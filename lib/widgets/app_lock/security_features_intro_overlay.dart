import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

import '../../theme/swallet_theme.dart';

class SecurityFeaturesIntroOverlay extends StatefulWidget {
  final bool isDark;
  final VoidCallback onDone;

  const SecurityFeaturesIntroOverlay({
    super.key,
    required this.isDark,
    required this.onDone,
  });

  @override
  State<SecurityFeaturesIntroOverlay> createState() =>
      _SecurityFeaturesIntroOverlayState();
}

class _SecurityFeaturesIntroOverlayState
    extends State<SecurityFeaturesIntroOverlay> {
  int _index = 0;
  double _slideDragDx = 0;

  static const List<_SecurityIntroSlide> _slides = [
    _SecurityIntroSlide(
      assetPath: 'assets/onboarding/secure card.svg',
      title: 'Hive encrypted vault',
      body:
          'Card details are written into an encrypted Hive box as unreadable cipher bytes on this device.',
      question: 'What if someone peeks at app storage?',
      answer: 'They meet cipher soup, not your card number.',
      useEncryptedCardAsset: true,
    ),
    _SecurityIntroSlide(
      assetPath: 'assets/onboarding/no internet.svg',
      lottieAssetPath: 'assets/lottie/no_connection.json',
      title: 'No internet required',
      body:
          'Swallet works fully offline. Your card vault stays on this device without sending details to a server.',
      question: 'Cable unplugged and Wi-Fi panicking?',
      answer: 'Still fine. Swallet keeps your cards local.',
    ),
    _SecurityIntroSlide(
      assetPath: 'assets/onboarding/fingerprint.svg',
      title: 'Private unlock',
      body:
          'Your app PIN and device authentication guard access before cards open.',
      question: 'Can anyone just open the vault?',
      answer: 'Only after your PIN or device unlock says yes.',
      useBiometricAsset: true,
    ),
  ];

  void _continue() {
    if (_index == _slides.length - 1) {
      widget.onDone();
      return;
    }
    setState(() => _index++);
  }

  void _previous() {
    if (_index == 0) return;
    setState(() => _index--);
  }

  void _handleHorizontalDragStart(DragStartDetails details) {
    _slideDragDx = 0;
  }

  void _handleHorizontalDragUpdate(DragUpdateDetails details) {
    _slideDragDx += details.delta.dx;
  }

  void _handleHorizontalDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    final distance = _slideDragDx;
    _slideDragDx = 0;

    if (velocity < -120 || distance < -56) {
      _continue();
    } else if (velocity > 120 || distance > 56) {
      _previous();
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = SwalletPalette(widget.isDark);
    final background = palette.background;
    final panelColor = palette.background;
    final buttonColor =
        widget.isDark ? const Color(0xFF34323D) : const Color(0xFFE8E8EE);
    final buttonText =
        widget.isDark ? const Color(0xFFFFFFFF) : const Color(0xFF16161C);

    return Material(
      color: background,
      child: SafeArea(
        child: Center(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final frameWidth =
                  constraints.maxWidth >= 600 ? 420.0 : constraints.maxWidth;

              return SizedBox(
                width: frameWidth,
                height: constraints.maxHeight,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: panelColor,
                    borderRadius: constraints.maxWidth >= 600
                        ? BorderRadius.circular(36)
                        : BorderRadius.zero,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(28, 18, 28, 28),
                    child: Column(
                      children: [
                        _SlideIndicator(
                          count: _slides.length,
                          activeIndex: _index,
                          palette: palette,
                        ),
                        Expanded(
                          child: GestureDetector(
                            key: const ValueKey('security_intro_slide_area'),
                            behavior: HitTestBehavior.translucent,
                            onHorizontalDragStart: _handleHorizontalDragStart,
                            onHorizontalDragUpdate: _handleHorizontalDragUpdate,
                            onHorizontalDragEnd: _handleHorizontalDragEnd,
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 260),
                              switchInCurve: Curves.easeOutCubic,
                              switchOutCurve: Curves.easeInCubic,
                              transitionBuilder: (child, animation) {
                                final offset = Tween<Offset>(
                                  begin: const Offset(0.08, 0),
                                  end: Offset.zero,
                                ).animate(animation);
                                return FadeTransition(
                                  opacity: animation,
                                  child: SlideTransition(
                                    position: offset,
                                    child: child,
                                  ),
                                );
                              },
                              child: _SecurityIntroSlideView(
                                key: ValueKey(_index),
                                slide: _slides[_index],
                                isDark: widget.isDark,
                                buttonColor: buttonColor,
                                buttonTextColor: buttonText,
                                buttonLabel: _index == _slides.length - 1
                                    ? 'Continue'
                                    : 'Next',
                                onButtonPressed: _index == _slides.length - 1
                                    ? widget.onDone
                                    : _continue,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SecurityIntroSlide {
  final String assetPath;
  final String? lottieAssetPath;
  final String title;
  final String body;
  final String question;
  final String answer;
  final bool useEncryptedCardAsset;
  final bool useBiometricAsset;

  const _SecurityIntroSlide({
    required this.assetPath,
    this.lottieAssetPath,
    required this.title,
    required this.body,
    required this.question,
    required this.answer,
    this.useEncryptedCardAsset = false,
    this.useBiometricAsset = false,
  });
}

class _SecurityIntroSlideView extends StatelessWidget {
  final _SecurityIntroSlide slide;
  final bool isDark;
  final Color buttonColor;
  final Color buttonTextColor;
  final String buttonLabel;
  final VoidCallback onButtonPressed;

  const _SecurityIntroSlideView({
    super.key,
    required this.slide,
    required this.isDark,
    required this.buttonColor,
    required this.buttonTextColor,
    required this.buttonLabel,
    required this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    final palette = SwalletPalette(isDark);

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxHeight < 590;
        final topBlockHeight = compact ? 106.0 : 116.0;
        final middleBlockHeight = compact ? 204.0 : 256.0;
        final middleBlockWidth = compact ? 300.0 : 316.0;
        final topMiddleGap = compact ? 14.0 : 20.0;
        final sceneTopPadding = compact ? 40.0 : 56.0;
        final sceneHeight = topBlockHeight + topMiddleGap + middleBlockHeight;
        final middleBottomGap = compact ? 8.0 : 12.0;
        final titleBodyGap = compact ? 10.0 : 14.0;
        final bodyButtonGap = compact ? 18.0 : 24.0;

        return Column(
          children: [
            SizedBox(height: sceneTopPadding),
            SizedBox(
              height: sceneHeight,
              child: Column(
                children: [
                  SizedBox(
                    height: topBlockHeight,
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: _StoryDialogue(
                        question: slide.question,
                        answer: slide.answer,
                        palette: palette,
                      ),
                    ),
                  ),
                  SizedBox(height: topMiddleGap),
                  SizedBox(
                    width: middleBlockWidth,
                    height: middleBlockHeight,
                    child: Center(
                      child: slide.useEncryptedCardAsset
                          ? const FittedBox(
                              fit: BoxFit.contain,
                              child: _EncryptedCardScanAsset(),
                            )
                          : slide.useBiometricAsset
                              ? const FittedBox(
                                  fit: BoxFit.contain,
                                  child: _FingerprintUnlockAsset(),
                                )
                              : slide.lottieAssetPath != null
                                  ? _OfflineLottieAsset(
                                      assetPath: slide.lottieAssetPath!,
                                      width: middleBlockWidth,
                                      height: middleBlockHeight,
                                    )
                                  : _StyledSvgAsset(
                                      assetPath: slide.assetPath,
                                      height: middleBlockHeight,
                                    ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: middleBottomGap),
            const Spacer(),
            _SlideBottomActionGroup(
              title: slide.title,
              body: slide.body,
              palette: palette,
              buttonColor: buttonColor,
              buttonTextColor: buttonTextColor,
              buttonLabel: buttonLabel,
              onButtonPressed: onButtonPressed,
              titleBodyGap: titleBodyGap,
              bodyButtonGap: bodyButtonGap,
            ),
          ],
        );
      },
    );
  }
}

class _SlideBottomActionGroup extends StatelessWidget {
  final String title;
  final String body;
  final SwalletPalette palette;
  final Color buttonColor;
  final Color buttonTextColor;
  final String buttonLabel;
  final VoidCallback onButtonPressed;
  final double titleBodyGap;
  final double bodyButtonGap;

  const _SlideBottomActionGroup({
    required this.title,
    required this.body,
    required this.palette,
    required this.buttonColor,
    required this.buttonTextColor,
    required this.buttonLabel,
    required this.onButtonPressed,
    required this.titleBodyGap,
    required this.bodyButtonGap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 20,
            height: 1,
            fontWeight: FontWeight.w600,
            color: palette.text,
          ),
        ),
        SizedBox(height: titleBodyGap),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 280),
          child: Text(
            body,
            textAlign: TextAlign.center,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 14,
              height: 1.35,
              fontWeight: FontWeight.w400,
              color: palette.textMuted,
            ),
          ),
        ),
        SizedBox(height: bodyButtonGap),
        SizedBox(
          width: 158,
          height: 54,
          child: FilledButton(
            key: ValueKey('security_intro_primary_button_$title'),
            onPressed: onButtonPressed,
            style: FilledButton.styleFrom(
              backgroundColor: buttonColor,
              foregroundColor: buttonTextColor,
              elevation: 0,
              shape: const StadiumBorder(),
              textStyle: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                height: 1,
              ),
            ),
            child: Text(
              buttonLabel,
              maxLines: 1,
            ),
          ),
        ),
      ],
    );
  }
}

class _AnimatedStoryBubble extends StatelessWidget {
  final int order;
  final Widget child;

  const _AnimatedStoryBubble({
    required this.order,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final startDelayMs = order == 0 ? 80.0 : 460.0;
    const animationMs = 360.0;
    const totalMs = 860.0;

    return TweenAnimationBuilder<double>(
      key: ValueKey(order),
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 860),
      builder: (context, value, child) {
        final delayed = ((value * totalMs) - startDelayMs)
            .clamp(0.0, animationMs)
            .toDouble();
        final rawProgress = delayed / animationMs;
        final progress = const Cubic(0.22, 1, 0.36, 1).transform(rawProgress);

        return Opacity(
          opacity: progress,
          child: Transform.translate(
            offset: Offset(0, 12 * (1 - progress)),
            child: Transform.scale(
              scale: 0.96 + (0.04 * progress),
              alignment:
                  order == 0 ? Alignment.centerLeft : Alignment.centerRight,
              child: child,
            ),
          ),
        );
      },
      child: child,
    );
  }
}

class _StoryDialogue extends StatelessWidget {
  final String question;
  final String answer;
  final SwalletPalette palette;

  const _StoryDialogue({
    required this.question,
    required this.answer,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: _AnimatedStoryBubble(
            order: 0,
            child: _StoryBubble(
              text: question,
              palette: palette,
              isAnswer: false,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: _AnimatedStoryBubble(
            order: 1,
            child: _StoryBubble(
              text: answer,
              palette: palette,
              isAnswer: true,
            ),
          ),
        ),
      ],
    );
  }
}

class _StoryBubble extends StatelessWidget {
  final String text;
  final SwalletPalette palette;
  final bool isAnswer;

  const _StoryBubble({
    required this.text,
    required this.palette,
    required this.isAnswer,
  });

  @override
  Widget build(BuildContext context) {
    final background = isAnswer
        ? palette.primary.withValues(alpha: 0.14)
        : palette.surfaceLow.withValues(alpha: 0.92);
    final borderColor = isAnswer
        ? palette.primary.withValues(alpha: 0.26)
        : palette.outline.withValues(alpha: 0.52);
    final textColor = isAnswer ? palette.text : palette.textMuted;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 284),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isAnswer ? 18 : 6),
            bottomRight: Radius.circular(isAnswer ? 6 : 18),
          ),
          border: Border.all(color: borderColor),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Text(
            text,
            textAlign: isAnswer ? TextAlign.right : TextAlign.left,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 12.5,
              height: 1.28,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}

class _OfflineLottieAsset extends StatelessWidget {
  final String assetPath;
  final double width;
  final double height;

  const _OfflineLottieAsset({
    required this.assetPath,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Lottie.asset(
        assetPath,
        fit: BoxFit.contain,
        repeat: true,
      ),
    );
  }
}

class _FingerprintUnlockAsset extends StatefulWidget {
  const _FingerprintUnlockAsset();

  @override
  State<_FingerprintUnlockAsset> createState() =>
      _FingerprintUnlockAssetState();
}

class _FingerprintUnlockAssetState extends State<_FingerprintUnlockAsset>
    with SingleTickerProviderStateMixin {
  static const Curve _settleCurve = Cubic(0.22, 1, 0.36, 1);

  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat();
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
    return _settleCurve.transform((value - start) / (end - start));
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 316,
      height: 246,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final scan = _phase(0.04, 0.5);
          final glowIn = _phase(0.42, 0.68);
          final glowOut = 1 - _phase(0.84, 1);
          final glow = glowIn * glowOut;

          return Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _FingerprintGlowPainter(
                    progress: _controller.value,
                  ),
                ),
              ),
              Transform.scale(
                scale: 0.98 + (0.02 * glow),
                child: Container(
                  width: 198,
                  height: 198,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(52),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF20242C),
                        Color(0xFF0A0B0F),
                        Color(0xFF2E3440),
                      ],
                    ),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.14),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.32),
                        blurRadius: 36,
                        offset: const Offset(0, 18),
                      ),
                      BoxShadow(
                        color: const Color(0xFF82B5FF).withValues(
                          alpha: 0.1 + (glow * 0.18),
                        ),
                        blurRadius: 38,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(52),
                            gradient: RadialGradient(
                              colors: [
                                const Color(0xFF7FB7FF).withValues(
                                  alpha: 0.14 + (glow * 0.2),
                                ),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: SvgPicture.asset(
                          'assets/icons/fingerprint-outline-sharp.svg',
                          width: 128,
                          height: 128,
                          colorFilter: ColorFilter.mode(
                            Color.lerp(
                              const Color(0xFFEAF1FB),
                              const Color(0xFF62D991),
                              glow,
                            )!,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        top: 42 + (74 * scan),
                        child: Opacity(
                          opacity: (0.9 - (glow * 0.48)).clamp(0.0, 1.0),
                          child: Container(
                            height: 46,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  const Color(0xFFB8D8FF).withValues(alpha: 0),
                                  const Color(0xFFD9EAFF)
                                      .withValues(alpha: 0.26),
                                  const Color(0xFFFFFFFF)
                                      .withValues(alpha: 0.52),
                                  const Color(0xFFB8D8FF).withValues(alpha: 0),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 4,
                child: Opacity(
                  opacity: 0.76,
                  child: Text(
                    glow > 0.35 ? 'FINGERPRINT OK' : 'VERIFYING',
                    style: GoogleFonts.poppins(
                      color: Colors.white.withValues(alpha: 0.74),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.4,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _FingerprintGlowPainter extends CustomPainter {
  final double progress;

  const _FingerprintGlowPainter({
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final pulse = 0.5 + (0.5 * (1 - (progress * 2 - 1).abs()));
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF7FB7FF).withValues(alpha: 0.18 * pulse),
          const Color(0xFF7FB7FF).withValues(alpha: 0),
        ],
      ).createShader(
        Rect.fromCircle(center: center, radius: 150),
      );

    canvas.drawCircle(center, 150, paint);

    final ringPaint = Paint()
      ..color = const Color(0xFFB8D8FF).withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawCircle(center, 112 + (8 * pulse), ringPaint);
  }

  @override
  bool shouldRepaint(covariant _FingerprintGlowPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _EncryptedCardScanAsset extends StatefulWidget {
  const _EncryptedCardScanAsset();

  @override
  State<_EncryptedCardScanAsset> createState() =>
      _EncryptedCardScanAssetState();
}

class _EncryptedCardScanAssetState extends State<_EncryptedCardScanAsset>
    with SingleTickerProviderStateMixin {
  static const Curve _scanCurve = Cubic(0.22, 1, 0.36, 1);

  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _rowProgress({
    required double scanY,
    required double rowY,
  }) {
    return ((scanY - rowY + 18) / 36).clamp(0.0, 1.0).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 286,
      child: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final rawScan =
                ((_controller.value - 0.08) / 0.76).clamp(0.0, 1.0).toDouble();
            final scan = _scanCurve.transform(rawScan);
            const cardHeight = 196.0;
            final scanY = cardHeight * scan;

            return Transform.rotate(
              angle: -0.035,
              child: Container(
                width: 316,
                height: cardHeight,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.34),
                      blurRadius: 34,
                      offset: const Offset(0, 18),
                    ),
                    BoxShadow(
                      color: const Color(0xFF9BA6B8).withValues(alpha: 0.12),
                      blurRadius: 40,
                      offset: const Offset(-8, -10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Stack(
                    children: [
                      const _EncryptedCardBackground(),
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _CardGrainPainter(
                            color: Colors.white.withValues(alpha: 0.035),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 24,
                        top: 22,
                        child: Row(
                          children: [
                            Container(
                              width: 34,
                              height: 24,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(7),
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFE1D3A6),
                                    Color(0xFFA48956),
                                  ],
                                ),
                                border: const Border.fromBorderSide(
                                  BorderSide(
                                    color: Color(0xFFF2E6BF),
                                    width: 0.8,
                                  ),
                                ),
                              ),
                              child: CustomPaint(
                                painter: _ChipLinePainter(),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'SWALLET',
                              style: GoogleFonts.poppins(
                                color: Colors.white.withValues(alpha: 0.86),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        right: 24,
                        top: 23,
                        child: Text(
                          'PRIVATE',
                          style: GoogleFonts.poppins(
                            color: Colors.white.withValues(alpha: 0.58),
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 24,
                        right: 24,
                        top: 78,
                        child: _EncryptedCardTextLine(
                          revealed: '5375 2481 9046 8432',
                          encrypted: 'A7 F3 0C 8B 91 E4',
                          progress: _rowProgress(scanY: scanY, rowY: 88),
                          fontSize: 20,
                          letterSpacing: 1.8,
                          weight: FontWeight.w600,
                        ),
                      ),
                      Positioned(
                        left: 24,
                        bottom: 28,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'CARD HOLDER',
                              style: GoogleFonts.poppins(
                                color: Colors.white.withValues(alpha: 0.46),
                                fontSize: 8,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            _EncryptedCardTextLine(
                              revealed: 'NIDIN GEORGE',
                              encrypted: '3A 7C F1 90',
                              progress: _rowProgress(scanY: scanY, rowY: 150),
                              fontSize: 13,
                              letterSpacing: 0.8,
                              weight: FontWeight.w600,
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        left: 160,
                        bottom: 28,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'VALID',
                              style: GoogleFonts.poppins(
                                color: Colors.white.withValues(alpha: 0.46),
                                fontSize: 8,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            _EncryptedCardTextLine(
                              revealed: '10/31',
                              encrypted: '6C 2A',
                              progress: _rowProgress(scanY: scanY, rowY: 150),
                              fontSize: 13,
                              letterSpacing: 0.9,
                              weight: FontWeight.w600,
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        right: 24,
                        bottom: 26,
                        child: SizedBox(
                          width: 54,
                          height: 32,
                          child: Stack(
                            children: [
                              Positioned(
                                left: 0,
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFFE9EDF5)
                                        .withValues(alpha: 0.88),
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 0,
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFF8B93A2)
                                        .withValues(alpha: 0.82),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        top: scanY - 34,
                        child: IgnorePointer(
                          child: _ScanLightBand(progress: rawScan),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _EncryptedCardBackground extends StatelessWidget {
  const _EncryptedCardBackground();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1C1D22),
            Color(0xFF090A0D),
            Color(0xFF2C2E35),
          ],
          stops: [0, 0.56, 1],
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            left: -56,
            top: -70,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          Positioned(
            right: -42,
            bottom: -58,
            child: Container(
              width: 170,
              height: 170,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF9CA3AF).withValues(alpha: 0.08),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EncryptedCardTextLine extends StatelessWidget {
  final String revealed;
  final String encrypted;
  final double progress;
  final double fontSize;
  final double letterSpacing;
  final FontWeight weight;

  const _EncryptedCardTextLine({
    required this.revealed,
    required this.encrypted,
    required this.progress,
    required this.fontSize,
    required this.letterSpacing,
    required this.weight,
  });

  @override
  Widget build(BuildContext context) {
    final revealedOpacity = (1 - (progress * 1.35)).clamp(0.0, 1.0);
    final encryptedOpacity = ((progress - 0.18) / 0.82).clamp(0.0, 1.0);

    return Stack(
      children: [
        Opacity(
          opacity: revealedOpacity,
          child: Text(
            revealed,
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.visible,
            style: GoogleFonts.poppins(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: fontSize,
              height: 1,
              fontWeight: weight,
              letterSpacing: letterSpacing,
            ),
          ),
        ),
        Opacity(
          opacity: encryptedOpacity,
          child: Transform.translate(
            offset: Offset(0, 3 * (1 - progress)),
            child: Text(
              encrypted,
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.visible,
              style: GoogleFonts.poppins(
                color: const Color(0xFFDFE6F4),
                fontSize: fontSize,
                height: 1,
                fontWeight: weight,
                letterSpacing: letterSpacing,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ScanLightBand extends StatelessWidget {
  final double progress;

  const _ScanLightBand({
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final opacity = progress <= 0 || progress >= 1 ? 0.0 : 1.0;

    return Opacity(
      opacity: opacity,
      child: Container(
        height: 68,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFEEF5FF).withValues(alpha: 0),
              const Color(0xFFEEF5FF).withValues(alpha: 0.18),
              const Color(0xFFFFFFFF).withValues(alpha: 0.46),
              const Color(0xFF9CCBFF).withValues(alpha: 0.22),
              const Color(0xFFEEF5FF).withValues(alpha: 0),
            ],
            stops: const [0, 0.34, 0.5, 0.64, 1],
          ),
        ),
        child: Align(
          alignment: Alignment.center,
          child: Container(
            height: 1.4,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.84),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFB9DDFF).withValues(alpha: 0.78),
                  blurRadius: 18,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChipLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF6F623F).withValues(alpha: 0.54)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    canvas.drawLine(
      Offset(size.width * 0.33, 0),
      Offset(size.width * 0.33, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.66, 0),
      Offset(size.width * 0.66, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(0, size.height * 0.5),
      Offset(size.width, size.height * 0.5),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _ChipLinePainter oldDelegate) => false;
}

class _CardGrainPainter extends CustomPainter {
  final Color color;

  const _CardGrainPainter({
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;

    for (var i = 0; i < 22; i++) {
      final y = (i * 17.0) - 90;
      canvas.drawLine(
        Offset(-20, y),
        Offset(size.width + 30, y + 130),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CardGrainPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _StyledSvgAsset extends StatelessWidget {
  final String assetPath;
  final double height;

  const _StyledSvgAsset({
    required this.assetPath,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: rootBundle.loadString(assetPath),
      builder: (context, snapshot) {
        final rawSvg = snapshot.data;
        if (rawSvg == null) {
          return SizedBox(height: height);
        }

        return SvgPicture.string(
          _SvgStyleInliner.inline(rawSvg),
          height: height,
          fit: BoxFit.contain,
        );
      },
    );
  }
}

class _SvgStyleInliner {
  const _SvgStyleInliner._();

  static final RegExp _styleBlockPattern = RegExp(
    r'<style[^>]*>([\s\S]*?)<\/style>',
    multiLine: true,
  );
  static final RegExp _styleRulePattern = RegExp(
    r'([^{}]+)\{([^{}]*)\}',
    multiLine: true,
  );
  static final RegExp _styleCommentPattern = RegExp(r'/\*[\s\S]*?\*/');
  static final RegExp _classSelectorPattern = RegExp(r'\.([A-Za-z_][\w-]*)');
  static final RegExp _classPattern = RegExp(r'class="([^"]+)"');

  static String inline(String svg) {
    final styles = <String, Map<String, String>>{};

    for (final styleBlock in _styleBlockPattern.allMatches(svg)) {
      final css = (styleBlock.group(1) ?? '')
          .replaceAll(_styleCommentPattern, '')
          .replaceAll('<![CDATA[', '')
          .replaceAll(']]>', '');

      for (final rule in _styleRulePattern.allMatches(css)) {
        final selectorList = rule.group(1);
        final declarations = rule.group(2);
        if (selectorList == null || declarations == null) continue;

        final parsedDeclarations = _parseDeclarations(declarations);
        if (parsedDeclarations.isEmpty) continue;

        for (final selector in selectorList.split(',')) {
          final classMatch = _classSelectorPattern.firstMatch(selector.trim());
          final className = classMatch?.group(1);
          if (className == null) continue;

          styles[className] = {
            ...?styles[className],
            ...parsedDeclarations,
          };
        }
      }
    }

    if (styles.isEmpty) return svg;

    return svg.replaceAllMapped(_classPattern, (match) {
      final classes = match.group(1)!.split(RegExp(r'\s+'));
      final declarations = <String, String>{};

      for (final className in classes) {
        declarations.addAll(styles[className] ?? const {});
      }

      if (declarations.isEmpty) return match.group(0)!;

      return declarations.entries
          .where((entry) => entry.value.isNotEmpty)
          .map((entry) => '${entry.key}="${entry.value}"')
          .join(' ');
    }).replaceAll(_styleBlockPattern, '');
  }

  static Map<String, String> _parseDeclarations(String declarations) {
    final parsed = <String, String>{};

    for (final declaration in declarations.split(';')) {
      final parts = declaration.split(':');
      if (parts.length < 2) continue;

      final property = parts.first.trim();
      final value = parts.sublist(1).join(':').trim();
      final attribute = _cssPropertyToSvgAttribute(property);
      if (attribute == null) continue;

      parsed[attribute] = value.replaceAll('px', '');
    }

    return parsed;
  }

  static String? _cssPropertyToSvgAttribute(String property) {
    switch (property) {
      case 'fill':
      case 'stroke':
      case 'opacity':
      case 'clip-path':
      case 'clip-rule':
      case 'display':
      case 'fill-opacity':
      case 'fill-rule':
      case 'stop-color':
      case 'stop-opacity':
      case 'stroke-dasharray':
      case 'stroke-dashoffset':
      case 'stroke-linecap':
      case 'stroke-linejoin':
      case 'stroke-miterlimit':
      case 'stroke-width':
      case 'stroke-opacity':
        return property;
      default:
        return null;
    }
  }
}

class _SlideIndicator extends StatelessWidget {
  final int count;
  final int activeIndex;
  final SwalletPalette palette;

  const _SlideIndicator({
    required this.count,
    required this.activeIndex,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 26,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(count, (index) {
          final active = index == activeIndex;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            width: active ? 22 : 4,
            height: active ? 5 : 4,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(99),
              color: active
                  ? palette.text
                  : palette.textMuted.withValues(alpha: 0.46),
            ),
          );
        }),
      ),
    );
  }
}
