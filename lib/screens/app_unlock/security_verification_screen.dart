import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:swallet/data/local/hive_boxes.dart';
import 'package:swallet/utils/security_store.dart';
import 'package:swallet/widgets/add_card/add_card_material_tokens.dart';
import 'package:swallet/widgets/buttons/custom_back_button.dart';

class SecurityVerificationScreen extends StatefulWidget {
  final bool isDark;
  final VoidCallback onVerificationSuccess;

  const SecurityVerificationScreen({
    super.key,
    required this.isDark,
    required this.onVerificationSuccess,
  });

  @override
  State<SecurityVerificationScreen> createState() =>
      _SecurityVerificationScreenState();
}

class _SecurityVerificationScreenState
    extends State<SecurityVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _a1Ctrl = TextEditingController();
  final TextEditingController _a2Ctrl = TextEditingController();

  late Box _settingsBox;
  String? _q1;
  String? _q2;
  String? _correctA1;
  String? _correctA2;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  @override
  void dispose() {
    _a1Ctrl.dispose();
    _a2Ctrl.dispose();
    super.dispose();
  }

  Future<void> _loadQuestions() async {
    _settingsBox = Hive.box(HiveBoxes.settings);
    _q1 = _settingsBox.get('security_q1');
    _q2 = _settingsBox.get('security_q2');
    final answers = await SecurityStore.readRecoveryAnswers();
    _correctA1 = answers.$1;
    _correctA2 = answers.$2;

    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  void _handleVerify() {
    if (!_formKey.currentState!.validate()) return;

    final inputA1 = _a1Ctrl.text.trim().toLowerCase();
    final inputA2 = _a2Ctrl.text.trim().toLowerCase();

    if (inputA1 == _correctA1 && inputA2 == _correctA2) {
      widget.onVerificationSuccess();
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Incorrect answers. Please try again.',
          style: GoogleFonts.roboto(),
        ),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AddCardMaterialTokens(widget.isDark);

    if (_isLoading) {
      return Scaffold(
        backgroundColor: tokens.surface,
        body: Center(
          child: CircularProgressIndicator(color: tokens.primary),
        ),
      );
    }

    return Scaffold(
      backgroundColor: tokens.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 64,
        leadingWidth: 72,
        leading: Center(child: CustomBackButton(isDark: widget.isDark)),
        title: Text(
          'Reset PIN',
          style: GoogleFonts.roboto(
            color: tokens.onSurface,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 18, 24, 28),
        child: Form(
          key: _formKey,
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
                        CupertinoIcons.question_circle_fill,
                        color: tokens.onPrimaryContainer,
                        size: 30,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Security verification',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.roboto(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: tokens.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Answer your questions to reset your PIN.',
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
              if (_q1 != null) ...[
                _buildQuestionLabel('Question 1', tokens),
                const SizedBox(height: 8),
                _buildQuestionCard(_q1!, tokens),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _a1Ctrl,
                  hint: 'Answer',
                  tokens: tokens,
                ),
              ],
              const SizedBox(height: 26),
              if (_q2 != null) ...[
                _buildQuestionLabel('Question 2', tokens),
                const SizedBox(height: 8),
                _buildQuestionCard(_q2!, tokens),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _a2Ctrl,
                  hint: 'Answer',
                  tokens: tokens,
                ),
              ],
              const SizedBox(height: 36),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton(
                  onPressed: _handleVerify,
                  style: FilledButton.styleFrom(
                    backgroundColor: tokens.primary,
                    foregroundColor: tokens.onPrimary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: tokens.pillRadius,
                    ),
                  ),
                  child: Text(
                    'Verify and reset',
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
    );
  }

  Widget _buildQuestionLabel(String text, AddCardMaterialTokens tokens) {
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

  Widget _buildQuestionCard(String question, AddCardMaterialTokens tokens) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: tokens.surfaceContainer,
        borderRadius: tokens.controlRadius,
        border: Border.all(
          color: tokens.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      child: Text(
        question,
        style: GoogleFonts.roboto(
          color: tokens.onSurface,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
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
}
