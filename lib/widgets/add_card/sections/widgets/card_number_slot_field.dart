import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:swallet/theme/swallet_theme.dart';
import 'package:swallet/utils/card_number_format.dart';
import 'package:swallet/widgets/add_card/add_card_material_tokens.dart';

class CardNumberSlotField extends StatefulWidget {
  final ValueChanged<String> onChanged;
  final VoidCallback? onCompleted;
  final bool isDark;
  final String initialValue;

  const CardNumberSlotField({
    super.key,
    required this.onChanged,
    required this.isDark,
    this.onCompleted,
    this.initialValue = '',
  });

  @override
  State<CardNumberSlotField> createState() => _CardNumberSlotFieldState();
}

class _CardNumberSlotFieldState extends State<CardNumberSlotField> {
  late final TextEditingController _controller;
  bool _isAmex = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: CardNumberFormat.format(widget.initialValue),
    );
    _isAmex = CardNumberFormat.isAmexNumber(widget.initialValue);
  }

  @override
  void didUpdateWidget(covariant CardNumberSlotField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue &&
        CardNumberFormat.digitsOnly(_controller.text) != widget.initialValue) {
      _controller.text = CardNumberFormat.format(widget.initialValue);
      _isAmex = CardNumberFormat.isAmexNumber(widget.initialValue);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AddCardMaterialTokens(widget.isDark);

    return SizedBox(
      height: 64,
      child: TextField(
        controller: _controller,
        keyboardType: TextInputType.number,
        cursorColor: tokens.primary,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          CardNumberInputFormatter(),
        ],
        onChanged: (value) {
          final digits = CardNumberFormat.digitsOnly(value);
          final isAmex = CardNumberFormat.isAmexNumber(digits);
          if (isAmex != _isAmex) {
            setState(() => _isAmex = isAmex);
          }

          widget.onChanged(digits);

          if (digits.length == CardNumberFormat.maxLengthForNumber(digits)) {
            widget.onCompleted?.call();
          }
        },
        style: GoogleFonts.robotoMono(
          fontSize: 16,
          height: 1.25,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          color: tokens.onSurface,
        ),
        decoration: InputDecoration(
          counterText: '',
          labelText: 'Card number',
          hintText: _isAmex ? 'XXXX XXXXXX XXXXX' : 'XXXX XXXX XXXX XXXX',
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          prefixIcon: const Icon(CupertinoIcons.creditcard, size: 22),
          prefixIconColor: WidgetStateColor.resolveWith((states) {
            return states.contains(WidgetState.focused)
                ? tokens.primary
                : tokens.onSurfaceVariant;
          }),
          suffixIcon: _isAmex
              ? Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Center(
                    widthFactor: 1,
                    child: Text(
                      'AMEX',
                      style: SwalletText.section.copyWith(
                        fontSize: 11,
                        color: tokens.primary,
                      ),
                    ),
                  ),
                )
              : null,
          labelStyle: SwalletText.bodyMedium.copyWith(
            color: tokens.onSurfaceVariant,
            fontSize: 14,
          ),
          floatingLabelStyle: SwalletText.section.copyWith(
            color: tokens.primary,
            fontSize: 13,
          ),
          hintStyle: GoogleFonts.robotoMono(
            color: tokens.onSurfaceVariant.withValues(alpha: 0.62),
            fontSize: 15,
            letterSpacing: 0,
          ),
          filled: true,
          fillColor: tokens.surfaceContainer,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 18,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: tokens.controlRadius,
            borderSide: BorderSide(
              color: tokens.outlineVariant.withValues(alpha: 0.64),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: tokens.controlRadius,
            borderSide: BorderSide(
              color: tokens.primary,
              width: 1.4,
            ),
          ),
        ),
      ),
    );
  }
}

class CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = CardNumberFormat.digitsOnly(newValue.text);

    if (digits.isEmpty) {
      return const TextEditingValue(text: '');
    }

    final formatted = CardNumberFormat.format(digits);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
