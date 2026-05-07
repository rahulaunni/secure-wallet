import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:swallet/data/local/hive_boxes.dart';
import 'package:swallet/theme/swallet_theme.dart';
import 'package:swallet/utils/size_config.dart';
import 'package:swallet/utils/security_store.dart';
import 'package:swallet/widgets/app_lock/security_question_form_widgets.dart';

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
  bool _submitting = false;
  String? _errorText;

  bool get _hasConfiguredQuestions {
    final q1 = (_q1 ?? '').trim();
    final q2 = (_q2 ?? '').trim();
    final a1 = (_correctA1 ?? '').trim();
    final a2 = (_correctA2 ?? '').trim();
    return q1.isNotEmpty && q2.isNotEmpty && a1.isNotEmpty && a2.isNotEmpty;
  }

  bool get _canVerify {
    return !_submitting &&
        _hasConfiguredQuestions &&
        _a1Ctrl.text.trim().isNotEmpty &&
        _a2Ctrl.text.trim().isNotEmpty;
  }

  String get _questionOneText {
    if (!_hasConfiguredQuestions) return 'Security question not set';
    return (_q1 ?? '').trim();
  }

  String get _questionTwoText {
    if (!_hasConfiguredQuestions) return 'Security question not set';
    return (_q2 ?? '').trim();
  }

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

  void _handleTextChanged(String _) {
    if ((_errorText ?? '').trim().isNotEmpty) {
      setState(() => _errorText = null);
      return;
    }
    setState(() {});
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
    if (_submitting) return;
    if (!_hasConfiguredQuestions) {
      setState(
        () => _errorText =
            'Security questions are not configured for this account.',
      );
      return;
    }

    final inputA1 = _a1Ctrl.text.trim().toLowerCase();
    final inputA2 = _a2Ctrl.text.trim().toLowerCase();

    if (inputA1 == _correctA1 && inputA2 == _correctA2) {
      setState(() {
        _submitting = true;
        _errorText = null;
      });
      widget.onVerificationSuccess();
      return;
    }

    setState(() => _errorText = 'Security answers do not match. Try again.');
  }

  @override
  Widget build(BuildContext context) {
    final style = SecurityQuestionFormStyle(isDark: widget.isDark);

    if (_isLoading) {
      return Scaffold(
        backgroundColor: style.background,
        body: Center(
          child: CircularProgressIndicator(color: style.accentColor),
        ),
      );
    }

    return Scaffold(
      backgroundColor: style.background,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: w(24),
                    vertical: w(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SecurityQuestionBackButton(style: style),
                      SizedBox(height: w(20)),
                      SecurityQuestionHeading(
                        title: 'Reset PIN',
                        subtitle:
                            'Answer your security questions to reset your PIN.',
                        style: style,
                      ),
                      SizedBox(height: w(44)),
                      SecurityQuestionLabel(
                        text: 'Question 1',
                        style: style,
                      ),
                      SizedBox(height: w(6)),
                      Text(
                        _questionOneText,
                        style: style.body.copyWith(
                          color: style.subtitleColor,
                        ),
                      ),
                      SizedBox(height: w(8)),
                      SecurityAnswerField(
                        controller: _a1Ctrl,
                        hintText: 'Answer',
                        style: style,
                        onChanged: _handleTextChanged,
                      ),
                      SizedBox(height: w(28)),
                      SecurityQuestionLabel(
                        text: 'Question 2',
                        style: style,
                      ),
                      SizedBox(height: w(6)),
                      Text(
                        _questionTwoText,
                        style: style.body.copyWith(
                          color: style.subtitleColor,
                        ),
                      ),
                      SizedBox(height: w(8)),
                      SecurityAnswerField(
                        controller: _a2Ctrl,
                        hintText: 'Answer',
                        style: style,
                        onChanged: _handleTextChanged,
                      ),
                      if ((_errorText ?? '').trim().isNotEmpty) ...[
                        SizedBox(height: w(12)),
                        Text(
                          _errorText!,
                          style: style.caption.copyWith(
                            color: SwalletColors.destructive,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  w(24),
                  w(8),
                  w(24),
                  w(24),
                ),
                child: SecurityQuestionPrimaryButton(
                  label: _submitting ? 'Verifying...' : 'Verify & Reset',
                  onPressed: _canVerify ? _handleVerify : null,
                  style: style,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
