import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:swallet/data/local/hive_boxes.dart';
import 'package:swallet/widgets/add_card/add_card_material_tokens.dart';

import 'device_auth.dart';

class AuthGate extends StatefulWidget {
  final Widget child;

  const AuthGate({
    super.key,
    required this.child,
  });

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> with WidgetsBindingObserver {
  bool _authenticated = false;
  bool _checking = true;

  bool get _isDark =>
      Hive.box(HiveBoxes.settings).get('is_dark', defaultValue: true);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _authenticate();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _authenticate();
    }
  }

  Future<void> _authenticate() async {
    setState(() => _checking = true);

    final success = await DeviceAuth.authenticate(
      reason: 'Authenticate to access your cards',
    );

    if (!mounted) return;
    setState(() {
      _authenticated = success;
      _checking = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AddCardMaterialTokens(_isDark);

    if (_checking) {
      return Scaffold(
        backgroundColor: tokens.surface,
        body: Center(
          child: CircularProgressIndicator(color: tokens.primary),
        ),
      );
    }

    if (!_authenticated) {
      return Scaffold(
        backgroundColor: tokens.surface,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: tokens.primaryContainer,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Icon(
                    CupertinoIcons.lock_shield_fill,
                    color: tokens.onPrimaryContainer,
                    size: 34,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Authentication required',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.roboto(
                    color: tokens.onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Unlock to access your saved cards.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.roboto(
                    color: tokens.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: FilledButton(
                    onPressed: _authenticate,
                    style: FilledButton.styleFrom(
                      backgroundColor: tokens.primary,
                      foregroundColor: tokens.onPrimary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: tokens.pillRadius,
                      ),
                    ),
                    child: Text(
                      'Unlock',
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

    return widget.child;
  }
}
