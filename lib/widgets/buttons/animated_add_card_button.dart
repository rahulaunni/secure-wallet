import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:swallet/data/local/hive_boxes.dart';
import 'package:swallet/theme/swallet_theme.dart';
import 'package:swallet/utils/haptics.dart';
import 'package:swallet/widgets/add_card/add_card_material_tokens.dart';

class AnimatedAddCardButton extends StatelessWidget {
  final bool collapsed;
  final VoidCallback onTap;

  const AnimatedAddCardButton({
    super.key,
    required this.collapsed,
    required this.onTap,
  });

  static const double _height = 56;
  static const double _collapsedWidth = 56;
  static const double _expandedWidth = 136;
  static const double _iconSize = 22;
  static const double _gapWidth = 8;
  static const double _collapsedHorizontalPadding = 15;
  static const double _expandedHorizontalPadding = 14;
  static const BorderRadius _buttonRadius = BorderRadius.all(
    Radius.circular(_height / 2),
  );
  static const Duration _duration = Duration(milliseconds: 260);
  static const Curve _curve = Curves.easeInOutCubic;

  @override
  Widget build(BuildContext context) {
    final settingsBox = Hive.box(HiveBoxes.settings);
    final isDark = settingsBox.get('is_dark', defaultValue: true);
    final tokens = AddCardMaterialTokens(isDark);
    final horizontalPadding =
        collapsed ? _collapsedHorizontalPadding : _expandedHorizontalPadding;

    return Material(
      color: Colors.transparent,
      borderRadius: _buttonRadius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          SwalletHaptics.bankSelected();
          onTap();
        },
        borderRadius: _buttonRadius,
        child: AnimatedContainer(
          duration: _duration,
          curve: _curve,
          height: _height,
          width: collapsed ? _collapsedWidth : _expandedWidth,
          decoration: BoxDecoration(
            color: tokens.primary,
            borderRadius: _buttonRadius,
            boxShadow: [
              BoxShadow(
                color: tokens.primary.withValues(alpha: isDark ? 0.28 : 0.18),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: _buttonRadius,
            child: AnimatedPadding(
              duration: _duration,
              curve: _curve,
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Center(
                child: TweenAnimationBuilder<double>(
                  duration: _duration,
                  curve: _curve,
                  tween: Tween<double>(end: collapsed ? 0 : 1),
                  builder: (context, textFactor, child) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          CupertinoIcons.add,
                          size: _iconSize,
                          color: Colors.white,
                        ),
                        ClipRect(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            widthFactor: textFactor,
                            child: Opacity(
                              opacity: textFactor,
                              child: Padding(
                                padding: const EdgeInsets.only(left: _gapWidth),
                                child: Text(
                                  'Add card',
                                  maxLines: 1,
                                  softWrap: false,
                                  overflow: TextOverflow.clip,
                                  textScaler: TextScaler.noScaling,
                                  style: SwalletText.button.copyWith(
                                    color: Colors.white,
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
              ),
            ),
          ),
        ),
      ),
    );
  }
}
