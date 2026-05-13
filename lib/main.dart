import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'data/local/card_box_migration.dart';
import 'data/local/hive_adapters.dart';
import 'data/local/hive_boxes.dart';
import 'screens/app_unlock/pin_lock_screen.dart';
import 'screens/home_screen.dart';
import 'theme/swallet_theme.dart';
import 'utils/adaptive_layout.dart';
import 'utils/hive_encryption.dart';
import 'utils/security_store.dart';
import 'utils/size_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  registerHiveAdapters();

  final encryptionKey = await HiveEncryption.getOrCreateKey();

  if (!Hive.isBoxOpen(HiveBoxes.cards)) {
    await CardBoxMigration.openEncryptedCardsBox(encryptionKey);
  }

  if (!Hive.isBoxOpen(HiveBoxes.settings)) {
    await Hive.openBox(HiveBoxes.settings);
  }

  await SecurityStore.migrateFromSettings(Hive.box(HiveBoxes.settings));

  runApp(const CardVaultApp());
}

class CardVaultApp extends StatefulWidget {
  const CardVaultApp({super.key});

  @override
  State<CardVaultApp> createState() => _CardVaultAppState();
}

class _CardVaultAppState extends State<CardVaultApp>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  static const String _themeKey = 'is_dark';
  static const Duration _lockDelay = Duration(seconds: 10);

  bool _isDark = true;
  bool _isUnlocked = false;
  bool _showBlur = false;
  bool? _allowsLandscape;

  Timer? _backgroundLockTimer;
  late final AnimationController _unlockController;
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  final GlobalKey<HomeScreenState> _homeKey = GlobalKey<HomeScreenState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    final settingsBox = Hive.box(HiveBoxes.settings);
    if (!settingsBox.containsKey(_themeKey)) {
      settingsBox.put(_themeKey, true);
      _isDark = true;
    } else {
      _isDark = settingsBox.get(_themeKey) == true;
    }

    _unlockController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1360),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _backgroundLockTimer?.cancel();
    _unlockController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden) {
      setState(() => _showBlur = true);
      return;
    }

    if (state == AppLifecycleState.paused) {
      _backgroundLockTimer?.cancel();
      _backgroundLockTimer = Timer(_lockDelay, () {
        if (!mounted || !_isUnlocked || !_canLockFromCurrentSurface) return;

        _homeKey.currentState?.cancelAllReveals();

        setState(() {
          _isUnlocked = false;
          _unlockController.reset();
        });
      });
      return;
    }

    if (state == AppLifecycleState.resumed) {
      _backgroundLockTimer?.cancel();
      setState(() => _showBlur = false);
    }
  }

  bool get _canLockFromCurrentSurface {
    final hasRouteAboveHome = _navigatorKey.currentState?.canPop() ?? false;
    if (hasRouteAboveHome) return false;

    return _homeKey.currentState?.isPrimarySurfaceVisible ?? true;
  }

  void _handleAppUnlockStarted() {
    if (_unlockController.isAnimating || _unlockController.isCompleted) {
      return;
    }

    _unlockController.forward(from: 0);
  }

  void _handleAppUnlocked() {
    if (!_unlockController.isCompleted) {
      _unlockController.value = 1;
    }
    setState(() => _isUnlocked = true);
  }

  void _syncOrientationPolicy(MediaQueryData mediaQuery) {
    final size = mediaQuery.size;
    final allowsLandscape =
        AdaptiveLayout.allowsLandscapeForSize(size.width, size.height);
    if (_allowsLandscape == allowsLandscape) return;

    _allowsLandscape = allowsLandscape;
    final orientations = allowsLandscape
        ? const <DeviceOrientation>[
            DeviceOrientation.portraitUp,
            DeviceOrientation.landscapeLeft,
            DeviceOrientation.landscapeRight,
          ]
        : const <DeviceOrientation>[
            DeviceOrientation.portraitUp,
          ];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemChrome.setPreferredOrientations(orientations);
    });
  }

  TextTheme _buildLockedTextTheme(TextTheme base) {
    final poppins = GoogleFonts.poppinsTextTheme(base);
    return poppins.copyWith(
      displayLarge: poppins.displayLarge?.copyWith(fontWeight: FontWeight.w600),
      displayMedium:
          poppins.displayMedium?.copyWith(fontWeight: FontWeight.w600),
      displaySmall: poppins.displaySmall?.copyWith(fontWeight: FontWeight.w600),
      headlineLarge:
          poppins.headlineLarge?.copyWith(fontWeight: FontWeight.w600),
      headlineMedium:
          poppins.headlineMedium?.copyWith(fontWeight: FontWeight.w600),
      headlineSmall:
          poppins.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
      titleLarge: poppins.titleLarge?.copyWith(fontWeight: FontWeight.w500),
      titleMedium: poppins.titleMedium?.copyWith(fontWeight: FontWeight.w500),
      titleSmall: poppins.titleSmall?.copyWith(fontWeight: FontWeight.w500),
      bodyLarge: poppins.bodyLarge?.copyWith(fontWeight: FontWeight.w400),
      bodyMedium: poppins.bodyMedium?.copyWith(fontWeight: FontWeight.w400),
      bodySmall: poppins.bodySmall?.copyWith(fontWeight: FontWeight.w400),
      labelLarge: poppins.labelLarge?.copyWith(fontWeight: FontWeight.w500),
      labelMedium: poppins.labelMedium?.copyWith(fontWeight: FontWeight.w500),
      labelSmall: poppins.labelSmall?.copyWith(fontWeight: FontWeight.w500),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        SizeConfig.init(context);
        final mediaQuery = MediaQuery.of(context);
        _syncOrientationPolicy(mediaQuery);
        return MediaQuery(
          data: mediaQuery.copyWith(
            textScaler: TextScaler.noScaling,
            boldText: false,
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
      themeMode: _isDark ? ThemeMode.dark : ThemeMode.light,
      theme: SwalletTheme.theme(false).copyWith(
        textTheme: _buildLockedTextTheme(ThemeData.light().textTheme),
      ),
      darkTheme: SwalletTheme.theme(true).copyWith(
        textTheme: _buildLockedTextTheme(ThemeData.dark().textTheme),
      ),
      home: Scaffold(
        body: Stack(
          children: [
            HomeScreen(
              key: _homeKey,
              isDark: _isDark,
              unlockSettleAnimation: _unlockController,
              onThemeChanged: (value) {
                setState(() => _isDark = value);
                Hive.box(HiveBoxes.settings).put(_themeKey, value);
              },
            ),
            Positioned.fill(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                reverseDuration: Duration.zero,
                switchInCurve: Curves.easeOut,
                child: _showBlur
                    ? BackdropFilter(
                        key: const ValueKey('blur'),
                        filter: ImageFilter.blur(
                          sigmaX: 16,
                          sigmaY: 16,
                        ),
                        child: Container(
                          color: Colors.black.withValues(alpha: 0.15),
                        ),
                      )
                    : const SizedBox.shrink(
                        key: ValueKey('empty'),
                      ),
              ),
            ),
            if (!_isUnlocked)
              Positioned.fill(
                child: PinLockScreen(
                  onUnlockStarted: _handleAppUnlockStarted,
                  onUnlocked: _handleAppUnlocked,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
