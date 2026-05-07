import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:local_auth/local_auth.dart';
import 'package:swallet/data/local/hive_boxes.dart';
import 'package:swallet/theme/swallet_theme.dart';
import 'package:swallet/utils/size_config.dart';
import 'package:swallet/utils/security_store.dart';
import 'package:swallet/widgets/app_lock/security_question_form_widgets.dart';

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
    'What was your first school name?',
    'What is your mother\'s maiden name?',
    'What was your childhood nickname?',
    'What was your first pet\'s name?',
    'What city were you born in?',
  ];

  bool get _canSave {
    return _q1 != null &&
        _q2 != null &&
        _q1 != _q2 &&
        _a1Ctrl.text.trim().isNotEmpty &&
        _a2Ctrl.text.trim().isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
    _a1Ctrl.addListener(_handleTextChanged);
    _a2Ctrl.addListener(_handleTextChanged);
    _checkBiometricAvailability();
  }

  @override
  void dispose() {
    _a1Ctrl.removeListener(_handleTextChanged);
    _a2Ctrl.removeListener(_handleTextChanged);
    _a1Ctrl.dispose();
    _a2Ctrl.dispose();
    super.dispose();
  }

  void _handleTextChanged() => setState(() {});

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
    if (_q1 == null || _q2 == null) {
      _showError('Please select both security questions');
      return;
    }

    if (_q1 == _q2) {
      _showError('Please select two different questions');
      return;
    }

    if (!_canSave || !(_formKey.currentState?.validate() ?? false)) return;

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
        content: Text(
          message,
          style: SwalletText.body.copyWith(color: Colors.white),
        ),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final style = SecurityQuestionFormStyle(isDark: widget.isDark);

    return Scaffold(
      backgroundColor: style.background,
      body: SafeArea(
        child: Form(
          key: _formKey,
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
                  title: 'Security Questions',
                  subtitle: 'Answer your security questions to set your PIN.',
                  style: style,
                ),
                SizedBox(height: h(64)),
                SecurityQuestionLabel(
                  text: 'Select Question 1',
                  style: style,
                ),
                SizedBox(height: w(8)),
                SecurityQuestionSelector(
                  value: _q1,
                  items: _questions,
                  hint: 'Select first question',
                  style: style,
                  onChanged: (v) => setState(() => _q1 = v),
                ),
                SizedBox(height: w(8)),
                SecurityAnswerField(
                  controller: _a1Ctrl,
                  hintText: 'Answer',
                  style: style,
                  validator: (v) => v!.trim().isEmpty ? 'Required' : null,
                ),
                SizedBox(height: w(32)),
                SecurityQuestionLabel(
                  text: 'Select Question 2',
                  style: style,
                ),
                SizedBox(height: w(8)),
                SecurityQuestionSelector(
                  value: _q2,
                  items: _questions,
                  hint: 'Select second question',
                  style: style,
                  onChanged: (v) => setState(() => _q2 = v),
                ),
                SizedBox(height: w(8)),
                SecurityAnswerField(
                  controller: _a2Ctrl,
                  hintText: 'Answer',
                  style: style,
                  validator: (v) => v!.trim().isEmpty ? 'Required' : null,
                ),
                if (_canCheckBiometrics) ...[
                  SizedBox(height: w(32)),
                  _buildBiometricTile(style),
                ],
                SizedBox(height: w(40)),
                SecurityQuestionPrimaryButton(
                  label: 'Save Setup',
                  onPressed: _canSave ? _handleSave : null,
                  style: style,
                ),
                SizedBox(height: w(40)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBiometricTile(SecurityQuestionFormStyle style) {
    return Material(
      color: style.fieldFill,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(r(16)),
      ),
      child: InkWell(
        onTap: () => setState(() => _useBiometrics = !_useBiometrics),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: w(16), vertical: w(12)),
          child: Row(
            children: [
              Container(
                width: w(40),
                height: w(40),
                decoration: BoxDecoration(
                  color: _useBiometrics
                      ? style.accentColor.withValues(alpha: 0.10)
                      : style.background,
                  borderRadius: BorderRadius.circular(r(16)),
                ),
                child: Icon(
                  CupertinoIcons.person_crop_circle_fill,
                  color:
                      _useBiometrics ? style.accentColor : style.subtitleColor,
                ),
              ),
              SizedBox(width: w(16)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Use biometrics',
                      style: style.body.copyWith(
                        color: style.bodyTextColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: w(2)),
                    Text(
                      'Unlock faster with fingerprint or face unlock',
                      style: style.caption.copyWith(
                        color: style.subtitleColor,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _useBiometrics,
                activeThumbColor: Colors.white,
                activeTrackColor: style.accentColor,
                inactiveThumbColor: style.bodyTextColor,
                inactiveTrackColor: style.fieldBorder,
                onChanged: (value) => setState(() => _useBiometrics = value),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
