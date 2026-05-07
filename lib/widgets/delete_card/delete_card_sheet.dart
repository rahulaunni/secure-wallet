import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // ✅ Added Import

import '../../models/card_data.dart';
import 'delete_card_preview.dart';

class DeleteCardSheet extends StatelessWidget {
  final CardData card;
  final bool isDark;
  final VoidCallback onDeleteConfirmed;

  const DeleteCardSheet({
    super.key,
    required this.card,
    required this.isDark,
    required this.onDeleteConfirmed,
  });

  // =========================================================
  // 🔒 LOCKED CONSTANTS — MANUAL TUNING ALLOWED
  // =========================================================

  // Layout
  static const double sideInset = 16;
  static const double bottomInset = 16;
  static const double cornerRadius = 40;

  // Spacing
  static const double titleSpacing = 12;
  static const double descSpacing = 20;
  static const double previewSpacing = 24;
  static const double buttonSpacing = 12;

  // Buttons
  static const double deleteButtonHeight = 54;
  static const double cancelButtonHeight = 50;
  static const double buttonRadius = 16;

  // Colors — Light
  static const Color bgLight = Colors.white;
  static const Color titleLight = Color(0xFF111827);
  static const Color descLight = Color(0xFF6B7280);
  static const Color cancelBorderLight = Color(0xFFE5E7EB);
  static const Color cancelTextLight = Color(0xFF374151);

  // Colors — Dark
  static const Color bgDark = Color(0xFF1C1C1E);
  static const Color titleDark = Color(0xFFF9FAFB);
  static const Color descDark = Color(0xFF9CA3AF);
  static const Color cancelBorderDark = Color(0xFF3A3A3C);
  static const Color cancelTextDark = Color(0xFFE5E7EB);

  // Danger
  static const Color warningColor = Color(0xFFEF4444);
  static const Color deleteBg = Color(0xFFDC2626);
  static const Color deleteText = Colors.white;

  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        sideInset,
        0,
        sideInset,
        bottomInset,
      ),
      child: Material(
        color: isDark ? bgDark : bgLight,
        borderRadius: BorderRadius.circular(cornerRadius),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            20,
            24,
            20,
            24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ================= WARNING ICON =================
              const Icon(
                Icons.warning_rounded,
                size: 40,
                color: warningColor,
              ),

              const SizedBox(height: titleSpacing),

              // ================= TITLE =================
              Text(
                'Delete this card?',
                // ✅ UPDATED TO POPPINS
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? titleDark : titleLight,
                ),
              ),

              const SizedBox(height: 6),

              // ================= DESCRIPTION =================
              Text(
                'This action is permanent and cannot be undone.',
                textAlign: TextAlign.center,
                // ✅ UPDATED TO POPPINS
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: isDark ? descDark : descLight,
                ),
              ),

              const SizedBox(height: descSpacing),

              // ================= CARD PREVIEW =================
              DeleteCardPreview(
                card: card,
                isDark: isDark,
              ),

              const SizedBox(height: previewSpacing),

              // ================= DELETE BUTTON =================
              SizedBox(
                height: deleteButtonHeight,
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: deleteBg,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(buttonRadius),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    onDeleteConfirmed();
                  },
                  child: Text(
                    'Delete Card',
                    // ✅ UPDATED TO POPPINS
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: deleteText,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: buttonSpacing),

              // ================= CANCEL BUTTON =================
              SizedBox(
                height: cancelButtonHeight,
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(buttonRadius),
                    ),
                    side: BorderSide(
                      color: isDark
                          ? cancelBorderDark
                          : cancelBorderLight,
                    ),
                  ),
                  onPressed: () =>
                      Navigator.of(context).pop(),
                  child: Text(
                    'Cancel',
                    // ✅ UPDATED TO POPPINS
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? cancelTextDark
                          : cancelTextLight,
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
