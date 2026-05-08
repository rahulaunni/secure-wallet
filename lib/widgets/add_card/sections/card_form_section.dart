import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import 'package:swallet/models/card_network.dart';
import 'package:swallet/models/card_type.dart';
import 'package:swallet/theme/swallet_theme.dart';
import 'package:swallet/utils/card_network_detector.dart';
import 'package:swallet/utils/card_number_format.dart';
import 'package:swallet/widgets/add_card/sections/widgets/card_number_slot_field.dart';
import 'package:swallet/widgets/add_card/sections/widgets/card_type_selector.dart';
import 'package:swallet/widgets/add_card/add_card_material_tokens.dart';
import 'package:swallet/widgets/add_card/widgets/add_card_cta_button.dart';
import 'package:swallet/widgets/add_card/widgets/form_text.dart';

class CardFormSection extends StatefulWidget {
  final bool isDark;

  final ValueChanged<String> onCardNumberChanged;
  final ValueChanged<CardNetwork?> onNetworkChanged;
  final ValueChanged<CardType> onCardTypeChanged;
  final ValueChanged<String> onExpiryChanged;
  final ValueChanged<String> onCvvChanged;
  final ValueChanged<String> onNameChanged;
  final VoidCallback onSubmit;
  final String initialCardNumber;
  final String initialExpiry;
  final String initialCvv;
  final String initialHolderName;
  final CardType initialCardType;
  final String title;
  final String submitLabel;

  const CardFormSection({
    super.key,
    required this.isDark,
    required this.onCardNumberChanged,
    required this.onNetworkChanged,
    required this.onCardTypeChanged,
    required this.onExpiryChanged,
    required this.onCvvChanged,
    required this.onNameChanged,
    required this.onSubmit,
    this.initialCardNumber = '',
    this.initialExpiry = '',
    this.initialCvv = '',
    this.initialHolderName = '',
    this.initialCardType = CardType.credit,
    this.title = 'Add payment card',
    this.submitLabel = 'Add Card',
  });

  @override
  State<CardFormSection> createState() => _CardFormSectionState();
}

class _CardFormSectionState extends State<CardFormSection> {
  late final TextEditingController _expiryCtrl;
  late final TextEditingController _cvvCtrl;
  late final TextEditingController _nameCtrl;

  final _expiryFocus = FocusNode();
  final _cvvFocus = FocusNode();
  final _nameFocus = FocusNode();

  late CardType _selectedCardType;
  CardNetwork? _detectedNetwork;

  @override
  void initState() {
    super.initState();
    _expiryCtrl = TextEditingController(text: widget.initialExpiry);
    _cvvCtrl = TextEditingController(text: widget.initialCvv);
    _nameCtrl = TextEditingController(text: widget.initialHolderName);
    _selectedCardType = widget.initialCardType;
    _detectedNetwork = CardNetworkDetector.detect(widget.initialCardNumber);
  }

  @override
  void dispose() {
    _expiryCtrl.dispose();
    _cvvCtrl.dispose();
    _nameCtrl.dispose();
    _expiryFocus.dispose();
    _cvvFocus.dispose();
    _nameFocus.dispose();
    super.dispose();
  }

  void _handleCardNumberChanged(String value) {
    widget.onCardNumberChanged(value);

    final network = CardNetworkDetector.detect(value);
    if (network != _detectedNetwork) {
      setState(() => _detectedNetwork = network);
      final cvvLength = CardNumberFormat.cvvLengthForNetwork(network);
      if (_cvvCtrl.text.length > cvvLength) {
        final trimmed = _cvvCtrl.text.substring(0, cvvLength);
        _cvvCtrl.text = trimmed;
        _cvvCtrl.selection = TextSelection.collapsed(offset: trimmed.length);
        widget.onCvvChanged(trimmed);
      }
    }

    widget.onNetworkChanged(network);
  }

  @override
  Widget build(BuildContext context) {
    final cvvLength = CardNumberFormat.cvvLengthForNetwork(_detectedNetwork);
    final isAmex = _detectedNetwork == CardNetwork.amex;
    final tokens = AddCardMaterialTokens(widget.isDark);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(
            widget.title,
            style: SwalletText.bodyMedium.copyWith(
              color: tokens.onSurface,
            ),
          ),
        ),
        const SizedBox(height: 24),
        CardTypeSelector(
          selected: _selectedCardType,
          isDark: widget.isDark,
          onChanged: (type) {
            setState(() => _selectedCardType = type);
            widget.onCardTypeChanged(type);
          },
        ),
        const SizedBox(height: 24),
        CardNumberSlotField(
          isDark: widget.isDark,
          initialValue: widget.initialCardNumber,
          onChanged: _handleCardNumberChanged,
          onCompleted: () => _expiryFocus.requestFocus(),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: FormText(
                label: 'Expiry date',
                hint: 'MM/YY',
                controller: _expiryCtrl,
                focusNode: _expiryFocus,
                keyboardType: TextInputType.number,
                leadingIcon: CupertinoIcons.calendar,
                isDark: widget.isDark,
                inputFormatters: [
                  ExpiryDateInputFormatter(),
                ],
                onChanged: (v) {
                  widget.onExpiryChanged(v);
                  if (v.length == 5) {
                    _cvvFocus.requestFocus();
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FormText(
                label: isAmex ? 'CID' : 'Security code',
                hint: isAmex ? '0000' : '000',
                controller: _cvvCtrl,
                focusNode: _cvvFocus,
                keyboardType: TextInputType.number,
                leadingIcon: CupertinoIcons.lock,
                obscureText: true,
                maxLength: cvvLength,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(cvvLength),
                ],
                isDark: widget.isDark,
                onChanged: (v) {
                  widget.onCvvChanged(v);
                  if (v.length == cvvLength) {
                    _nameFocus.requestFocus();
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        FormText(
          label: 'Name on card',
          hint: 'Card holder name',
          controller: _nameCtrl,
          focusNode: _nameFocus,
          leadingIcon: CupertinoIcons.person,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.done,
          isDark: widget.isDark,
          onChanged: widget.onNameChanged,
        ),
        const SizedBox(height: 24),
        AddCardCTAButton(
          label: widget.submitLabel,
          onPressed: widget.onSubmit,
        ),
      ],
    );
  }
}

class ExpiryDateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final raw = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (raw.isEmpty) {
      return const TextEditingValue(text: '');
    }

    if (raw.length > 4) return oldValue;

    if (raw.length >= 2) {
      final month = int.tryParse(raw.substring(0, 2));
      if (month == null || month < 1 || month > 12) {
        return oldValue;
      }
    }

    final formatted =
        raw.length <= 2 ? raw : '${raw.substring(0, 2)}/${raw.substring(2)}';

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
