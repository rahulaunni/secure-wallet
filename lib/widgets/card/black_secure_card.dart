import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // ✅ Added Import
import '../../constants/layout_constants.dart';

class BlackSecureCard extends StatelessWidget {
  final int remainingSeconds;

  // 🔒 Locked visuals (compiler-safe)
  static const double _blackCardRadius = 40;

  // Theme-aware colors (LOCAL, SAFE)
  static const Color _bgDark = Color(0xFF0E0E0E);
  static const Color _bgLight = Color(0xFF1A1A1A);

  static const Color _textDark = Colors.white;
  static const Color _textLight = Color(0xFFEAEAEA);

  const BlackSecureCard({
    super.key,
    required this.remainingSeconds,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark =
        Theme.of(context).brightness == Brightness.dark;

    final Color backgroundColor =
        isDark ? _bgDark : _bgLight;

    final Color textColor =
        isDark ? _textDark : _textLight;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius:
            BorderRadius.circular(_blackCardRadius),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SizedBox(
              height: secureRevealBarHeight,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 08),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Text(
                    'Securely locking in 00:${remainingSeconds.toString().padLeft(2, '0')}s',
                    // ✅ UPDATED TO POPPINS (Merges with existing style)
                    style: GoogleFonts.poppins(
                      textStyle: secureRevealTextStyle,
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      color: textColor,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
