import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
    extends State<SecurityFeaturesIntroOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _shieldScale;
  late final Animation<double> _ringOpacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _shieldScale = Tween<double>(begin: 0.96, end: 1.04).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );
    _ringOpacity = Tween<double>(begin: 0.18, end: 0.38).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
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
    final media = MediaQuery.of(context);
    final maxWidth = media.size.width >= 600 ? 430.0 : media.size.width - 32;

    return Material(
      color: Colors.black.withValues(alpha: widget.isDark ? 0.76 : 0.58),
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 16),
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
                  _SecurityShieldAnimation(
                    palette: palette,
                    shieldScale: _shieldScale,
                    ringOpacity: _ringOpacity,
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Built for private card storage',
                    textAlign: TextAlign.center,
                    style: SwalletText.title.copyWith(
                      color: palette.text,
                      fontSize: 21,
                      height: 1.12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your wallet is protected before you add your first card.',
                    textAlign: TextAlign.center,
                    style: SwalletText.body.copyWith(
                      color: palette.textMuted,
                      height: 1.32,
                    ),
                  ),
                  const SizedBox(height: 18),
                  _FeatureRow(
                    icon: CupertinoIcons.wifi_slash,
                    title: 'Offline by design',
                    body: 'Card details stay on this device.',
                    palette: palette,
                  ),
                  const SizedBox(height: 10),
                  _FeatureRow(
                    icon: CupertinoIcons.lock_shield_fill,
                    title: 'Hive encrypted vault',
                    body: 'Saved cards are written to encrypted local storage.',
                    palette: palette,
                  ),
                  const SizedBox(height: 10),
                  _FeatureRow(
                    icon: CupertinoIcons.person_crop_circle_badge_checkmark,
                    title: 'Private unlock',
                    body: 'Your PIN and device auth guard access.',
                    palette: palette,
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton(
                      onPressed: widget.onDone,
                      child: const Text('Continue'),
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

class _SecurityShieldAnimation extends StatelessWidget {
  final SwalletPalette palette;
  final Animation<double> shieldScale;
  final Animation<double> ringOpacity;

  const _SecurityShieldAnimation({
    required this.palette,
    required this.shieldScale,
    required this.ringOpacity,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 112,
      height: 112,
      child: AnimatedBuilder(
        animation: shieldScale,
        builder: (context, _) {
          return Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 104,
                height: 104,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: palette.primary.withValues(alpha: ringOpacity.value),
                ),
              ),
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: palette.primaryContainer,
                  border: Border.all(
                    color: palette.primary.withValues(alpha: 0.28),
                  ),
                ),
              ),
              Transform.scale(
                scale: shieldScale.value,
                child: Icon(
                  CupertinoIcons.lock_shield_fill,
                  size: 44,
                  color: palette.onPrimaryContainer,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final SwalletPalette palette;

  const _FeatureRow({
    required this.icon,
    required this.title,
    required this.body,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: palette.surfaceLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: palette.outline.withValues(alpha: 0.58),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: palette.primaryContainer,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              icon,
              size: 21,
              color: palette.onPrimaryContainer,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: SwalletText.bodyMedium.copyWith(
                    color: palette.text,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: SwalletText.caption.copyWith(
                    color: palette.textMuted,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
