import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:swallet/constants/card_visuals.dart';
import 'package:swallet/theme/swallet_theme.dart';
import 'package:swallet/widgets/add_card/add_card_material_tokens.dart';
import 'package:swallet/widgets/add_card/widgets/add_card_cta_button.dart';
import 'package:swallet/widgets/add_card/widgets/form_text.dart';
import 'package:swallet/widgets/card/card_visual_asset_layer.dart';

enum CustomCardVisualMode { gradient, image }

class OtherBankSetupSection extends StatefulWidget {
  final bool isDark;
  final String customBankName;
  final String? customBankLogoPath;
  final String? customCardImagePath;
  final String? customCardPatternAssetPath;
  final Color gradientStartColor;
  final Color gradientMiddleColor;
  final Color gradientEndColor;
  final CustomCardVisualMode visualMode;
  final Alignment imageAlignment;
  final ValueChanged<String> onCustomBankNameChanged;
  final ValueChanged<Color> onGradientStartColorChanged;
  final ValueChanged<Color> onGradientMiddleColorChanged;
  final ValueChanged<Color> onGradientEndColorChanged;
  final ValueChanged<CustomCardVisualMode> onVisualModeChanged;
  final ValueChanged<String?> onPatternChanged;
  final ValueChanged<Alignment> onImageAlignmentChanged;
  final VoidCallback onPickCustomBankLogo;
  final VoidCallback onRemoveCustomBankLogo;
  final VoidCallback onPickCustomCardImage;
  final VoidCallback onRemoveCustomCardImage;
  final VoidCallback onNext;

  const OtherBankSetupSection({
    super.key,
    required this.isDark,
    required this.customBankName,
    required this.customBankLogoPath,
    required this.customCardImagePath,
    required this.customCardPatternAssetPath,
    required this.gradientStartColor,
    required this.gradientMiddleColor,
    required this.gradientEndColor,
    required this.visualMode,
    required this.imageAlignment,
    required this.onCustomBankNameChanged,
    required this.onGradientStartColorChanged,
    required this.onGradientMiddleColorChanged,
    required this.onGradientEndColorChanged,
    required this.onVisualModeChanged,
    required this.onPatternChanged,
    required this.onImageAlignmentChanged,
    required this.onPickCustomBankLogo,
    required this.onRemoveCustomBankLogo,
    required this.onPickCustomCardImage,
    required this.onRemoveCustomCardImage,
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
            style: SwalletText.bodyMedium.copyWith(
              color: AddCardMaterialTokens(widget.isDark).onSurface,
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
        CardVisualCustomizationSection(
          isDark: widget.isDark,
          startColor: widget.gradientStartColor,
          middleColor: widget.gradientMiddleColor,
          endColor: widget.gradientEndColor,
          imagePath: widget.customCardImagePath,
          patternAssetPath: widget.customCardPatternAssetPath,
          visualMode: widget.visualMode,
          imageAlignment: widget.imageAlignment,
          onStartChanged: widget.onGradientStartColorChanged,
          onMiddleChanged: widget.onGradientMiddleColorChanged,
          onEndChanged: widget.onGradientEndColorChanged,
          onVisualModeChanged: widget.onVisualModeChanged,
          onPatternChanged: widget.onPatternChanged,
          onImageAlignmentChanged: widget.onImageAlignmentChanged,
          onPickImage: widget.onPickCustomCardImage,
          onRemoveImage: widget.onRemoveCustomCardImage,
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
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bank logo',
          style: SwalletText.section.copyWith(
            fontSize: 13,
            color: tokens.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 6),
        Material(
          color: tokens.surfaceContainer,
          shape: RoundedRectangleBorder(
            borderRadius: tokens.controlRadius,
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onPick,
            borderRadius: tokens.controlRadius,
            child: Container(
              constraints: const BoxConstraints(minHeight: 60),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                      style: SwalletText.bodyMedium.copyWith(
                        fontSize: 15,
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

class CardVisualCustomizationSection extends StatefulWidget {
  final bool isDark;
  final Color startColor;
  final Color middleColor;
  final Color endColor;
  final String? imagePath;
  final String? patternAssetPath;
  final CustomCardVisualMode visualMode;
  final Alignment imageAlignment;
  final ValueChanged<Color> onStartChanged;
  final ValueChanged<Color> onMiddleChanged;
  final ValueChanged<Color> onEndChanged;
  final ValueChanged<CustomCardVisualMode> onVisualModeChanged;
  final ValueChanged<String?> onPatternChanged;
  final ValueChanged<Alignment> onImageAlignmentChanged;
  final VoidCallback onPickImage;
  final VoidCallback onRemoveImage;

  const CardVisualCustomizationSection({
    super.key,
    required this.isDark,
    required this.startColor,
    required this.middleColor,
    required this.endColor,
    required this.imagePath,
    required this.patternAssetPath,
    required this.visualMode,
    required this.imageAlignment,
    required this.onStartChanged,
    required this.onMiddleChanged,
    required this.onEndChanged,
    required this.onVisualModeChanged,
    required this.onPatternChanged,
    required this.onImageAlignmentChanged,
    required this.onPickImage,
    required this.onRemoveImage,
  });

  @override
  State<CardVisualCustomizationSection> createState() =>
      _CardVisualCustomizationSectionState();
}

class _CardVisualCustomizationSectionState
    extends State<CardVisualCustomizationSection> {
  int _activeColorIndex = 0;
  bool _choosingGradientPattern = false;

  Color get _activeColor => switch (_activeColorIndex) {
        0 => widget.startColor,
        1 => widget.middleColor,
        _ => widget.endColor,
      };

  void _setActiveColor(Color color) {
    if (_activeColorIndex == 0) {
      widget.onStartChanged(color);
    } else if (_activeColorIndex == 1) {
      widget.onMiddleChanged(color);
    } else {
      widget.onEndChanged(color);
    }
  }

  @override
  void didUpdateWidget(covariant CardVisualCustomizationSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.visualMode != oldWidget.visualMode &&
        widget.visualMode != CustomCardVisualMode.gradient) {
      _choosingGradientPattern = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AddCardMaterialTokens(widget.isDark);
    final activeHsv = HSVColor.fromColor(_activeColor);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Card visual',
          style: SwalletText.section.copyWith(
            fontSize: 13,
            color: tokens.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        _CustomVisualModeSelector(
          isDark: widget.isDark,
          selected: widget.visualMode,
          onChanged: widget.onVisualModeChanged,
        ),
        const SizedBox(height: 12),
        if (widget.visualMode == CustomCardVisualMode.gradient) ...[
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeOutCubic,
            child: _choosingGradientPattern
                ? _GradientPatternCarousel(
                    key: const ValueKey('pattern_phase'),
                    isDark: widget.isDark,
                    startColor: widget.startColor,
                    middleColor: widget.middleColor,
                    endColor: widget.endColor,
                    selectedAssetPath: widget.patternAssetPath,
                    onChanged: widget.onPatternChanged,
                    onBack: () =>
                        setState(() => _choosingGradientPattern = false),
                  )
                : Column(
                    key: const ValueKey('color_phase'),
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _ColorField(
                              hsvColor: activeHsv,
                              onChanged: (hsvColor) =>
                                  _setActiveColor(hsvColor.toColor()),
                            ),
                          ),
                          const SizedBox(width: 12),
                          _GradientColorRoundSelector(
                            activeIndex: _activeColorIndex,
                            startColor: widget.startColor,
                            middleColor: widget.middleColor,
                            endColor: widget.endColor,
                            isDark: widget.isDark,
                            onChanged: (index) =>
                                setState(() => _activeColorIndex = index),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _HueSlider(
                        hsvColor: activeHsv,
                        onChanged: (hsvColor) =>
                            _setActiveColor(hsvColor.toColor()),
                      ),
                      const SizedBox(height: 12),
                      _PatternPhaseButton(
                        isDark: widget.isDark,
                        onTap: () =>
                            setState(() => _choosingGradientPattern = true),
                      ),
                    ],
                  ),
          ),
        ] else
          _CardImageVisualPicker(
            isDark: widget.isDark,
            imagePath: widget.imagePath,
            imageAlignment: widget.imageAlignment,
            onPick: widget.onPickImage,
            onRemove: widget.onRemoveImage,
            onAlignmentChanged: widget.onImageAlignmentChanged,
          ),
      ],
    );
  }
}

class _PatternPhaseButton extends StatelessWidget {
  final bool isDark;
  final VoidCallback onTap;

  const _PatternPhaseButton({
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AddCardMaterialTokens(isDark);

    return Material(
      color: tokens.surfaceContainer,
      borderRadius: tokens.controlRadius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: tokens.controlRadius,
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              Icon(
                CupertinoIcons.rectangle_grid_2x2,
                size: 20,
                color: tokens.primary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Choose pattern',
                  style: SwalletText.bodyMedium.copyWith(
                    fontSize: 14,
                    color: tokens.onSurface,
                  ),
                ),
              ),
              Icon(
                CupertinoIcons.chevron_right,
                size: 18,
                color: tokens.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GradientPatternCarousel extends StatelessWidget {
  final bool isDark;
  final Color startColor;
  final Color middleColor;
  final Color endColor;
  final String? selectedAssetPath;
  final ValueChanged<String?> onChanged;
  final VoidCallback onBack;

  const _GradientPatternCarousel({
    super.key,
    required this.isDark,
    required this.startColor,
    required this.middleColor,
    required this.endColor,
    required this.selectedAssetPath,
    required this.onChanged,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AddCardMaterialTokens(isDark);
    final assets = CardVisuals.customVisualAssetPaths;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onBack,
              child: Icon(
                CupertinoIcons.chevron_left,
                size: 22,
                color: tokens.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Pattern',
              style: SwalletText.section.copyWith(
                fontSize: 13,
                color: tokens.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 112,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: assets.length + 1,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final assetPath = index == 0 ? null : assets[index - 1];
              return _PatternPreviewTile(
                isDark: isDark,
                startColor: startColor,
                middleColor: middleColor,
                endColor: endColor,
                assetPath: assetPath,
                selected: selectedAssetPath == assetPath,
                onTap: () => onChanged(assetPath),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _PatternPreviewTile extends StatelessWidget {
  final bool isDark;
  final Color startColor;
  final Color middleColor;
  final Color endColor;
  final String? assetPath;
  final bool selected;
  final VoidCallback onTap;

  const _PatternPreviewTile({
    required this.isDark,
    required this.startColor,
    required this.middleColor,
    required this.endColor,
    required this.assetPath,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AddCardMaterialTokens(isDark);
    final visual = CardVisuals.customGradient(
      startColor,
      endColor,
      middle: middleColor,
      visualAssetPath: assetPath,
      previewBoost: true,
    );

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 124,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              height: 78,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: selected
                      ? tokens.primary
                      : tokens.outlineVariant.withValues(alpha: 0.54),
                  width: selected ? 2 : 1,
                ),
              ),
              padding: const EdgeInsets.all(3),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(gradient: visual.gradient),
                    ),
                    if (assetPath != null)
                      CardVisualAssetLayer(
                        visual: visual,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    if (assetPath == null)
                      Center(
                        child: Text(
                          'None',
                          style: SwalletText.bodyMedium.copyWith(
                            fontSize: 13,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 7),
            Text(
              assetPath == null
                  ? 'None'
                  : CardVisuals.customVisualAssetName(assetPath!),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: SwalletText.caption.copyWith(
                color: selected ? tokens.primary : tokens.onSurfaceVariant,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomVisualModeSelector extends StatelessWidget {
  final bool isDark;
  final CustomCardVisualMode selected;
  final ValueChanged<CustomCardVisualMode> onChanged;

  const _CustomVisualModeSelector({
    required this.isDark,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AddCardMaterialTokens(isDark);
    const outerRadius = 16.0;
    const innerPadding = 4.0;
    const innerRadius = outerRadius - innerPadding;

    return Container(
      height: 52,
      padding: const EdgeInsets.all(innerPadding),
      decoration: BoxDecoration(
        color: tokens.surfaceContainer,
        borderRadius: BorderRadius.circular(outerRadius),
      ),
      child: Row(
        children: [
          Expanded(
            child: _CustomVisualModeChip(
              label: 'Gradient',
              icon: CupertinoIcons.color_filter,
              selected: selected == CustomCardVisualMode.gradient,
              tokens: tokens,
              radius: innerRadius,
              onTap: () => onChanged(CustomCardVisualMode.gradient),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _CustomVisualModeChip(
              label: 'Image',
              icon: CupertinoIcons.photo,
              selected: selected == CustomCardVisualMode.image,
              tokens: tokens,
              radius: innerRadius,
              onTap: () => onChanged(CustomCardVisualMode.image),
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomVisualModeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final AddCardMaterialTokens tokens;
  final double radius;
  final VoidCallback onTap;

  const _CustomVisualModeChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.tokens,
    required this.radius,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(radius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          height: double.infinity,
          decoration: BoxDecoration(
            color: selected ? tokens.segmentedSelected : Colors.transparent,
            borderRadius: BorderRadius.circular(radius),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedScale(
                scale: selected ? 1.0 : 0.92,
                duration: const Duration(milliseconds: 180),
                child: Icon(
                  icon,
                  size: 20,
                  color: selected
                      ? tokens.onSegmentedSelected
                      : tokens.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: SwalletText.bodyMedium.copyWith(
                  fontSize: 14,
                  color: selected
                      ? tokens.onSegmentedSelected
                      : tokens.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GradientColorRoundSelector extends StatelessWidget {
  final int activeIndex;
  final Color startColor;
  final Color middleColor;
  final Color endColor;
  final bool isDark;
  final ValueChanged<int> onChanged;

  const _GradientColorRoundSelector({
    required this.activeIndex,
    required this.startColor,
    required this.middleColor,
    required this.endColor,
    required this.isDark,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AddCardMaterialTokens(isDark);

    return SizedBox(
      width: 44,
      child: Column(
        children: [
          _GradientColorDot(
            label: '1',
            color: startColor,
            selected: activeIndex == 0,
            tokens: tokens,
            onTap: () => onChanged(0),
          ),
          const SizedBox(height: 10),
          _GradientColorDot(
            label: '2',
            color: middleColor,
            selected: activeIndex == 1,
            tokens: tokens,
            onTap: () => onChanged(1),
          ),
          const SizedBox(height: 10),
          _GradientColorDot(
            label: '3',
            color: endColor,
            selected: activeIndex == 2,
            tokens: tokens,
            onTap: () => onChanged(2),
          ),
        ],
      ),
    );
  }
}

class _GradientColorDot extends StatelessWidget {
  final String label;
  final Color color;
  final bool selected;
  final AddCardMaterialTokens tokens;
  final VoidCallback onTap;

  const _GradientColorDot({
    required this.label,
    required this.color,
    required this.selected,
    required this.tokens,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: ValueKey('gradient_color_dot_$label'),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          border: Border.all(
            color: selected
                ? tokens.primary
                : Colors.white.withValues(alpha: 0.62),
            width: selected ? 2.4 : 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: selected ? 0.22 : 0.12),
              blurRadius: selected ? 10 : 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: SwalletText.bodyMedium.copyWith(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _CardImageVisualPicker extends StatelessWidget {
  final bool isDark;
  final String? imagePath;
  final Alignment imageAlignment;
  final VoidCallback onPick;
  final VoidCallback onRemove;
  final ValueChanged<Alignment> onAlignmentChanged;

  const _CardImageVisualPicker({
    required this.isDark,
    required this.imagePath,
    required this.imageAlignment,
    required this.onPick,
    required this.onRemove,
    required this.onAlignmentChanged,
  });

  void _moveImage(DragUpdateDetails details) {
    final next = Alignment(
      (imageAlignment.x + details.delta.dx / 70).clamp(-1.0, 1.0),
      (imageAlignment.y + details.delta.dy / 45).clamp(-1.0, 1.0),
    );
    onAlignmentChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AddCardMaterialTokens(isDark);
    final selectedPath = imagePath?.trim();
    final hasImage = selectedPath != null &&
        selectedPath.isNotEmpty &&
        File(selectedPath).existsSync();

    return Material(
      color: tokens.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: tokens.controlRadius,
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPick,
        borderRadius: tokens.controlRadius,
        child: Container(
          height: 132,
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              AspectRatio(
                aspectRatio: 1.58,
                child: GestureDetector(
                  onTap: onPick,
                  onPanUpdate: hasImage ? _moveImage : null,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (hasImage)
                          Image.file(
                            File(selectedPath),
                            fit: BoxFit.cover,
                            alignment: imageAlignment,
                          )
                        else
                          ColoredBox(
                            color: tokens.surfaceContainerHigh,
                            child: Icon(
                              CupertinoIcons.photo,
                              size: 28,
                              color: tokens.onSurfaceVariant,
                            ),
                          ),
                        if (hasImage)
                          Positioned(
                            right: 8,
                            bottom: 8,
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black.withValues(alpha: 0.38),
                              ),
                              child: const Icon(
                                CupertinoIcons.move,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  hasImage ? 'Image selected' : 'Choose image',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: SwalletText.bodyMedium.copyWith(
                    fontSize: 15,
                    color:
                        hasImage ? tokens.onSurface : tokens.onSurfaceVariant,
                  ),
                ),
              ),
              if (hasImage)
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(CupertinoIcons.xmark, size: 18),
                  color: tokens.onSurfaceVariant,
                  onPressed: onRemove,
                ),
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(CupertinoIcons.photo_on_rectangle, size: 20),
                color: tokens.primary,
                onPressed: onPick,
              ),
            ],
          ),
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
