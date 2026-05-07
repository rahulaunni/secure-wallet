import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:swallet/widgets/add_card/add_card_material_tokens.dart';
import 'package:swallet/widgets/add_card/widgets/add_card_cta_button.dart';
import 'package:swallet/widgets/add_card/widgets/form_text.dart';

class OtherBankSetupSection extends StatefulWidget {
  final bool isDark;
  final String customBankName;
  final String? customBankLogoPath;
  final Color gradientStartColor;
  final Color gradientEndColor;
  final ValueChanged<String> onCustomBankNameChanged;
  final ValueChanged<Color> onGradientStartColorChanged;
  final ValueChanged<Color> onGradientEndColorChanged;
  final VoidCallback onPickCustomBankLogo;
  final VoidCallback onRemoveCustomBankLogo;
  final VoidCallback onNext;

  const OtherBankSetupSection({
    super.key,
    required this.isDark,
    required this.customBankName,
    required this.customBankLogoPath,
    required this.gradientStartColor,
    required this.gradientEndColor,
    required this.onCustomBankNameChanged,
    required this.onGradientStartColorChanged,
    required this.onGradientEndColorChanged,
    required this.onPickCustomBankLogo,
    required this.onRemoveCustomBankLogo,
    required this.onNext,
  });

  @override
  State<OtherBankSetupSection> createState() => _OtherBankSetupSectionState();
}

class _OtherBankSetupSectionState extends State<OtherBankSetupSection> {
  late final TextEditingController _bankNameCtrl;

  @override
  void initState() {
    super.initState();
    _bankNameCtrl = TextEditingController(text: widget.customBankName);
  }

  @override
  void didUpdateWidget(covariant OtherBankSetupSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.customBankName != _bankNameCtrl.text) {
      _bankNameCtrl.text = widget.customBankName;
    }
  }

  @override
  void dispose() {
    _bankNameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(
            'Custom bank',
            style: GoogleFonts.roboto(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: widget.isDark
                  ? const Color.fromARGB(255, 221, 221, 221)
                  : const Color(0xFF111827),
            ),
          ),
        ),
        const SizedBox(height: 24),
        FormText(
          label: 'Bank name',
          hint: 'Enter bank name',
          controller: _bankNameCtrl,
          leadingIcon: CupertinoIcons.building_2_fill,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.done,
          isDark: widget.isDark,
          onChanged: widget.onCustomBankNameChanged,
        ),
        const SizedBox(height: 12),
        _CustomBankLogoPicker(
          isDark: widget.isDark,
          logoPath: widget.customBankLogoPath,
          onPick: widget.onPickCustomBankLogo,
          onRemove: widget.onRemoveCustomBankLogo,
        ),
        const SizedBox(height: 16),
        _GradientColorSelector(
          isDark: widget.isDark,
          startColor: widget.gradientStartColor,
          endColor: widget.gradientEndColor,
          onStartChanged: widget.onGradientStartColorChanged,
          onEndChanged: widget.onGradientEndColorChanged,
        ),
        const SizedBox(height: 24),
        AddCardCTAButton(
          label: 'Next',
          onPressed: widget.onNext,
        ),
      ],
    );
  }
}

class _CustomBankLogoPicker extends StatelessWidget {
  final bool isDark;
  final String? logoPath;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  const _CustomBankLogoPicker({
    required this.isDark,
    required this.logoPath,
    required this.onPick,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AddCardMaterialTokens(isDark);
    final selectedPath = logoPath?.trim();
    final hasLogo = selectedPath != null &&
        selectedPath.isNotEmpty &&
        File(selectedPath).existsSync();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bank logo',
          style: GoogleFonts.roboto(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: tokens.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 6),
        Material(
          color: tokens.surfaceContainerHigh,
          borderRadius: tokens.controlRadius,
          child: InkWell(
            onTap: onPick,
            borderRadius: tokens.controlRadius,
            child: Container(
              constraints: const BoxConstraints(minHeight: 60),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: tokens.controlRadius,
                border: Border.all(color: tokens.outlineVariant),
              ),
              child: Row(
                children: [
                  if (hasLogo)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.file(
                        File(selectedPath),
                        width: 48,
                        height: 34,
                        fit: BoxFit.contain,
                      ),
                    )
                  else
                    Icon(
                      CupertinoIcons.photo,
                      size: 22,
                      color: tokens.onSurfaceVariant,
                    ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      hasLogo ? 'Logo selected' : 'Choose from gallery',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.roboto(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: hasLogo
                            ? tokens.onSurface
                            : tokens.onSurfaceVariant,
                      ),
                    ),
                  ),
                  if (hasLogo)
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(CupertinoIcons.xmark, size: 18),
                      color: tokens.onSurfaceVariant,
                      onPressed: onRemove,
                    ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    icon:
                        const Icon(CupertinoIcons.photo_on_rectangle, size: 20),
                    color: tokens.primary,
                    onPressed: onPick,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _GradientColorSelector extends StatefulWidget {
  final bool isDark;
  final Color startColor;
  final Color endColor;
  final ValueChanged<Color> onStartChanged;
  final ValueChanged<Color> onEndChanged;

  const _GradientColorSelector({
    required this.isDark,
    required this.startColor,
    required this.endColor,
    required this.onStartChanged,
    required this.onEndChanged,
  });

  @override
  State<_GradientColorSelector> createState() => _GradientColorSelectorState();
}

class _GradientColorSelectorState extends State<_GradientColorSelector> {
  int _activeColorIndex = 0;

  Color get _activeColor =>
      _activeColorIndex == 0 ? widget.startColor : widget.endColor;

  void _setActiveColor(Color color) {
    if (_activeColorIndex == 0) {
      widget.onStartChanged(color);
    } else {
      widget.onEndChanged(color);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AddCardMaterialTokens(widget.isDark);
    final activeHsv = HSVColor.fromColor(_activeColor);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Card gradient',
          style: GoogleFonts.roboto(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: tokens.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        _GradientColorTabs(
          isDark: widget.isDark,
          activeIndex: _activeColorIndex,
          startColor: widget.startColor,
          endColor: widget.endColor,
          onChanged: (index) => setState(() => _activeColorIndex = index),
        ),
        const SizedBox(height: 12),
        _ColorField(
          hsvColor: activeHsv,
          onChanged: (hsvColor) => _setActiveColor(hsvColor.toColor()),
        ),
        const SizedBox(height: 10),
        _HueSlider(
          hsvColor: activeHsv,
          onChanged: (hsvColor) => _setActiveColor(hsvColor.toColor()),
        ),
      ],
    );
  }
}

class _GradientColorTabs extends StatelessWidget {
  final bool isDark;
  final int activeIndex;
  final Color startColor;
  final Color endColor;
  final ValueChanged<int> onChanged;

  const _GradientColorTabs({
    required this.isDark,
    required this.activeIndex,
    required this.startColor,
    required this.endColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _GradientColorTab(
            label: 'Color 1',
            color: startColor,
            isSelected: activeIndex == 0,
            isDark: isDark,
            onTap: () => onChanged(0),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _GradientColorTab(
            label: 'Color 2',
            color: endColor,
            isSelected: activeIndex == 1,
            isDark: isDark,
            onTap: () => onChanged(1),
          ),
        ),
      ],
    );
  }
}

class _GradientColorTab extends StatelessWidget {
  final String label;
  final Color color;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _GradientColorTab({
    required this.label,
    required this.color,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AddCardMaterialTokens(isDark);
    final textColor = tokens.onSurface;
    final borderColor = isSelected ? tokens.primary : tokens.outlineVariant;
    final fillColor =
        isSelected ? tokens.primaryContainer : tokens.surfaceContainerHigh;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: fillColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: isSelected ? 1.4 : 1),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: isSelected ? 28 : 20,
              height: 10,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.8),
                  width: 1,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.roboto(
                  color: isSelected ? tokens.onPrimaryContainer : textColor,
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ColorField extends StatelessWidget {
  final HSVColor hsvColor;
  final ValueChanged<HSVColor> onChanged;

  const _ColorField({
    required this.hsvColor,
    required this.onChanged,
  });

  static const double _height = 132;
  static const double _thumbSize = 18;

  void _updateColor(Offset localPosition, Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    final saturation = (localPosition.dx / size.width).clamp(0.0, 1.0);
    final value = (1 - (localPosition.dy / size.height)).clamp(0.0, 1.0);

    onChanged(
      HSVColor.fromAHSV(
        1,
        hsvColor.hue,
        saturation,
        value,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hueColor = HSVColor.fromAHSV(1, hsvColor.hue, 1, 1).toColor();

    return SizedBox(
      height: _height,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(constraints.maxWidth, _height);
          final thumbLeft =
              (hsvColor.saturation * size.width) - (_thumbSize / 2);
          final thumbTop =
              ((1 - hsvColor.value) * size.height) - (_thumbSize / 2);

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (details) => _updateColor(details.localPosition, size),
            onPanUpdate: (details) => _updateColor(details.localPosition, size),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ColoredBox(color: hueColor),
                  ),
                  const Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [Colors.white, Colors.transparent],
                        ),
                      ),
                    ),
                  ),
                  const Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: thumbLeft.clamp(0.0, size.width - _thumbSize),
                    top: thumbTop.clamp(0.0, size.height - _thumbSize),
                    child: Container(
                      width: _thumbSize,
                      height: _thumbSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: hsvColor.toColor(),
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.28),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _HueSlider extends StatelessWidget {
  final HSVColor hsvColor;
  final ValueChanged<HSVColor> onChanged;

  const _HueSlider({
    required this.hsvColor,
    required this.onChanged,
  });

  static const double _height = 28;
  static const double _thumbSize = 12;

  static const List<Color> _hueColors = [
    Color(0xFFE11D1D),
    Color(0xFFEAB308),
    Color(0xFF16A34A),
    Color(0xFF06B6D4),
    Color(0xFF1D4ED8),
    Color(0xFF7C3AED),
    Color(0xFFDB2777),
    Color(0xFFE11D1D),
  ];

  void _updateColor(double localDx, double width) {
    if (width <= 0) return;
    final percent = (localDx / width).clamp(0.0, 1.0);
    final hue = percent * 360.0;
    onChanged(
      HSVColor.fromAHSV(
        1,
        hue,
        hsvColor.saturation,
        hsvColor.value,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hue = hsvColor.hue;

    return SizedBox(
      height: _height,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final thumbLeft = ((hue / 360.0) * width - (_thumbSize / 2)).clamp(
            0.0,
            width - _thumbSize,
          );

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (details) {
              _updateColor(details.localPosition.dx, width);
            },
            onHorizontalDragUpdate: (details) {
              _updateColor(details.localPosition.dx, width);
            },
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      gradient: const LinearGradient(colors: _hueColors),
                    ),
                  ),
                ),
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 80),
                  curve: Curves.easeOut,
                  left: thumbLeft,
                  top: (_height - _thumbSize) / 2,
                  child: Container(
                    width: _thumbSize,
                    height: _thumbSize,
                    decoration: BoxDecoration(
                      color: hsvColor.toColor(),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.24),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
