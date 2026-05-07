import 'package:flutter/material.dart';
import 'package:swallet/theme/swallet_theme.dart';
import 'package:swallet/widgets/add_card/add_card_material_tokens.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
        children: ['Credit', 'Debit'].map((type) {
          final selected = value == type;

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Material(
                color: selected ? tokens.primaryContainer : Colors.transparent,
                borderRadius: BorderRadius.circular(innerRadius),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => onChanged(type),
                  borderRadius: BorderRadius.circular(innerRadius),
                  child: Center(
                    child: Text(
                      type,
                      textAlign: TextAlign.center,
                      style: SwalletText.bodyMedium.copyWith(
                        color: selected
                            ? tokens.onPrimaryContainer
                            : tokens.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
