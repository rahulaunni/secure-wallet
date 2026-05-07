import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:swallet/widgets/add_card/add_card_material_tokens.dart';

class NfcScanButton extends StatelessWidget {
  final bool isDark;
  final bool isScanning;
  final VoidCallback onTap;

  const NfcScanButton({
    super.key,
    required this.isDark,
    required this.isScanning,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AddCardMaterialTokens(isDark);
    final bgColor =
        isScanning ? tokens.primaryContainer : tokens.surfaceContainer;
    final fgColor =
        isScanning ? tokens.onPrimaryContainer : tokens.onSurfaceVariant;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: tokens.pillRadius,
        boxShadow: [
          BoxShadow(
            color: tokens.primary.withValues(alpha: isScanning ? 0.16 : 0.06),
            blurRadius: isScanning ? 22 : 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: bgColor,
        borderRadius: tokens.pillRadius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: tokens.pillRadius,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: tokens.pillRadius,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  CupertinoIcons.radiowaves_right,
                  size: 18,
                  color: fgColor,
                ),
                const SizedBox(width: 8),
                Text(
                  isScanning ? 'Scanning' : 'Tap to add',
                  style: GoogleFonts.roboto(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: fgColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
