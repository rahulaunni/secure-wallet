import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import 'package:swallet/data/bank_assets.dart';
import 'package:swallet/models/card_data.dart';
import 'package:swallet/models/card_network.dart';
import 'package:swallet/models/card_type.dart';

import 'constants/add_card_layout_constants.dart';
import 'widgets/add_card_preview_stack.dart';
import 'widgets/card_form_section_host.dart';
import 'widgets/bank_selection_section.dart';
import 'widgets/other_bank_setup_section.dart';
// import 'widgets/add_card_background.dart'; // Unused, commented out

import 'package:swallet/widgets/add_card/sections/card_form_section.dart';
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
  final VoidCallback? onClose;
  final bool embedded;
  final AddCardFlowController? controller;

  const AddCardFlowScreen({
    super.key,
    required this.isDark,
    required this.onCardAdded,
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
  bool _otherBankDetailsReady = false;
  Color _customGradientStartColor = const Color(0xFF111827);
  Color _customGradientEndColor = const Color(0xFF2563EB);
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

  void _onBankSelected(String cid) {
    SwalletHaptics.bankSelected();
    setState(() {
      _selectedBankCid = cid;
      _isBankSelected = true;
      _cardNumber = '';
      _expiry = '';
      _cvv = '';
      _holderName = '';
      _customBankName = '';
      _customBankLogoPath = null;
      _otherBankDetailsReady = cid != BankAssets.otherBankId;
      _customGradientStartColor = const Color(0xFF111827);
      _customGradientEndColor = const Color(0xFF2563EB);
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
      _otherBankDetailsReady = false;
      _customGradientStartColor = const Color(0xFF111827);
      _customGradientEndColor = const Color(0xFF2563EB);
      _cardNetwork = null;
      _cardType = CardType.credit;
    });
  }

  void _onBackFromSelectedBank() {
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

  void _onAddCardPressed() {
    final isOtherBank = _selectedBankCid == BankAssets.otherBankId;
    final hasCustomOtherBank =
        _customBankName.trim().isNotEmpty || _customBankLogoPath != null;
    final requiredCardNumberLength = _cardNetwork == CardNetwork.amex ? 15 : 16;
    final requiredCvvLength =
        CardNumberFormat.cvvLengthForNetwork(_cardNetwork);

    if (_selectedBankCid == null ||
        _cardNetwork == null ||
        _cardNumber.length != requiredCardNumberLength ||
        _expiry.length != 5 ||
        _cvv.length != requiredCvvLength ||
        _holderName.isEmpty ||
        (isOtherBank && !hasCustomOtherBank)) {
      return;
    }

    SwalletHaptics.cardAdded();

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
          isOtherBank ? _customGradientStartColor.toARGB32() : null,
      customGradientEndColor:
          isOtherBank ? _customGradientEndColor.toARGB32() : null,
    );

    widget.onCardAdded(card);
    _close();
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
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
    final bool showCardDetailsForm =
        _isBankSelected && (!isOtherBank || _otherBankDetailsReady);

    return PopScope(
      canPop: !widget.embedded && !_isBankSelected,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (_isBankSelected) {
          _onBackFromSelectedBank();
          return;
        }
        if (widget.embedded) {
          _close();
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            // ================= BLUR BACKGROUND =================
            Positioned.fill(
              child: BackdropFilter(
                filter:
                    ImageFilter.blur(sigmaX: currentBlur, sigmaY: currentBlur),
                child: Container(
                    color: Colors.black.withValues(alpha: currentDimOpacity)),
              ),
            ),

            // ================= PREVIEW CARD =================
            AddCardPreviewStack(
              top: effectivePreviewTop,
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
              customGradientStartColor:
                  _selectedBankCid == BankAssets.otherBankId
                      ? _customGradientStartColor
                      : null,
              customGradientEndColor: _selectedBankCid == BankAssets.otherBankId
                  ? _customGradientEndColor
                  : null,
              // ❌ REMOVED: onChangeBank: _onChangeBankPressed,
              // This removes the button trigger from the UI component.
            ),

            // ================= BANK SELECTION (DRAWER) =================
            Positioned(
              left: 16,
              right: 16,
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
              left: 16,
              right: 16,
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
                        gradientStartColor: _customGradientStartColor,
                        gradientEndColor: _customGradientEndColor,
                        onCustomBankNameChanged: (v) =>
                            setState(() => _customBankName = v),
                        onGradientStartColorChanged: (color) =>
                            setState(() => _customGradientStartColor = color),
                        onGradientEndColorChanged: (color) =>
                            setState(() => _customGradientEndColor = color),
                        onPickCustomBankLogo: _pickCustomBankLogo,
                        onRemoveCustomBankLogo: _removeCustomBankLogo,
                        onNext: _onOtherBankNextPressed,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ================= CARD DETAILS FORM SECTION =================
            Positioned(
              left: 16,
              right: 16,
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
