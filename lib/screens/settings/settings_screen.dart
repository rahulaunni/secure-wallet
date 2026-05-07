import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:swallet/data/local/card_repository.dart';
import 'package:swallet/data/local/hive_boxes.dart';
import 'package:swallet/screens/app_unlock/pin_lock_screen.dart';
import 'package:swallet/screens/app_unlock/security_verification_screen.dart';
import 'package:swallet/screens/home_screen.dart';
import 'package:swallet/theme/swallet_theme.dart';
import 'package:swallet/utils/size_config.dart';
import 'package:swallet/utils/security_store.dart';
import 'package:swallet/widgets/add_card/add_card_material_tokens.dart';
import 'package:swallet/widgets/buttons/custom_back_button.dart';

class SettingsScreen extends StatefulWidget {
  final bool isDark;
  final ValueChanged<bool> onThemeChanged;
  final VoidCallback? onClose;

  const SettingsScreen({
    super.key,
    required this.isDark,
    required this.onThemeChanged,
    this.onClose,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late Box _settingsBox;
  bool _useBiometrics = false;

  @override
  void initState() {
    super.initState();
    _settingsBox = Hive.box(HiveBoxes.settings);
    _useBiometrics = _settingsBox.get('use_biometrics', defaultValue: false);
  }

  Future<void> _toggleBiometrics(bool value) async {
    await _settingsBox.put('use_biometrics', value);
    setState(() => _useBiometrics = value);
  }

  void _handleChangePin() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (verificationContext) => SecurityVerificationScreen(
          isDark: widget.isDark,
          onVerificationSuccess: () async {
            Navigator.pop(verificationContext);
            await SecurityStore.deletePin();
            if (!mounted) return;

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (pinContext) => PinLockScreen(
                  onUnlocked: () {
                    Navigator.pop(pinContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'New PIN set successfully',
                          style: SwalletText.bodyMedium.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _handleClearData() {
    final tokens = AddCardMaterialTokens(widget.isDark);
    final palette = SwalletPalette(widget.isDark);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: palette.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: tokens.containerRadius),
        title: Text(
          'Clear all data?',
          style: SwalletText.title.copyWith(color: palette.text),
        ),
        content: Text(
          'This will delete all saved cards and reset your PIN. The app will restart.',
          style: SwalletText.body.copyWith(color: palette.textMuted),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            style: TextButton.styleFrom(
              foregroundColor: tokens.primary,
              shape: RoundedRectangleBorder(borderRadius: tokens.pillRadius),
            ),
            child: Text(
              'Cancel',
              style: SwalletText.button,
            ),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(dialogContext);

              try {
                await CardRepository.clearAll();

                if (!_settingsBox.isOpen) {
                  _settingsBox = await Hive.openBox(HiveBoxes.settings);
                }

                await _settingsBox.clear();
                await SecurityStore.clearAll();
                await _settingsBox.flush();
                await _settingsBox.put('is_dark', widget.isDark);
              } catch (e) {
                debugPrint('Wipe failed: $e');
              }

              if (!mounted) return;

              Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => PinLockScreen(
                    onUnlocked: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HomeScreen(
                            isDark: widget.isDark,
                            onThemeChanged: widget.onThemeChanged,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                (route) => false,
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: tokens.pillRadius),
            ),
            child: Text(
              'Clear all',
              style: SwalletText.button,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AddCardMaterialTokens(widget.isDark);
    final palette = SwalletPalette(widget.isDark);

    return Scaffold(
      backgroundColor: palette.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: w(24),
            vertical: w(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopBar(palette),
              SizedBox(height: w(20)),
              _buildSectionHeader('Security', tokens),
              SizedBox(height: w(8)),
              _buildGroup(
                tokens,
                children: [
                  _buildSwitchTile(
                    title: 'Biometric unlock',
                    icon: CupertinoIcons.person_crop_circle_fill,
                    value: _useBiometrics,
                    onChanged: _toggleBiometrics,
                    tokens: tokens,
                  ),
                  _buildDivider(tokens),
                  _buildNavTile(
                    title: 'Change PIN',
                    icon: CupertinoIcons.lock_shield_fill,
                    tokens: tokens,
                    onTap: _handleChangePin,
                  ),
                ],
              ),
              SizedBox(height: w(24)),
              _buildSectionHeader('Appearance', tokens),
              SizedBox(height: w(8)),
              _buildGroup(
                tokens,
                children: [
                  _buildSwitchTile(
                    title: 'Dark mode',
                    icon: widget.isDark
                        ? CupertinoIcons.moon_fill
                        : CupertinoIcons.sun_max_fill,
                    value: widget.isDark,
                    onChanged: widget.onThemeChanged,
                    tokens: tokens,
                  ),
                ],
              ),
              SizedBox(height: w(24)),
              _buildSectionHeader('Data', tokens),
              SizedBox(height: w(8)),
              _buildGroup(
                tokens,
                children: [
                  _buildNavTile(
                    title: 'Clear all data',
                    icon: CupertinoIcons.xmark_circle_fill,
                    tokens: tokens,
                    onTap: _handleClearData,
                    destructive: true,
                    hideArrow: true,
                  ),
                ],
              ),
              SizedBox(height: w(32)),
              Center(
                child: Text(
                  'Version 1.0.0',
                  style: SwalletText.caption.copyWith(
                    color: tokens.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(SwalletPalette palette) {
    return Row(
      children: [
        CustomBackButton(
          isDark: widget.isDark,
          onTap: widget.onClose,
        ),
        SizedBox(width: w(4)),
        Expanded(
          child: SizedBox(
            height: w(56),
            child: Align(
              alignment: Alignment.center,
              child: Text(
                'Settings',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: SwalletText.title.copyWith(
                  color: palette.text,
                  fontSize: sp(16),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: w(44), height: w(40)),
      ],
    );
  }

  Widget _buildSectionHeader(String title, AddCardMaterialTokens tokens) {
    return Text(
      title,
      style: SwalletText.caption.copyWith(
        color: tokens.onSurfaceVariant,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildGroup(
    AddCardMaterialTokens tokens, {
    required List<Widget> children,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(r(24)),
      child: ColoredBox(
        color: widget.isDark
            ? tokens.surfaceContainerHigh
            : tokens.surfaceContainer,
        child: Column(children: children),
      ),
    );
  }

  Widget _buildDivider(AddCardMaterialTokens tokens) {
    return Divider(
      height: w(1),
      thickness: w(1),
      color: tokens.outlineVariant,
    );
  }

  Widget _buildIconShell(
    IconData icon,
    AddCardMaterialTokens tokens, {
    bool destructive = false,
  }) {
    final color = destructive ? Colors.redAccent : tokens.onPrimaryContainer;
    return SizedBox(
      width: 24,
      height: 24,
      child: Icon(
        icon,
        color: destructive ? color : tokens.onSurface,
        size: 24,
      ),
    );
  }

  Widget _buildNavTile({
    required String title,
    required IconData icon,
    required AddCardMaterialTokens tokens,
    required VoidCallback onTap,
    bool destructive = false,
    bool hideArrow = false,
  }) {
    final titleColor = destructive ? Colors.redAccent : tokens.onSurface;

    return Material(
      color: Colors.transparent,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: w(16),
            vertical: w(16),
          ),
          child: Row(
            children: [
              _buildIconShell(icon, tokens, destructive: destructive),
              SizedBox(width: w(10)),
              Expanded(
                child: Text(
                  title,
                  style: SwalletText.body.copyWith(
                    color: titleColor,
                    fontSize: sp(14),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (!hideArrow)
                Icon(
                  CupertinoIcons.chevron_right,
                  color: tokens.onSurfaceVariant,
                  size: w(22),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
    required AddCardMaterialTokens tokens,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: w(16),
        vertical: w(12),
      ),
      child: Row(
        children: [
          _buildIconShell(icon, tokens),
          SizedBox(width: w(10)),
          Expanded(
            child: Text(
              title,
              style: SwalletText.body.copyWith(
                color: tokens.onSurface,
                fontSize: sp(14),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Transform.scale(
            scale: 0.86,
            child: Switch(
              value: value,
              activeThumbColor: tokens.onPrimary,
              activeTrackColor: tokens.primary,
              inactiveThumbColor: tokens.onSurface,
              inactiveTrackColor: tokens.surfaceContainerHighest,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              trackOutlineColor: WidgetStateProperty.resolveWith(
                (states) => states.contains(WidgetState.selected)
                    ? tokens.primary.withValues(alpha: 0.36)
                    : tokens.outlineVariant.withValues(alpha: 0.70),
              ),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
