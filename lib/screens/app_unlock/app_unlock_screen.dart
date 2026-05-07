import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:swallet/data/local/hive_boxes.dart';
import 'package:swallet/theme/swallet_theme.dart';
import 'package:swallet/utils/device_auth.dart';
import 'package:swallet/widgets/add_card/add_card_material_tokens.dart';

const String _kLottieAsset = 'assets/lottie/auth_success.json';

enum _AuthState {
  checking,
  success,
  failed,
}

class AppUnlockScreen extends StatefulWidget {
  final VoidCallback onUnlocked;

  const AppUnlockScreen({
    super.key,
    required this.onUnlocked,
  });

  @override
  State<AppUnlockScreen> createState() => _AppUnlockScreenState();
}

class _AppUnlockScreenState extends State<AppUnlockScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _lottieController;

  _AuthState _state = _AuthState.checking;
  bool _authInProgress = false;
  late bool _isDark;

  @override
  void initState() {
    super.initState();
    _isDark = Hive.box(HiveBoxes.settings).get('is_dark', defaultValue: true);
    _lottieController = AnimationController(vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _startAuth());
  }

  @override
  void dispose() {
    _lottieController.dispose();
    super.dispose();
  }

  Future<void> _startAuth() async {
    if (_authInProgress) return;
    _authInProgress = true;

    setState(() => _state = _AuthState.checking);

    final success = await DeviceAuth.authenticate(reason: 'Unlock Swallet');

    if (!mounted) return;

    if (success) {
      setState(() => _state = _AuthState.success);
      _lottieController
        ..value = 0
        ..forward();

      _lottieController.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          widget.onUnlocked();
        }
      });
    } else {
      setState(() => _state = _AuthState.failed);
      _lottieController
        ..value = 0
        ..stop();
    }

    _authInProgress = false;
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AddCardMaterialTokens(_isDark);
    final palette = SwalletPalette(_isDark);

    return Scaffold(
      backgroundColor: palette.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
          child: Column(
            children: [
              Image.asset(
                'assets/images/logo_56.png',
                height: 56,
                width: 56,
                fit: BoxFit.contain,
              ),
              const Spacer(),
              Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  color: tokens.surfaceContainer,
                  borderRadius: BorderRadius.circular(36),
                  border: Border.all(
                    color: tokens.outlineVariant.withValues(alpha: 0.64),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: tokens.primary.withValues(
                        alpha: _isDark ? 0.14 : 0.08,
                      ),
                      blurRadius: 28,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: SizedBox(
                  height: 170,
                  width: 170,
                  child: Lottie.asset(
                    _kLottieAsset,
                    controller: _lottieController,
                    repeat: false,
                    onLoaded: (composition) {
                      _lottieController.duration = composition.duration;
                      if (_state == _AuthState.failed) {
                        _lottieController.value = 0;
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                _state == _AuthState.failed
                    ? 'Authentication failed'
                    : 'Unlock your wallet',
                style: SwalletText.title.copyWith(
                  color: tokens.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _state == _AuthState.failed
                    ? 'Try again to access your cards.'
                    : 'Confirm it is you to continue.',
                style: SwalletText.caption.copyWith(
                  color: tokens.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              if (_state == _AuthState.failed)
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: FilledButton.icon(
                    onPressed: _startAuth,
                    style: FilledButton.styleFrom(
                      backgroundColor: tokens.primary,
                      foregroundColor: tokens.onPrimary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: tokens.pillRadius,
                      ),
                    ),
                    icon: const Icon(CupertinoIcons.lock_open_fill, size: 18),
                    label: Text(
                      'Unlock',
                      style: SwalletText.bodyMedium.copyWith(
                        fontSize: 16,
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
}
