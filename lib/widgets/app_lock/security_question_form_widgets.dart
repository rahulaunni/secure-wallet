import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:swallet/theme/swallet_theme.dart';
import 'package:swallet/utils/size_config.dart';

class SecurityQuestionFormStyle {
  const SecurityQuestionFormStyle({
    required this.isDark,
  });

  final bool isDark;

  SwalletPalette get palette => SwalletPalette(isDark);

  Color get background => palette.background;
  Color get titleColor => palette.text;
  Color get subtitleColor => palette.textMuted;
  Color get labelColor => palette.textMuted;
  Color get bodyTextColor => palette.text;
  Color get hintColor =>
      isDark ? const Color(0xFF6F7480) : const Color(0xFF9A9DA5);
  Color get fieldFill =>
      isDark ? const Color(0xFF161616) : const Color(0xFFEDEDED);
  Color get fieldBorder =>
      isDark ? const Color(0xFF2A2A2A) : const Color(0xFFDADADA);
  Color get accentColor => palette.primary;
  Color get iconColor => palette.text;

  TextStyle get h2 => GoogleFonts.poppins(
        fontSize: sp(16),
        fontWeight: FontWeight.w600,
        height: 1,
        letterSpacing: -0.17,
      );

  TextStyle get body => GoogleFonts.poppins(
        fontSize: sp(14),
        fontWeight: FontWeight.w400,
        height: 1.25,
        letterSpacing: -0.17,
      );

  TextStyle get button => GoogleFonts.poppins(
        fontSize: sp(14),
        fontWeight: FontWeight.w600,
        height: 1,
        letterSpacing: -0.17,
      );

  TextStyle get caption => GoogleFonts.poppins(
        fontSize: sp(12),
        fontWeight: FontWeight.w400,
        height: 1.25,
        letterSpacing: -0.17,
      );
}

class SecurityQuestionBackButton extends StatelessWidget {
  const SecurityQuestionBackButton({
    super.key,
    required this.style,
    this.onTap,
  });

  final SecurityQuestionFormStyle style;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: w(40),
      height: w(40),
      child: InkWell(
        onTap: onTap ?? () => Navigator.of(context).maybePop(),
        borderRadius: BorderRadius.circular(r(16)),
        child: Icon(
          Icons.arrow_back,
          color: style.iconColor,
          size: w(24),
        ),
      ),
    );
  }
}

class SecurityQuestionHeading extends StatelessWidget {
  const SecurityQuestionHeading({
    super.key,
    required this.title,
    required this.subtitle,
    required this.style,
  });

  final String title;
  final String subtitle;
  final SecurityQuestionFormStyle style;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: style.h2.copyWith(
              color: style.titleColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: w(8)),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: style.body.copyWith(color: style.subtitleColor),
          ),
        ],
      ),
    );
  }
}

class SecurityQuestionLabel extends StatelessWidget {
  const SecurityQuestionLabel({
    super.key,
    required this.text,
    required this.style,
  });

  final String text;
  final SecurityQuestionFormStyle style;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: style.caption.copyWith(
        color: style.labelColor,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }
}

class SecurityQuestionPrimaryButton extends StatelessWidget {
  const SecurityQuestionPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    required this.style,
  });

  final String label;
  final VoidCallback? onPressed;
  final SecurityQuestionFormStyle style;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: w(54),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: style.palette.primary,
          disabledBackgroundColor:
              style.palette.primary.withValues(alpha: 0.45),
          foregroundColor: style.palette.onPrimary,
          disabledForegroundColor: style.palette.onPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(r(14)),
          ),
        ),
        child: Text(
          label,
          style: style.button.copyWith(color: style.palette.onPrimary),
        ),
      ),
    );
  }
}

class SecurityAnswerField extends StatelessWidget {
  const SecurityAnswerField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.style,
    this.onChanged,
    this.validator,
  });

  final TextEditingController controller;
  final String hintText;
  final SecurityQuestionFormStyle style;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: w(56),
      child: TextFormField(
        controller: controller,
        onChanged: onChanged,
        validator: validator,
        cursorColor: style.accentColor,
        style: style.body.copyWith(color: style.bodyTextColor),
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          filled: true,
          fillColor: style.fieldFill,
          hintText: hintText,
          hintStyle: style.body.copyWith(color: style.hintColor),
          contentPadding: EdgeInsets.symmetric(horizontal: w(16)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(r(16)),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(r(16)),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(r(16)),
            borderSide: BorderSide(
              color: style.accentColor,
              width: 1.5,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(r(16)),
            borderSide: BorderSide.none,
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(r(16)),
            borderSide: const BorderSide(
              color: SwalletColors.destructive,
              width: 1.5,
            ),
          ),
          errorStyle: const TextStyle(height: 0, fontSize: 0),
        ),
      ),
    );
  }
}

class SecurityQuestionSelector extends StatefulWidget {
  const SecurityQuestionSelector({
    super.key,
    required this.value,
    required this.items,
    required this.hint,
    required this.style,
    required this.onChanged,
  });

  final String? value;
  final List<String> items;
  final String hint;
  final SecurityQuestionFormStyle style;
  final ValueChanged<String> onChanged;

  @override
  State<SecurityQuestionSelector> createState() =>
      _SecurityQuestionSelectorState();
}

class _SecurityQuestionSelectorState extends State<SecurityQuestionSelector>
    with TickerProviderStateMixin {
  late final TextEditingController _displayController;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _displayController = TextEditingController(text: widget.value ?? '');
  }

  @override
  void didUpdateWidget(covariant SecurityQuestionSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    final nextText = widget.value ?? '';
    if (_displayController.text != nextText) {
      _displayController.text = nextText;
    }
  }

  @override
  void dispose() {
    _displayController.dispose();
    super.dispose();
  }

  void _toggle() => setState(() => _isExpanded = !_isExpanded);

  void _select(String item) {
    widget.onChanged(item);
    setState(() => _isExpanded = false);
  }

  @override
  Widget build(BuildContext context) {
    final style = widget.style;
    final fieldTextColor =
        widget.value == null ? style.hintColor : style.bodyTextColor;
    final fieldWeight =
        widget.value == null ? FontWeight.w400 : FontWeight.w500;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: w(56),
          child: TextField(
            controller: _displayController,
            readOnly: true,
            onTap: _toggle,
            cursorColor: style.accentColor,
            style: style.body.copyWith(
              color: fieldTextColor,
              fontWeight: fieldWeight,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: style.fieldFill,
              hintText: widget.hint,
              hintStyle: style.body.copyWith(color: style.hintColor),
              contentPadding: EdgeInsets.symmetric(horizontal: w(16)),
              suffixIcon: Padding(
                padding: EdgeInsets.only(right: w(12)),
                child: AnimatedRotation(
                  turns: _isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 260),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: w(24),
                    color: _isExpanded
                        ? style.accentColor
                        : (style.isDark
                            ? const Color(0xFF949494)
                            : const Color(0xFF7E8189)),
                  ),
                ),
              ),
              suffixIconConstraints: const BoxConstraints(
                minWidth: 0,
                minHeight: 0,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(r(16)),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(r(16)),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(r(16)),
                borderSide: BorderSide(
                  color: style.accentColor,
                  width: 1.5,
                ),
              ),
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeInOutCubic,
          alignment: Alignment.topCenter,
          child: _isExpanded
              ? Container(
                  constraints: BoxConstraints(maxHeight: h(240)),
                  decoration: BoxDecoration(
                    color: style.fieldFill,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(r(16)),
                      bottomRight: Radius.circular(r(16)),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(bottom: w(8)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Divider(
                          height: w(1),
                          thickness: w(1),
                          color: style.fieldBorder,
                        ),
                        ...widget.items.map((item) {
                          final isSelected = item == widget.value;
                          return InkWell(
                            onTap: () => _select(item),
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(
                                horizontal: w(16),
                                vertical: w(12),
                              ),
                              color: isSelected
                                  ? style.accentColor.withValues(alpha: 0.10)
                                  : Colors.transparent,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      item,
                                      style: style.caption.copyWith(
                                        color: isSelected
                                            ? style.accentColor
                                            : style.bodyTextColor.withValues(
                                                alpha: 0.85,
                                              ),
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                  if (isSelected)
                                    Icon(
                                      Icons.check,
                                      size: w(16),
                                      color: style.accentColor,
                                    ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
