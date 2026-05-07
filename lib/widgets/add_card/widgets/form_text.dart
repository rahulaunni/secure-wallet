import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:swallet/theme/swallet_theme.dart';
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
        style: SwalletText.bodyMedium.copyWith(
          fontSize: 16,
          height: 1.25,
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
          labelStyle: SwalletText.bodyMedium.copyWith(
            color: tokens.onSurfaceVariant,
            fontSize: 14,
          ),
          floatingLabelStyle: SwalletText.section.copyWith(
            color: tokens.primary,
            fontSize: 13,
          ),
          hintStyle: SwalletText.body.copyWith(
            color: tokens.onSurfaceVariant.withValues(alpha: 0.72),
            fontSize: 16,
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
