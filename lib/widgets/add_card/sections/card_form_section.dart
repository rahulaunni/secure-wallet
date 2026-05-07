import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:swallet/models/card_network.dart';
import 'package:swallet/models/card_type.dart';
import 'package:swallet/utils/card_network_detector.dart';
import 'package:swallet/utils/card_number_format.dart';
import 'package:swallet/widgets/add_card/sections/widgets/card_number_slot_field.dart';
import 'package:swallet/widgets/add_card/sections/widgets/card_type_selector.dart';
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
  });

  @override
  State<CardFormSection> createState() => _CardFormSectionState();
}

class _CardFormSectionState extends State<CardFormSection> {
  final _expiryCtrl = TextEditingController();
  final _cvvCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();

  final _expiryFocus = FocusNode();
  final _cvvFocus = FocusNode();
  final _nameFocus = FocusNode();

  CardType _selectedCardType = CardType.credit;
  CardNetwork? _detectedNetwork;

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

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(
            'Add payment card',
            style: GoogleFonts.roboto(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: widget.isDark
                  ? _FormTitleColors.textDark
                  : _FormTitleColors.textLight,
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

class _FormTitleColors {
  static const Color textLight = Color(0xFF111827);
  static const Color textDark = Color.fromARGB(255, 221, 221, 221);
}
