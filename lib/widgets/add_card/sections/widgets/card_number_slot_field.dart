import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:swallet/utils/card_number_format.dart';
import 'package:swallet/widgets/add_card/add_card_material_tokens.dart';

class CardNumberSlotField extends StatefulWidget {
  final ValueChanged<String> onChanged;
  final VoidCallback? onCompleted;
  final bool isDark;

  const CardNumberSlotField({
    super.key,
    required this.onChanged,
    required this.isDark,
    this.onCompleted,
  });

  @override
  State<CardNumberSlotField> createState() => _CardNumberSlotFieldState();
}

class _CardNumberSlotFieldState extends State<CardNumberSlotField> {
  bool _isAmex = false;

  @override
  Widget build(BuildContext context) {
    final tokens = AddCardMaterialTokens(widget.isDark);

    return SizedBox(
      height: 64,
      child: TextField(
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
          letterSpacing: 0.2,
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
                      style: GoogleFonts.roboto(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: tokens.primary,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                )
              : null,
          labelStyle: GoogleFonts.roboto(
            color: tokens.onSurfaceVariant,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          floatingLabelStyle: GoogleFonts.roboto(
            color: tokens.primary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          hintStyle: GoogleFonts.robotoMono(
            color: tokens.onSurfaceVariant.withValues(alpha: 0.62),
            fontSize: 15,
            letterSpacing: 0.2,
          ),
          filled: true,
          fillColor: tokens.surfaceContainerHigh,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 18,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: tokens.controlRadius,
            borderSide: BorderSide(color: tokens.outlineVariant),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: tokens.controlRadius,
            borderSide: BorderSide(
              color: tokens.primary,
              width: 2,
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
