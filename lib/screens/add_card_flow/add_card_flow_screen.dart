import 'dart:io';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import 'package:swallet/constants/card_visuals.dart';
import 'package:swallet/data/bank_assets.dart';
import 'package:swallet/models/card_data.dart';
import 'package:swallet/models/card_network.dart';
import 'package:swallet/models/card_type.dart';
import 'package:swallet/theme/swallet_theme.dart';
import 'constants/add_card_layout_constants.dart';
import 'widgets/add_card_preview_stack.dart';
import 'widgets/card_form_section_host.dart';
import 'widgets/bank_selection_section.dart';
import 'widgets/other_bank_setup_section.dart';
// import 'widgets/add_card_background.dart'; // Unused, commented out

import 'package:swallet/widgets/add_card/sections/card_form_section.dart';
import 'package:swallet/widgets/add_card/add_card_material_tokens.dart';
import 'package:swallet/widgets/add_card/widgets/add_card_cta_button.dart';
import 'package:swallet/utils/adaptive_layout.dart';
import 'package:swallet/utils/card_number_format.dart';
import 'package:swallet/utils/haptics.dart';

class AddCardFlowController {
  _AddCardFlowScreenState? _state;

  bool handleBack() {
    final state = _state;
    if (state == null) return false;
    state._handleEmbeddedBack();
    return true;
  }
}

class AddCardFlowScreen extends StatefulWidget {
  final bool isDark;
  final ValueChanged<CardData> onCardAdded;
  final ValueChanged<CardData>? onCardUpdated;
  final CardData? initialCard;
  final VoidCallback? onClose;
  final bool embedded;
  final AddCardFlowController? controller;

  const AddCardFlowScreen({
    super.key,
    required this.isDark,
    required this.onCardAdded,
    this.onCardUpdated,
    this.initialCard,
    this.onClose,
    this.embedded = false,
    this.controller,
  });

  @override
  State<AddCardFlowScreen> createState() => _AddCardFlowScreenState();
}

class _AddCardFlowScreenState extends State<AddCardFlowScreen>
    with TickerProviderStateMixin {
  // ================= STATE VARIABLES =================
  String? _selectedBankCid;
  bool _isBankSelected = false;

  // -- Drag & Animation --
  double _dragOffset = 0.0;
  late AnimationController _dragAnimationController;
  Animation<double>? _dragAnimation;

  // -- Scroll Control --
  final ScrollController _scrollController = ScrollController();

  // -- Card Data --
  String _cardNumber = '';
  String _expiry = '';
  String _cvv = '';
  String _holderName = '';
  String _customBankName = '';
  String? _customBankLogoPath;
  String? _customCardImagePath;
  String? _customCardPatternAssetPath;
  CustomCardVisualMode _customCardVisualMode = CustomCardVisualMode.gradient;
  Alignment _customCardImageAlignment = Alignment.center;
  bool _otherBankDetailsReady = false;
  bool _showBuiltInVisualEditor = false;
  Color _customGradientStartColor = const Color(0xFF111827);
  Color _customGradientMiddleColor = const Color(0xFF1F4F9A);
  Color _customGradientEndColor = const Color(0xFF2563EB);
  bool _hasCustomVisualOverride = false;
  CardNetwork? _cardNetwork;
  CardType _cardType = CardType.credit;
  final ImagePicker _imagePicker = ImagePicker();

  // -- Layout Constants --
  static const double _previewTopOffset = 32;
  static const double _previewMinScale = 0.93;

  static const Duration _bankExitDuration = Duration(milliseconds: 320);
  static const Duration _formEnterDuration = Duration(milliseconds: 360);
  static const Curve _transitionCurve = Curves.easeOutCubic;

  bool _keyboardHapticFired = false;

  bool get _isEditMode => widget.initialCard != null;

  void _seedCustomGradientFromBank(
    String cid, {
    bool includePattern = false,
  }) {
    if (cid == BankAssets.otherBankId) return;

    final bankVisual = CardVisuals.forBank(cid);
    final colors = bankVisual.gradient.colors;
    if (colors.isEmpty) return;
    final editableColors = CardVisuals.editableGradientColorsForBank(cid);

    _customGradientStartColor = editableColors.first;
    _customGradientMiddleColor = editableColors[1];
    _customGradientEndColor = editableColors.last;
    if (includePattern) {
      _customCardPatternAssetPath ??= bankVisual.visualAssetPath;
    }
  }

  @override
  void initState() {
    super.initState();
    widget.controller?._state = this;
    _dragAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _dragAnimationController.addListener(() {
      if (_dragAnimation != null) {
        setState(() {
          _dragOffset = _dragAnimation!.value;
        });
      }
    });

    final initialCard = widget.initialCard;
    if (initialCard != null) {
      _loadInitialCard(initialCard);
    }
  }

  @override
  void dispose() {
    if (widget.controller?._state == this) {
      widget.controller?._state = null;
    }
    _dragAnimationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ================= LOGIC: SCROLL & DRAG PHYSICS =================

  bool _handleScrollNotification(ScrollNotification notification) {
    if (_isBankSelected) return false;

    // 1. HANDLE OVERSCROLL
    if (notification is OverscrollNotification) {
      if (notification.overscroll < 0) {
        setState(() {
          _dragOffset -= notification.overscroll;
        });
      }
    }
    // 2. HANDLE UPDATES
    else if (notification is ScrollUpdateNotification) {
      final double delta = notification.scrollDelta ?? 0;

      if (_dragOffset > 0) {
        setState(() {
          _dragOffset -= delta;
          if (_dragOffset < 0) _dragOffset = 0;
        });

        if (_scrollController.hasClients && _scrollController.offset != 0) {
          _scrollController.jumpTo(0);
        }
      }
    }

    // 3. HANDLE RELEASE
    if (notification is ScrollEndNotification) {
      if (_dragOffset > 0) {
        _handleDragEnd();
      }
    }

    return false;
  }

  void _handleDragEnd() {
    if (_isBankSelected) return;

    final screenHeight = MediaQuery.of(context).size.height;
    final bool shouldClose = _dragOffset > 80;

    _dragAnimationController.reset();

    if (shouldClose) {
      // === ANIMATE OUT (CLOSE) ===
      final start = _dragOffset;
      final end = screenHeight;

      _dragAnimation = Tween<double>(begin: start, end: end).animate(
        CurvedAnimation(
          parent: _dragAnimationController,
          curve: Curves.easeOutCubic,
        ),
      );

      _dragAnimationController.forward().then((_) {
        if (mounted) _close();
      });
    } else {
      // === SNAP BACK (DOCK) ===
      final start = _dragOffset;
      const end = 0.0;

      _dragAnimation = Tween<double>(begin: start, end: end).animate(
        CurvedAnimation(
          parent: _dragAnimationController,
          curve: Curves.easeOutQuart,
        ),
      );

      _dragAnimationController.duration = const Duration(milliseconds: 300);
      _dragAnimationController.forward();
    }
  }

  void _close() {
    final onClose = widget.onClose;
    if (onClose != null) {
      onClose();
      return;
    }

    Navigator.of(context).pop();
  }

  void _handleEmbeddedBack() {
    if (_isBankSelected) {
      _onBackFromSelectedBank();
      return;
    }

    _close();
  }

  // ================= HELPERS =================

  double _previewTop(BuildContext context) {
    return MediaQuery.of(context).padding.top + _previewTopOffset;
  }

  double _keyboardHeight(BuildContext context) {
    return MediaQuery.of(context).viewInsets.bottom;
  }

  EdgeInsets _surfaceInsets(Size size) {
    if (widget.embedded) {
      final paneWidth = math.min(size.width, AdaptiveLayout.formPaneMaxWidth);
      final targetWidth = math.min(
        paneWidth - 32,
        AdaptiveLayout.phoneCardWidth,
      );
      final inset = math.max(16.0, (paneWidth - targetWidth) / 2);
      return EdgeInsets.symmetric(horizontal: inset);
    }

    final isTablet =
        math.min(size.width, size.height) >= AdaptiveLayout.compactWidthMax;
    if (!isTablet) {
      return const EdgeInsets.symmetric(horizontal: 16);
    }

    if (size.width > size.height) {
      return EdgeInsets.only(
        left: math.max(
          16.0,
          size.width - AdaptiveLayout.formPaneMaxWidth + 16,
        ),
        right: 16,
      );
    }

    final inset = math.max(
      16.0,
      (size.width - AdaptiveLayout.phoneCardWidth) / 2,
    );
    return EdgeInsets.symmetric(horizontal: inset);
  }

  void _loadInitialCard(CardData card) {
    final isOtherBank = card.bankCid == BankAssets.otherBankId;
    final bankColors = isOtherBank
        ? null
        : CardVisuals.editableGradientColorsForBank(card.bankCid);
    final hasCustomGradient = card.customGradientStartColor != null &&
        card.customGradientEndColor != null;
    final hasCustomImage =
        card.customCardVisualMode == CustomCardVisualMode.image.index &&
            card.customCardImagePath != null;

    _selectedBankCid = card.bankCid;
    _isBankSelected = true;
    _cardNumber = card.cardNumber;
    _expiry = card.expiry;
    _cvv = card.cvv;
    _holderName = card.holderName;
    _customBankName = card.customBankName ?? '';
    _customBankLogoPath = card.customBankLogoPath;
    _customCardImagePath = card.customCardImagePath;
    _customCardPatternAssetPath = card.customCardPatternAssetPath;
    _customCardVisualMode = hasCustomImage
        ? CustomCardVisualMode.image
        : CustomCardVisualMode.gradient;
    _customCardImageAlignment = Alignment(
      card.customCardImageAlignmentX ?? 0,
      card.customCardImageAlignmentY ?? 0,
    );
    _otherBankDetailsReady = true;
    _showBuiltInVisualEditor = false;
    _customGradientStartColor = hasCustomGradient
        ? Color(card.customGradientStartColor!)
        : (isOtherBank
            ? const Color(0xFF111827)
            : bankColors?.first ?? const Color(0xFF111827));
    _customGradientMiddleColor = hasCustomGradient
        ? Color(
            card.customGradientMiddleColor ??
                Color.lerp(
                  Color(card.customGradientStartColor!),
                  Color(card.customGradientEndColor!),
                  0.5,
                )!
                    .toARGB32(),
          )
        : (isOtherBank
            ? const Color(0xFF1F4F9A)
            : bankColors?[1] ?? const Color(0xFF1F4F9A));
    _customGradientEndColor = hasCustomGradient
        ? Color(card.customGradientEndColor!)
        : (isOtherBank
            ? const Color(0xFF2563EB)
            : bankColors?.last ?? const Color(0xFF2563EB));
    _hasCustomVisualOverride = hasCustomGradient;
    _cardNetwork = card.cardNetwork;
    _cardType = card.cardType;
  }

  void _onBankSelected(String cid) {
    SwalletHaptics.bankSelected();
    final isOtherBank = cid == BankAssets.otherBankId;
    final bankColors =
        isOtherBank ? null : CardVisuals.editableGradientColorsForBank(cid);

    setState(() {
      _selectedBankCid = cid;
      _isBankSelected = true;
      _cardNumber = '';
      _expiry = '';
      _cvv = '';
      _holderName = '';
      _customBankName = '';
      _customBankLogoPath = null;
      _customCardImagePath = null;
      _customCardPatternAssetPath = null;
      _customCardVisualMode = CustomCardVisualMode.gradient;
      _customCardImageAlignment = Alignment.center;
      _otherBankDetailsReady = cid != BankAssets.otherBankId;
      _showBuiltInVisualEditor = false;
      _customGradientStartColor = isOtherBank
          ? const Color(0xFF111827)
          : bankColors?.first ?? const Color(0xFF111827);
      _customGradientMiddleColor = isOtherBank
          ? const Color(0xFF1F4F9A)
          : bankColors?[1] ?? const Color(0xFF1F4F9A);
      _customGradientEndColor = isOtherBank
          ? const Color(0xFF2563EB)
          : bankColors?.last ?? const Color(0xFF2563EB);
      _hasCustomVisualOverride = false;
      _cardNetwork = null;
      _cardType = CardType.credit;
    });
  }

  // 🔔 NOTE: Kept for System Back Button logic (PopScope),
  // but removed from the UI button (AddCardPreviewStack).
  void _onChangeBankPressed() {
    SwalletHaptics.changeBank();
    setState(() {
      _selectedBankCid = null;
      _isBankSelected = false;
      _cardNumber = '';
      _expiry = '';
      _cvv = '';
      _holderName = '';
      _customBankName = '';
      _customBankLogoPath = null;
      _customCardImagePath = null;
      _customCardPatternAssetPath = null;
      _customCardVisualMode = CustomCardVisualMode.gradient;
      _customCardImageAlignment = Alignment.center;
      _otherBankDetailsReady = false;
      _showBuiltInVisualEditor = false;
      _customGradientStartColor = const Color(0xFF111827);
      _customGradientMiddleColor = const Color(0xFF1F4F9A);
      _customGradientEndColor = const Color(0xFF2563EB);
      _hasCustomVisualOverride = false;
      _cardNetwork = null;
      _cardType = CardType.credit;
    });
  }

  void _onBackFromSelectedBank() {
    if (_showBuiltInVisualEditor) {
      setState(() => _showBuiltInVisualEditor = false);
      return;
    }

    if (_isEditMode) {
      _close();
      return;
    }

    if (_selectedBankCid == BankAssets.otherBankId && _otherBankDetailsReady) {
      setState(() {
        _otherBankDetailsReady = false;
        _cardNumber = '';
        _expiry = '';
        _cvv = '';
        _holderName = '';
        _cardNetwork = null;
        _cardType = CardType.credit;
      });
      return;
    }

    _onChangeBankPressed();
  }

  void _onOtherBankNextPressed() {
    final hasCustomOtherBank =
        _customBankName.trim().isNotEmpty || _customBankLogoPath != null;
    if (!hasCustomOtherBank) {
      return;
    }

    setState(() => _otherBankDetailsReady = true);
  }

  Future<void> _pickCustomBankLogo() async {
    final picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );
    if (picked == null) return;

    try {
      final appDir = await getApplicationDocumentsDirectory();
      final logosDir = Directory('${appDir.path}/custom_bank_logos');
      if (!logosDir.existsSync()) {
        logosDir.createSync(recursive: true);
      }

      final extension = picked.name.contains('.')
          ? picked.name.substring(picked.name.lastIndexOf('.'))
          : '.png';
      final fileName =
          'bank_logo_${DateTime.now().millisecondsSinceEpoch}$extension';
      final savedFile =
          await File(picked.path).copy('${logosDir.path}/$fileName');

      if (!mounted) return;
      setState(() => _customBankLogoPath = savedFile.path);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not select bank logo')),
      );
    }
  }

  void _removeCustomBankLogo() {
    setState(() => _customBankLogoPath = null);
  }

  Future<void> _pickCustomCardImage() async {
    final picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );
    if (picked == null) return;

    try {
      final appDir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${appDir.path}/custom_card_images');
      if (!imagesDir.existsSync()) {
        imagesDir.createSync(recursive: true);
      }

      final extension = picked.name.contains('.')
          ? picked.name.substring(picked.name.lastIndexOf('.'))
          : '.png';
      final fileName =
          'card_visual_${DateTime.now().millisecondsSinceEpoch}$extension';
      final savedFile =
          await File(picked.path).copy('${imagesDir.path}/$fileName');

      if (!mounted) return;
      setState(() {
        _customCardImagePath = savedFile.path;
        _customCardPatternAssetPath = null;
        _customCardVisualMode = CustomCardVisualMode.image;
        _customCardImageAlignment = Alignment.center;
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not select card image')),
      );
    }
  }

  void _removeCustomCardImage() {
    setState(() {
      _customCardImagePath = null;
      _customCardImageAlignment = Alignment.center;
    });
  }

  void _showCardVisualEditor() {
    final cid = _selectedBankCid;
    if (cid == null) return;
    if (cid == BankAssets.otherBankId && !_isEditMode) return;

    setState(() {
      if (cid != BankAssets.otherBankId &&
          !_hasCustomVisualOverride &&
          _customCardVisualMode == CustomCardVisualMode.gradient) {
        _seedCustomGradientFromBank(cid, includePattern: true);
      }
      _showBuiltInVisualEditor = true;
    });
  }

  void _onAddCardPressed() {
    final isOtherBank = _selectedBankCid == BankAssets.otherBankId;
    final hasCustomOtherBank =
        _customBankName.trim().isNotEmpty || _customBankLogoPath != null;
    final requiredCvvLength =
        CardNumberFormat.cvvLengthForNetwork(_cardNetwork);
    final hasValidCardNumberLength = CardNumberFormat.isValidLengthForNetwork(
      network: _cardNetwork,
      length: _cardNumber.length,
    );

    if (_selectedBankCid == null ||
        _cardNetwork == null ||
        !hasValidCardNumberLength ||
        _expiry.length != 5 ||
        _cvv.length != requiredCvvLength ||
        _holderName.isEmpty ||
        (isOtherBank && !hasCustomOtherBank)) {
      return;
    }

    SwalletHaptics.cardAdded();
    final usesGradient = _customCardVisualMode == CustomCardVisualMode.gradient;
    final usesImage = _customCardVisualMode == CustomCardVisualMode.image &&
        _customCardImagePath != null;
    final hasCustomGradient =
        usesGradient && (isOtherBank || _hasCustomVisualOverride);
    final hasCustomVisual = hasCustomGradient || usesImage;

    final card = CardData(
      bankCid: _selectedBankCid!,
      cardNetwork: _cardNetwork!,
      cardType: _cardType,
      cardNumber: _cardNumber,
      expiry: _expiry,
      holderName: _holderName,
      cvv: _cvv,
      customBankName: isOtherBank && _customBankName.trim().isNotEmpty
          ? _customBankName.trim()
          : null,
      customBankLogoPath: isOtherBank ? _customBankLogoPath : null,
      customGradientStartColor:
          hasCustomGradient ? _customGradientStartColor.toARGB32() : null,
      customGradientMiddleColor:
          hasCustomGradient ? _customGradientMiddleColor.toARGB32() : null,
      customGradientEndColor:
          hasCustomGradient ? _customGradientEndColor.toARGB32() : null,
      customCardImagePath: usesImage ? _customCardImagePath : null,
      customCardVisualMode:
          hasCustomVisual ? _customCardVisualMode.index : null,
      customCardImageAlignmentX: usesImage ? _customCardImageAlignment.x : null,
      customCardImageAlignmentY: usesImage ? _customCardImageAlignment.y : null,
      customCardPatternAssetPath:
          hasCustomGradient ? _customCardPatternAssetPath : null,
    );

    if (_isEditMode) {
      widget.onCardUpdated?.call(card);
    } else {
      widget.onCardAdded(card);
    }
    _close();
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    final mediaSize = MediaQuery.sizeOf(context);
    final surfaceInsets = _surfaceInsets(mediaSize);
    final previewTop = _previewTop(context);
    final keyboardHeight = _keyboardHeight(context);
    final bool isKeyboardActive = _isBankSelected && keyboardHeight > 0;

    if (isKeyboardActive && !_keyboardHapticFired) {
      SwalletHaptics.keyboardEntered();
      _keyboardHapticFired = true;
    }
    if (!isKeyboardActive) _keyboardHapticFired = false;

    final double formLift = isKeyboardActive ? keyboardHeight : 0;
    final double maxKeyboardHeight = MediaQuery.of(context).size.height * 0.4;
    final double keyboardProgress =
        (keyboardHeight / maxKeyboardHeight).clamp(0.0, 1.0);
    final double previewScale =
        lerpDouble(1.0, _previewMinScale, keyboardProgress)!;

    final double effectivePreviewTop = previewTop - _dragOffset;

    // Calculate Dynamic Blur & Dimming
    final double dragProgress = (_dragOffset / 150.0).clamp(0.0, 1.0);
    final double inverseProgress = 1.0 - dragProgress;
    final double currentBlur = 15.0 * inverseProgress;
    final double currentDimOpacity = 0.6 * inverseProgress;
    final bool isOtherBank = _selectedBankCid == BankAssets.otherBankId;
    final bool showOtherBankSetup =
        _isBankSelected && isOtherBank && !_otherBankDetailsReady;
    final bool showBuiltInVisualEditor =
        _isBankSelected && !isOtherBank && _showBuiltInVisualEditor;
    final bool showCardDetailsForm = _isBankSelected &&
        !showBuiltInVisualEditor &&
        (!isOtherBank || _otherBankDetailsReady);
    final palette = SwalletPalette(widget.isDark);

    return PopScope(
      canPop: !widget.embedded && !_isBankSelected,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (widget.embedded) return;
        if (_isBankSelected) {
          _onBackFromSelectedBank();
          return;
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor:
            widget.embedded ? palette.background : Colors.transparent,
        body: Stack(
          children: [
            // ================= BLUR BACKGROUND =================
            if (widget.embedded)
              Positioned.fill(
                child: ColoredBox(color: palette.background),
              )
            else
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: currentBlur,
                    sigmaY: currentBlur,
                  ),
                  child: Container(
                    color: Colors.black.withValues(alpha: currentDimOpacity),
                  ),
                ),
              ),

            // ================= PREVIEW CARD =================
            AddCardPreviewStack(
              top: effectivePreviewTop,
              horizontalInsets: surfaceInsets,
              scale: previewScale,
              isDark: widget.isDark,
              bankCid: _selectedBankCid,
              isBankSelected: _isBankSelected,
              cardNumber: _cardNumber,
              expiry: _expiry,
              holderName: _holderName,
              cardNetwork: _cardNetwork,
              cardType: _cardType,
              customBankName: _selectedBankCid == BankAssets.otherBankId
                  ? _customBankName
                  : null,
              customBankLogoPath: _selectedBankCid == BankAssets.otherBankId
                  ? _customBankLogoPath
                  : null,
              customCardImagePath:
                  _customCardVisualMode == CustomCardVisualMode.image
                      ? _customCardImagePath
                      : null,
              customCardImageAlignment: _customCardImageAlignment,
              customCardPatternAssetPath:
                  _customCardVisualMode == CustomCardVisualMode.gradient
                      ? _customCardPatternAssetPath
                      : null,
              customGradientStartColor:
                  _customCardVisualMode == CustomCardVisualMode.gradient &&
                          (isOtherBank || _hasCustomVisualOverride)
                      ? _customGradientStartColor
                      : null,
              customGradientMiddleColor:
                  _customCardVisualMode == CustomCardVisualMode.gradient &&
                          (isOtherBank || _hasCustomVisualOverride)
                      ? _customGradientMiddleColor
                      : null,
              customGradientEndColor:
                  _customCardVisualMode == CustomCardVisualMode.gradient &&
                          (isOtherBank || _hasCustomVisualOverride)
                      ? _customGradientEndColor
                      : null,
              onEditVisualTap: _isBankSelected && (!isOtherBank || _isEditMode)
                  ? _showCardVisualEditor
                  : null,
              // ❌ REMOVED: onChangeBank: _onChangeBankPressed,
              // This removes the button trigger from the UI component.
            ),

            // ================= BANK SELECTION (DRAWER) =================
            Positioned(
              left: surfaceInsets.left,
              right: surfaceInsets.right,
              // 🔧 REFINED SPACING:
              // Changed the gap logic to be tight (24.0) since the button is gone.
              // Previously: AddCardLayoutConstants.previewToSectionGap
              top: previewTop + AddCardLayoutConstants.previewCardHeight + 24.0,
              bottom: AddCardLayoutConstants.sectionBottomInset,
              child: AnimatedSlide(
                offset: _isBankSelected ? const Offset(-1, 0) : Offset.zero,
                duration: _bankExitDuration,
                curve: _transitionCurve,
                child: AnimatedOpacity(
                  opacity: _isBankSelected ? 0 : 1,
                  duration: const Duration(milliseconds: 220),
                  child: Transform.translate(
                    offset: Offset(0, _dragOffset),
                    child: NotificationListener<ScrollNotification>(
                      onNotification: _handleScrollNotification,
                      child: BankSelectionSection(
                        controller: _scrollController,
                        onBankSelected: _onBankSelected,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ================= OTHER BANK SETUP SECTION =================
            Positioned(
              left: surfaceInsets.left,
              right: surfaceInsets.right,
              bottom: AddCardLayoutConstants.sectionBottomInset + formLift,
              child: IgnorePointer(
                ignoring: !showOtherBankSetup,
                child: AnimatedSlide(
                  offset: showOtherBankSetup
                      ? Offset.zero
                      : _isBankSelected && isOtherBank
                          ? const Offset(-1, 0)
                          : const Offset(1, 0),
                  duration: _formEnterDuration,
                  curve: _transitionCurve,
                  child: AnimatedOpacity(
                    opacity: showOtherBankSetup ? 1 : 0,
                    duration: const Duration(milliseconds: 260),
                    child: CardFormSectionHost(
                      isDark: widget.isDark,
                      child: OtherBankSetupSection(
                        isDark: widget.isDark,
                        customBankName: _customBankName,
                        customBankLogoPath: _customBankLogoPath,
                        customCardImagePath: _customCardImagePath,
                        customCardPatternAssetPath: _customCardPatternAssetPath,
                        gradientStartColor: _customGradientStartColor,
                        gradientMiddleColor: _customGradientMiddleColor,
                        gradientEndColor: _customGradientEndColor,
                        visualMode: _customCardVisualMode,
                        imageAlignment: _customCardImageAlignment,
                        onCustomBankNameChanged: (v) =>
                            setState(() => _customBankName = v),
                        onGradientStartColorChanged: (color) => setState(() {
                          _customGradientStartColor = color;
                          _customCardVisualMode = CustomCardVisualMode.gradient;
                        }),
                        onGradientMiddleColorChanged: (color) => setState(() {
                          _customGradientMiddleColor = color;
                          _customCardVisualMode = CustomCardVisualMode.gradient;
                        }),
                        onGradientEndColorChanged: (color) => setState(() {
                          _customGradientEndColor = color;
                          _customCardVisualMode = CustomCardVisualMode.gradient;
                        }),
                        onVisualModeChanged: (mode) =>
                            setState(() => _customCardVisualMode = mode),
                        onPatternChanged: (assetPath) => setState(() {
                          _customCardPatternAssetPath = assetPath;
                          _customCardVisualMode = CustomCardVisualMode.gradient;
                        }),
                        onImageAlignmentChanged: (alignment) => setState(
                            () => _customCardImageAlignment = alignment),
                        onPickCustomBankLogo: _pickCustomBankLogo,
                        onRemoveCustomBankLogo: _removeCustomBankLogo,
                        onPickCustomCardImage: _pickCustomCardImage,
                        onRemoveCustomCardImage: _removeCustomCardImage,
                        onNext: _onOtherBankNextPressed,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ================= BUILT-IN BANK VISUAL SECTION =================
            Positioned(
              left: surfaceInsets.left,
              right: surfaceInsets.right,
              bottom: AddCardLayoutConstants.sectionBottomInset + formLift,
              child: IgnorePointer(
                ignoring: !showBuiltInVisualEditor,
                child: AnimatedSlide(
                  offset: showBuiltInVisualEditor
                      ? Offset.zero
                      : const Offset(1, 0),
                  duration: _formEnterDuration,
                  curve: _transitionCurve,
                  child: AnimatedOpacity(
                    opacity: showBuiltInVisualEditor ? 1 : 0,
                    duration: const Duration(milliseconds: 260),
                    child: CardFormSectionHost(
                      isDark: widget.isDark,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Center(
                            child: Text(
                              'Edit card visual',
                              style: SwalletText.bodyMedium.copyWith(
                                color: AddCardMaterialTokens(widget.isDark)
                                    .onSurface,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          CardVisualCustomizationSection(
                            isDark: widget.isDark,
                            startColor: _customGradientStartColor,
                            middleColor: _customGradientMiddleColor,
                            endColor: _customGradientEndColor,
                            imagePath: _customCardImagePath,
                            patternAssetPath: _customCardPatternAssetPath,
                            visualMode: _customCardVisualMode,
                            imageAlignment: _customCardImageAlignment,
                            onStartChanged: (color) => setState(() {
                              _customGradientStartColor = color;
                              _customCardVisualMode =
                                  CustomCardVisualMode.gradient;
                              _hasCustomVisualOverride = true;
                            }),
                            onMiddleChanged: (color) => setState(() {
                              _customGradientMiddleColor = color;
                              _customCardVisualMode =
                                  CustomCardVisualMode.gradient;
                              _hasCustomVisualOverride = true;
                            }),
                            onEndChanged: (color) => setState(() {
                              _customGradientEndColor = color;
                              _customCardVisualMode =
                                  CustomCardVisualMode.gradient;
                              _hasCustomVisualOverride = true;
                            }),
                            onVisualModeChanged: (mode) => setState(() {
                              _customCardVisualMode = mode;
                              if (mode == CustomCardVisualMode.gradient) {
                                _hasCustomVisualOverride = true;
                              }
                            }),
                            onPatternChanged: (assetPath) => setState(() {
                              _customCardPatternAssetPath = assetPath;
                              _customCardVisualMode =
                                  CustomCardVisualMode.gradient;
                              _hasCustomVisualOverride = true;
                            }),
                            onImageAlignmentChanged: (alignment) => setState(
                                () => _customCardImageAlignment = alignment),
                            onPickImage: _pickCustomCardImage,
                            onRemoveImage: _removeCustomCardImage,
                          ),
                          const SizedBox(height: 24),
                          AddCardCTAButton(
                            label: 'Done',
                            onPressed: () => setState(
                                () => _showBuiltInVisualEditor = false),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ================= CARD DETAILS FORM SECTION =================
            Positioned(
              left: surfaceInsets.left,
              right: surfaceInsets.right,
              bottom: AddCardLayoutConstants.sectionBottomInset + formLift,
              child: IgnorePointer(
                ignoring: !showCardDetailsForm,
                child: AnimatedSlide(
                  offset:
                      showCardDetailsForm ? Offset.zero : const Offset(1, 0),
                  duration: _formEnterDuration,
                  curve: _transitionCurve,
                  child: AnimatedOpacity(
                    opacity: showCardDetailsForm ? 1 : 0,
                    duration: const Duration(milliseconds: 260),
                    child: CardFormSectionHost(
                      isDark: widget.isDark,
                      child: CardFormSection(
                        key: ValueKey('card_form_$_selectedBankCid'),
                        isDark: widget.isDark,
                        initialCardNumber: _cardNumber,
                        initialExpiry: _expiry,
                        initialCvv: _cvv,
                        initialHolderName: _holderName,
                        initialCardType: _cardType,
                        title: _isEditMode
                            ? 'Edit payment card'
                            : 'Add payment card',
                        submitLabel: _isEditMode ? 'Save Card' : 'Add Card',
                        onCardNumberChanged: (v) =>
                            setState(() => _cardNumber = v),
                        onNetworkChanged: (n) =>
                            setState(() => _cardNetwork = n),
                        onCardTypeChanged: (t) => setState(() => _cardType = t),
                        onExpiryChanged: (v) => setState(() => _expiry = v),
                        onCvvChanged: (v) => setState(() => _cvv = v),
                        onNameChanged: (v) => setState(() => _holderName = v),
                        onSubmit: _onAddCardPressed,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
