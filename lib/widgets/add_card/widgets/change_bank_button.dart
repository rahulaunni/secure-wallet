import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // ✅ Added Import

class CardTypeSelector extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const CardTypeSelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: ['Credit', 'Debit'].map((type) {
        final selected = value == type;

        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(type),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: selected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey.shade200,
              ),
              child: Text(
                type,
                textAlign: TextAlign.center,
                // ✅ UPDATED TO POPPINS
                style: GoogleFonts.poppins(
                  color: selected ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}