import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:swallet/widgets/add_card/add_card_material_tokens.dart';
import 'top_nav_constants.dart';

class AddChipButton extends StatelessWidget {
  final bool isDark;
  final VoidCallback onTap;

  const AddChipButton({
    super.key,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AddCardMaterialTokens(isDark);

    return Material(
      color: tokens.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(chipHeight / 2),
        side: BorderSide(
          color: tokens.outlineVariant.withValues(alpha: 0.45),
          width: chipBorderWidth,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: chipHeight,
          width: chipHeight,
          child: Center(
            child: Icon(
              CupertinoIcons.add,
              size: 22,
              color: tokens.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
