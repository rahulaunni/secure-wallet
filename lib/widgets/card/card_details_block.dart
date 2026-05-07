import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../constants/layout_constants.dart';

class CardDetailsBlock extends StatelessWidget {
  final String cardNumber;        // DISPLAY number
  final String rawCardNumber;     // FULL number for clipboard
  final String validThru;
  final String holderName;
  final String cvv;

  final bool showCvvToggle;
  final bool isCvvVisible;
  final VoidCallback onToggleCvv;

  const CardDetailsBlock({
    super.key,
    required this.cardNumber,
    required this.rawCardNumber,
    required this.validThru,
    required this.holderName,
    required this.cvv,
    required this.showCvvToggle,
    required this.isCvvVisible,
    required this.onToggleCvv,
  });

  void _showInlineCopiedToast(OverlayState overlay, RenderBox renderBox) {
    final position = renderBox.localToGlobal(Offset.zero);

    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (_) => Positioned(
        left: position.dx + renderBox.size.width / 2,
        top: position.dy - 36, // 👈 above card number
        child: Material(
          color: Colors.transparent,
          child: Transform.translate(
            offset: const Offset(-24, 0),
            child: AnimatedOpacity(
              opacity: 1,
              duration: const Duration(milliseconds: 150),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Copied',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(entry);

    Future.delayed(const Duration(milliseconds: 900), () {
      entry.remove();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ================= CARD NUMBER (Auto-Scaling) =================
        SizedBox(
          width: double.infinity, // 1. Occupy full available width
          child: FittedBox(
            // 2. Scale down ONLY if text is wider than the card
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            
            child: GestureDetector(
              onLongPress: () async {
                // 🔒 Only allow copy when revealed
                if (cardNumber.contains('*')) return;

                final overlay = Overlay.of(context);
                final renderBox = context.findRenderObject() as RenderBox;

                await Clipboard.setData(
                  ClipboardData(text: rawCardNumber),
                );

                // 📳 Haptic
                HapticFeedback.lightImpact();

                // 🟢 Inline toast
                _showInlineCopiedToast(overlay, renderBox);
              },
              child: Text(
                cardNumber,
                
                // 🔒 CRITICAL FIX: Force text to be one long line
                // This allows FittedBox to calculate the true width and shrink it.
                maxLines: 1, 
                softWrap: false, 
                overflow: TextOverflow.visible, 

                style: GoogleFonts.poppins(
                  fontSize: cardNumberFontSize, // Ideally ~22.0
                  letterSpacing: cardNumberLetterSpacing, // Ideally ~2.0-2.5
                  fontWeight: cardNumberFontWeight,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: numberToRowSpacing),

        // ================= VALID / THRU + DATE + CVV + PILL =================
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'VALID',
                  style: GoogleFonts.poppins(
                    fontSize: labelFontSize,
                    color: Colors.white70,
                    height: 1.0,
                  ),
                ),
                Text(
                  'THRU',
                  style: GoogleFonts.poppins(
                    fontSize: labelFontSize,
                    color: Colors.white70,
                    height: 1.0,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 6),
            Text(
              validThru,
              style: GoogleFonts.poppins(
                fontSize: valueFontSize,
                letterSpacing: valueLetterSpacing,
                fontWeight: valueFontWeight,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: detailsGroupSpacing),
            Text(
              'CVV ',
              style: GoogleFonts.poppins(
                fontSize: labelFontSize,
                color: Colors.white70,
              ),
            ),
            Text(
              cvv,
              style: GoogleFonts.poppins(
                fontSize: valueFontSize,
                letterSpacing: valueLetterSpacing,
                fontWeight: valueFontWeight,
                color: Colors.white,
              ),
            ),
            if (showCvvToggle) ...[
              const SizedBox(width: 8),
              _CvvPill(
                isOn: isCvvVisible,
                onTap: onToggleCvv,
              ),
            ],
          ],
        ),

        const SizedBox(height: rowToNameSpacing),

        // ================= HOLDER NAME =================
        Text(
          holderName.toUpperCase(),
          style: GoogleFonts.poppins(
            fontSize: holderNameFontSize,
            letterSpacing: holderNameLetterSpacing,
            fontWeight: holderNameFontWeight,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

// ================= CVV PILL =================

class _CvvPill extends StatelessWidget {
  final bool isOn;
  final VoidCallback onTap;

  const _CvvPill({
    required this.isOn,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isOn ? Colors.green : Colors.grey.shade700,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          isOn ? 'CVV ON' : 'CVV OFF',
          style: GoogleFonts.poppins(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
