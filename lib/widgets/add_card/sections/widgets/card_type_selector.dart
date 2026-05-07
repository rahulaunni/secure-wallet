import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:swallet/models/card_type.dart';
import 'package:swallet/theme/swallet_theme.dart';
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
    const outerRadius = 16.0;
    const innerPadding = 4.0;
    const innerRadius = outerRadius - innerPadding;

    return Container(
      height: 52,
      padding: const EdgeInsets.all(innerPadding),
      decoration: BoxDecoration(
        color: tokens.surfaceContainer,
        borderRadius: BorderRadius.circular(outerRadius),
      ),
      child: Row(
        children: [
          _CardTypeChip(
            label: 'Credit',
            icon: CupertinoIcons.creditcard,
            selected: selected == CardType.credit,
            tokens: tokens,
            radius: innerRadius,
            onTap: () => onChanged(CardType.credit),
          ),
          const SizedBox(width: 6),
          _CardTypeChip(
            label: 'Debit',
            icon: CupertinoIcons.creditcard_fill,
            selected: selected == CardType.debit,
            tokens: tokens,
            radius: innerRadius,
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
  final double radius;
  final VoidCallback onTap;

  const _CardTypeChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.tokens,
    required this.radius,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(radius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(radius),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            height: double.infinity,
            decoration: BoxDecoration(
              color: selected ? tokens.primaryContainer : Colors.transparent,
              borderRadius: BorderRadius.circular(radius),
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
                  style: SwalletText.bodyMedium.copyWith(
                    fontSize: 14,
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
