import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:swallet/models/card_type.dart';
import 'package:swallet/widgets/add_card/add_card_material_tokens.dart';

class CardTypeSelector extends StatelessWidget {
  final CardType selected;
  final ValueChanged<CardType> onChanged;
  final bool isDark;

  const CardTypeSelector({
    super.key,
    required this.selected,
    required this.onChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AddCardMaterialTokens(isDark);

    return Container(
      height: 52,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: tokens.surfaceContainerHigh,
        borderRadius: tokens.pillRadius,
      ),
      child: Row(
        children: [
          _CardTypeChip(
            label: 'Credit',
            icon: CupertinoIcons.creditcard,
            selected: selected == CardType.credit,
            tokens: tokens,
            onTap: () => onChanged(CardType.credit),
          ),
          const SizedBox(width: 6),
          _CardTypeChip(
            label: 'Debit',
            icon: CupertinoIcons.creditcard_fill,
            selected: selected == CardType.debit,
            tokens: tokens,
            onTap: () => onChanged(CardType.debit),
          ),
        ],
      ),
    );
  }
}

class _CardTypeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final AddCardMaterialTokens tokens;
  final VoidCallback onTap;

  const _CardTypeChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.tokens,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        borderRadius: tokens.pillRadius,
        child: InkWell(
          onTap: onTap,
          borderRadius: tokens.pillRadius,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            height: double.infinity,
            decoration: BoxDecoration(
              color: selected ? tokens.primaryContainer : Colors.transparent,
              borderRadius: tokens.pillRadius,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedScale(
                  scale: selected ? 1.0 : 0.92,
                  duration: const Duration(milliseconds: 180),
                  child: Icon(
                    icon,
                    size: 20,
                    color: selected
                        ? tokens.onPrimaryContainer
                        : tokens.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected
                        ? tokens.onPrimaryContainer
                        : tokens.onSurfaceVariant,
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
