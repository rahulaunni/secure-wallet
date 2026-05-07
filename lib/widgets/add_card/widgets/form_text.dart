import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:swallet/widgets/add_card/add_card_material_tokens.dart';

class FormText extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final FocusNode? focusNode;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextCapitalization textCapitalization;
  final TextInputAction? textInputAction;
  final int? maxLength;
  final IconData? leadingIcon;
  final ValueChanged<String>? onChanged;
  final List<TextInputFormatter>? inputFormatters;
  final bool isDark;

  const FormText({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    required this.isDark,
    this.focusNode,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.textCapitalization = TextCapitalization.none,
    this.textInputAction,
    this.maxLength,
    this.leadingIcon,
    this.inputFormatters,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AddCardMaterialTokens(isDark);

    return SizedBox(
      height: 64,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        obscureText: obscureText,
        keyboardType: keyboardType,
        textCapitalization: textCapitalization,
        textInputAction: textInputAction,
        maxLength: maxLength,
        inputFormatters: inputFormatters,
        onChanged: onChanged,
        cursorColor: tokens.primary,
        style: GoogleFonts.roboto(
          fontSize: 16,
          height: 1.25,
          fontWeight: FontWeight.w500,
          color: tokens.onSurface,
        ),
        decoration: InputDecoration(
          counterText: '',
          labelText: label,
          hintText: hint,
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          prefixIcon: leadingIcon == null
              ? null
              : Icon(
                  leadingIcon,
                  size: 22,
                ),
          prefixIconColor: WidgetStateColor.resolveWith((states) {
            return states.contains(WidgetState.focused)
                ? tokens.primary
                : tokens.onSurfaceVariant;
          }),
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
          hintStyle: GoogleFonts.roboto(
            color: tokens.onSurfaceVariant.withValues(alpha: 0.72),
            fontSize: 16,
          ),
          filled: true,
          fillColor: tokens.surfaceContainerHigh,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 18,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: tokens.controlRadius,
            borderSide: BorderSide(
              color: tokens.outlineVariant,
            ),
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
