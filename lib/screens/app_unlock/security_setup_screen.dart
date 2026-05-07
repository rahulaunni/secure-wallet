import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:local_auth/local_auth.dart';
import 'package:swallet/data/local/hive_boxes.dart';
import 'package:swallet/utils/security_store.dart';
import 'package:swallet/widgets/add_card/add_card_material_tokens.dart';

class SecuritySetupScreen extends StatefulWidget {
  final bool isDark;

  const SecuritySetupScreen({
    super.key,
    required this.isDark,
  });

  @override
  State<SecuritySetupScreen> createState() => _SecuritySetupScreenState();
}

class _SecuritySetupScreenState extends State<SecuritySetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _a1Ctrl = TextEditingController();
  final TextEditingController _a2Ctrl = TextEditingController();

  String? _q1;
  String? _q2;
  bool _useBiometrics = false;
  bool _canCheckBiometrics = false;

  final List<String> _questions = [
    "What is your mother's maiden name?",
    "What was the name of your first pet?",
    "What city were you born in?",
    "What is your favorite food?",
    "What was the model of your first car?",
    "What is the name of your favorite teacher?",
  ];

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
  }

  @override
  void dispose() {
    _a1Ctrl.dispose();
    _a2Ctrl.dispose();
    super.dispose();
  }

  Future<void> _checkBiometricAvailability() async {
    final auth = LocalAuthentication();
    final canCheck = await auth.canCheckBiometrics;
    if (!mounted) return;
    setState(() {
      _canCheckBiometrics = canCheck;
      if (canCheck) _useBiometrics = true;
    });
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    if (_q1 == null || _q2 == null) {
      _showError('Please select both security questions');
      return;
    }

    if (_q1 == _q2) {
      _showError('Please select two different questions');
      return;
    }

    final box = Hive.box(HiveBoxes.settings);

    await box.put('security_q1', _q1);
    await box.put('security_q2', _q2);
    await box.put('use_biometrics', _useBiometrics);
    await SecurityStore.saveRecoveryAnswers(
      answer1: _a1Ctrl.text.trim().toLowerCase(),
      answer2: _a2Ctrl.text.trim().toLowerCase(),
    );

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.roboto()),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AddCardMaterialTokens(widget.isDark);

    return Scaffold(
      backgroundColor: tokens.surface,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: tokens.primaryContainer,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Icon(
                          CupertinoIcons.shield_fill,
                          color: tokens.onPrimaryContainer,
                          size: 30,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Security setup',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.roboto(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: tokens.onSurface,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Add recovery questions for PIN reset.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.roboto(
                          color: tokens.onSurfaceVariant,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 34),
                _buildSectionLabel('Question 1', tokens),
                const SizedBox(height: 12),
                ExpandableQuestionSelector(
                  value: _q1,
                  items: _questions,
                  hint: 'Select first question',
                  tokens: tokens,
                  onChanged: (v) => setState(() => _q1 = v),
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _a1Ctrl,
                  hint: 'Answer',
                  tokens: tokens,
                ),
                const SizedBox(height: 28),
                _buildSectionLabel('Question 2', tokens),
                const SizedBox(height: 12),
                ExpandableQuestionSelector(
                  value: _q2,
                  items: _questions,
                  hint: 'Select second question',
                  tokens: tokens,
                  onChanged: (v) => setState(() => _q2 = v),
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _a2Ctrl,
                  hint: 'Answer',
                  tokens: tokens,
                ),
                if (_canCheckBiometrics) ...[
                  const SizedBox(height: 30),
                  _buildBiometricTile(tokens),
                ],
                const SizedBox(height: 36),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: FilledButton(
                    onPressed: _handleSave,
                    style: FilledButton.styleFrom(
                      backgroundColor: tokens.primary,
                      foregroundColor: tokens.onPrimary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: tokens.pillRadius,
                      ),
                    ),
                    child: Text(
                      'Save setup',
                      style: GoogleFonts.roboto(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String text, AddCardMaterialTokens tokens) {
    return Text(
      text.toUpperCase(),
      style: GoogleFonts.roboto(
        color: tokens.primary,
        fontSize: 12,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.4,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required AddCardMaterialTokens tokens,
  }) {
    return TextFormField(
      controller: controller,
      style: GoogleFonts.roboto(color: tokens.onSurface, fontSize: 15),
      cursorColor: tokens.primary,
      decoration: InputDecoration(
        filled: true,
        fillColor: tokens.surfaceContainer,
        hintText: hint,
        hintStyle: GoogleFonts.roboto(
          color: tokens.onSurfaceVariant,
          fontSize: 15,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: tokens.controlRadius,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: tokens.controlRadius,
          borderSide: BorderSide(color: tokens.primary, width: 1.2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: tokens.controlRadius,
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
        ),
      ),
      validator: (v) => v!.trim().isEmpty ? 'Required' : null,
    );
  }

  Widget _buildBiometricTile(AddCardMaterialTokens tokens) {
    return Material(
      color: tokens.surfaceContainer,
      borderRadius: tokens.containerRadius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => setState(() => _useBiometrics = !_useBiometrics),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: _useBiometrics
                      ? tokens.primaryContainer
                      : tokens.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  CupertinoIcons.person_crop_circle_fill,
                  color: _useBiometrics
                      ? tokens.onPrimaryContainer
                      : tokens.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Use biometrics',
                      style: GoogleFonts.roboto(
                        color: tokens.onSurface,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Unlock faster with fingerprint or face unlock',
                      style: GoogleFonts.roboto(
                        color: tokens.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _useBiometrics,
                activeThumbColor: tokens.onPrimary,
                activeTrackColor: tokens.primary,
                inactiveThumbColor: tokens.onSurfaceVariant,
                inactiveTrackColor: tokens.surfaceContainerHighest,
                onChanged: (value) => setState(() => _useBiometrics = value),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ExpandableQuestionSelector extends StatefulWidget {
  final String? value;
  final List<String> items;
  final String hint;
  final AddCardMaterialTokens tokens;
  final ValueChanged<String> onChanged;

  const ExpandableQuestionSelector({
    super.key,
    required this.value,
    required this.items,
    required this.hint,
    required this.tokens,
    required this.onChanged,
  });

  @override
  State<ExpandableQuestionSelector> createState() =>
      _ExpandableQuestionSelectorState();
}

class _ExpandableQuestionSelectorState
    extends State<ExpandableQuestionSelector> {
  bool _isExpanded = false;

  void _select(String item) {
    widget.onChanged(item);
    setState(() => _isExpanded = false);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = widget.tokens;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeInOutCubic,
      decoration: BoxDecoration(
        color: tokens.surfaceContainer,
        borderRadius: tokens.controlRadius,
        border: Border.all(
          color: _isExpanded
              ? tokens.primary
              : tokens.outlineVariant.withValues(alpha: 0.35),
          width: _isExpanded ? 1.2 : 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: tokens.controlRadius,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.value ?? widget.hint,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.roboto(
                        color: widget.value == null
                            ? tokens.onSurfaceVariant
                            : tokens.onSurface,
                        fontSize: 15,
                        fontWeight: widget.value == null
                            ? FontWeight.w400
                            : FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 260),
                    child: Icon(
                      CupertinoIcons.chevron_down,
                      color: _isExpanded
                          ? tokens.primary
                          : tokens.onSurfaceVariant,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeInOutCubic,
            alignment: Alignment.topCenter,
            child: SizedBox(
              height: _isExpanded ? null : 0,
              child: _isExpanded
                  ? ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 240),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Divider(
                              height: 1,
                              color: tokens.outlineVariant.withValues(
                                alpha: 0.5,
                              ),
                            ),
                            ...widget.items.map((item) {
                              final isSelected = item == widget.value;
                              return InkWell(
                                onTap: () => _select(item),
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 18,
                                    vertical: 13,
                                  ),
                                  color: isSelected
                                      ? tokens.primaryContainer
                                      : Colors.transparent,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          item,
                                          style: GoogleFonts.roboto(
                                            color: isSelected
                                                ? tokens.onPrimaryContainer
                                                : tokens.onSurface,
                                            fontSize: 14,
                                            fontWeight: isSelected
                                                ? FontWeight.w700
                                                : FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                      if (isSelected)
                                        Icon(
                                          CupertinoIcons.check_mark,
                                          size: 17,
                                          color: tokens.onPrimaryContainer,
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
          ),
        ],
      ),
    );
  }
}
