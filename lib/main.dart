import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'screens/home_screen.dart';
import 'screens/app_unlock/pin_lock_screen.dart';

import 'data/local/card_box_migration.dart';
import 'data/local/hive_adapters.dart';
import 'data/local/hive_boxes.dart';
import 'utils/adaptive_layout.dart';
import 'utils/hive_encryption.dart';
import 'utils/security_store.dart';

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

  bool _isDark = true; // Default to Dark
  bool _isUnlocked = false; // Start Locked

  bool _showBlur = false;
  Timer? _backgroundLockTimer;

  static const Duration _lockDelay = Duration(seconds: 10);

  late final AnimationController _unlockController;
  final GlobalKey<HomeScreenState> _homeKey = GlobalKey<HomeScreenState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    final settingsBox = Hive.box(HiveBoxes.settings);

    // 🔧 FORCE DEFAULT TO DARK MODE
    // If no preference is saved, set it to true (Dark)
    if (!settingsBox.containsKey(_themeKey)) {
      settingsBox.put(_themeKey, true);
      _isDark = true;
    } else {
      _isDark = settingsBox.get(_themeKey);
    }

    _unlockController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _backgroundLockTimer?.cancel();
    _unlockController.dispose();
    super.dispose();
  }

  // ================= APP LIFECYCLE =================

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 1. App inactive/hidden -> Show Blur
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden) {
      setState(() => _showBlur = true);
      return;
    }

    // 2. App backgrounded -> Start Timer to Lock
    if (state == AppLifecycleState.paused) {
      _backgroundLockTimer?.cancel();
      _backgroundLockTimer = Timer(_lockDelay, () {
        _homeKey.currentState?.cancelAllReveals();

        setState(() {
          _isUnlocked = false;
          _unlockController.reset();
        });
      });
      return;
    }

    // 3. App resumed -> Clear Blur
    if (state == AppLifecycleState.resumed) {
      _backgroundLockTimer?.cancel();
      setState(() => _showBlur = false);
      return;
    }
  }

  // ================= UNLOCK FLOW =================

  void _handleAppUnlocked() {
    _unlockController.value = 1;
    setState(() => _isUnlocked = true);
  }

  // ================= SCALING & THEME HELPERS =================

  EdgeInsets _scalePadding(EdgeInsets original, double scale) {
    if (scale == 0) return original;
    return EdgeInsets.fromLTRB(
      original.left / scale,
      original.top / scale,
      original.right / scale,
      original.bottom / scale,
    );
  }

  /// 🔒 Force Regular/Medium weights to override system "Bold Text"
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

  /// 🔒 Force Button styles
  ElevatedButtonThemeData _buildButtonTheme(bool isDark) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: isDark ? const Color(0xFF2C2C2E) : Colors.black,
        textStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
          height: 1.0,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        minimumSize: const Size(120, 50),
      ),
    );
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // 🔒 THE PROJECTOR FIX: Forces 390px width layout
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        if (!AdaptiveLayout.usesPhoneCanvas(mediaQuery.size.width)) {
          return MediaQuery(
            data: mediaQuery.copyWith(
              textScaler: TextScaler.noScaling,
              boldText: false,
            ),
            child: child!,
          );
        }

        const double designWidth = AdaptiveLayout.phoneDesignWidth;

        final double scale = mediaQuery.size.width / designWidth;
        final double scaledHeight = mediaQuery.size.height / scale;

        final scaledPadding = _scalePadding(mediaQuery.padding, scale);
        final scaledViewInsets = _scalePadding(mediaQuery.viewInsets, scale);
        final scaledViewPadding = _scalePadding(mediaQuery.viewPadding, scale);

        return MediaQuery(
          data: mediaQuery.copyWith(
            textScaler: TextScaler.noScaling,
            boldText: false,
            devicePixelRatio: mediaQuery.devicePixelRatio * scale,
            size: Size(designWidth, scaledHeight),
            padding: scaledPadding,
            viewInsets: scaledViewInsets,
            viewPadding: scaledViewPadding,
          ),
          child: FittedBox(
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: designWidth,
              height: scaledHeight,
              child: child!,
            ),
          ),
        );
      },

      themeMode: _isDark ? ThemeMode.dark : ThemeMode.light,

      // ✅ LIGHT THEME
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: GoogleFonts.poppins().fontFamily,
        textTheme: _buildLockedTextTheme(ThemeData.light().textTheme),
        elevatedButtonTheme: _buildButtonTheme(false),
        filledButtonTheme:
            FilledButtonThemeData(style: _buildButtonTheme(false).style),
      ),

      // ✅ DARK THEME
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        fontFamily: GoogleFonts.poppins().fontFamily,
        textTheme: _buildLockedTextTheme(ThemeData.dark().textTheme),
        elevatedButtonTheme: _buildButtonTheme(true),
        filledButtonTheme:
            FilledButtonThemeData(style: _buildButtonTheme(true).style),
      ),

      home: Scaffold(
        body: Stack(
          children: [
            // ================= HOME =================
            AnimatedBuilder(
              animation: _unlockController,
              builder: (_, child) {
                final scale = Tween<double>(
                  begin: 0.98,
                  end: 1.0,
                ).animate(
                  CurvedAnimation(
                    parent: _unlockController,
                    curve: Curves.easeOutCubic,
                  ),
                );

                return Transform.scale(
                  scale: scale.value,
                  child: child,
                );
              },
              child: HomeScreen(
                key: _homeKey,
                isDark: _isDark,
                onThemeChanged: (v) {
                  setState(() => _isDark = v);
                  Hive.box(HiveBoxes.settings).put(_themeKey, v);
                },
              ),
            ),

            // ================= BLUR OVERLAY =================
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

            // ================= PIN LOCK SCREEN =================
            if (!_isUnlocked)
              Positioned.fill(
                child: PinLockScreen(
                  onUnlocked: _handleAppUnlocked,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
