import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:swallet/data/local/card_repository.dart';
import 'package:swallet/data/local/hive_boxes.dart';
import 'package:swallet/screens/app_unlock/pin_lock_screen.dart';
import 'package:swallet/screens/app_unlock/security_verification_screen.dart';
import 'package:swallet/screens/home_screen.dart';
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
                          style:
                              GoogleFonts.roboto(fontWeight: FontWeight.w600),
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

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: tokens.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: tokens.containerRadius),
        title: Text(
          'Clear all data?',
          style: GoogleFonts.roboto(
            color: tokens.onSurface,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        content: Text(
          'This will delete all saved cards and reset your PIN. The app will restart.',
          style: GoogleFonts.roboto(
            color: tokens.onSurfaceVariant,
            fontSize: 14,
            height: 1.35,
          ),
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
              style: GoogleFonts.roboto(fontWeight: FontWeight.w700),
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
              style: GoogleFonts.roboto(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AddCardMaterialTokens(widget.isDark);

    return Scaffold(
      backgroundColor: tokens.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 64,
        leadingWidth: 72,
        leading: Center(
          child: CustomBackButton(
            isDark: widget.isDark,
            onTap: widget.onClose,
          ),
        ),
        title: Text(
          'Settings',
          style: GoogleFonts.roboto(
            color: tokens.onSurface,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Security', tokens),
            const SizedBox(height: 8),
            _buildGroup(
              tokens,
              children: [
                _buildSwitchTile(
                  title: 'Biometric unlock',
                  subtitle: 'Use fingerprint or face unlock',
                  icon: CupertinoIcons.person_crop_circle_fill,
                  value: _useBiometrics,
                  onChanged: _toggleBiometrics,
                  tokens: tokens,
                ),
                _buildDivider(tokens),
                _buildNavTile(
                  title: 'Change PIN',
                  subtitle: 'Verify security answers first',
                  icon: CupertinoIcons.lock_shield_fill,
                  tokens: tokens,
                  onTap: _handleChangePin,
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSectionHeader('Appearance', tokens),
            const SizedBox(height: 8),
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
            const SizedBox(height: 24),
            _buildSectionHeader('Data', tokens),
            const SizedBox(height: 8),
            _buildGroup(
              tokens,
              children: [
                _buildNavTile(
                  title: 'Clear all data',
                  subtitle: 'Delete cards and reset settings',
                  icon: CupertinoIcons.xmark_circle_fill,
                  tokens: tokens,
                  onTap: _handleClearData,
                  destructive: true,
                  hideArrow: true,
                ),
              ],
            ),
            const SizedBox(height: 32),
            Center(
              child: Text(
                'Version 1.0.0',
                style: GoogleFonts.roboto(
                  color: tokens.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, AddCardMaterialTokens tokens) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 4),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.roboto(
          color: tokens.primary,
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  Widget _buildGroup(
    AddCardMaterialTokens tokens, {
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: tokens.surfaceContainer,
        borderRadius: tokens.containerRadius,
        border: Border.all(
          color: tokens.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDivider(AddCardMaterialTokens tokens) {
    return Padding(
      padding: const EdgeInsets.only(left: 74),
      child: Divider(
        height: 1,
        thickness: 1,
        color: tokens.outlineVariant.withValues(alpha: 0.45),
      ),
    );
  }

  Widget _buildIconShell(
    IconData icon,
    AddCardMaterialTokens tokens, {
    bool destructive = false,
  }) {
    final color = destructive ? Colors.redAccent : tokens.onPrimaryContainer;
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: destructive
            ? Colors.redAccent.withValues(alpha: 0.12)
            : tokens.primaryContainer,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Icon(icon, color: color, size: 21),
    );
  }

  Widget _buildNavTile({
    required String title,
    String? subtitle,
    required IconData icon,
    required AddCardMaterialTokens tokens,
    required VoidCallback onTap,
    bool destructive = false,
    bool hideArrow = false,
  }) {
    final titleColor = destructive ? Colors.redAccent : tokens.onSurface;

    return Material(
      color: Colors.transparent,
      borderRadius: tokens.containerRadius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              _buildIconShell(icon, tokens, destructive: destructive),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.roboto(
                        color: titleColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: GoogleFonts.roboto(
                          color: tokens.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (!hideArrow)
                Icon(
                  CupertinoIcons.chevron_right,
                  color: tokens.onSurfaceVariant,
                  size: 18,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    String? subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
    required AddCardMaterialTokens tokens,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          _buildIconShell(icon, tokens),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.roboto(
                    color: tokens.onSurface,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.roboto(
                      color: tokens.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: tokens.onPrimary,
            activeTrackColor: tokens.primary,
            inactiveThumbColor: tokens.onSurfaceVariant,
            inactiveTrackColor: tokens.surfaceContainerHighest,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
