import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

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
      assetPath: 'assets/onboarding/no internet.svg',
      title: 'Completely offline',
      body:
          'Your saved card details stay on this device, without needing a network connection.',
    ),
    _SecurityIntroSlide(
      assetPath: 'assets/onboarding/secure card.svg',
      title: 'Hive protected vault',
      body:
          'Cards are stored locally in an encrypted Hive box so your data stays protected.',
    ),
    _SecurityIntroSlide(
      assetPath: 'assets/onboarding/fingerprint.svg',
      title: 'Private unlock',
      body:
          'Your app PIN and device authentication guard access before cards open.',
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
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 158,
                          height: 54,
                          child: FilledButton(
                            key:
                                const ValueKey('security_intro_primary_button'),
                            onPressed: _index == _slides.length - 1
                                ? widget.onDone
                                : _continue,
                            style: FilledButton.styleFrom(
                              backgroundColor: buttonColor,
                              foregroundColor: buttonText,
                              elevation: 0,
                              shape: const StadiumBorder(),
                              textStyle: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                height: 1,
                              ),
                            ),
                            child: Text(
                              _index == _slides.length - 1
                                  ? 'Continue'
                                  : 'Next',
                              maxLines: 1,
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
  final String title;
  final String body;

  const _SecurityIntroSlide({
    required this.assetPath,
    required this.title,
    required this.body,
  });
}

class _SecurityIntroSlideView extends StatelessWidget {
  final _SecurityIntroSlide slide;
  final bool isDark;

  const _SecurityIntroSlideView({
    super.key,
    required this.slide,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final palette = SwalletPalette(isDark);

    return Column(
      children: [
        const Spacer(flex: 1),
        SizedBox(
          height: 310,
          child: Center(
            child: _StyledSvgAsset(
              assetPath: slide.assetPath,
              height: 286,
            ),
          ),
        ),
        const Spacer(flex: 1),
        Text(
          slide.title,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 20,
            height: 1,
            fontWeight: FontWeight.w600,
            color: palette.text,
          ),
        ),
        const SizedBox(height: 24),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 280),
          child: Text(
            slide.body,
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
        const Spacer(flex: 2),
      ],
    );
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
