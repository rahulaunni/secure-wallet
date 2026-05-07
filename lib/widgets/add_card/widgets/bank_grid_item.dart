import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:swallet/theme/swallet_theme.dart';
import 'package:swallet/utils/bank_asset_resolver.dart';
import 'package:swallet/widgets/add_card/add_card_material_tokens.dart';

class BankGridItem extends StatelessWidget {
  final String bankCid;
  final VoidCallback onTap;

  const BankGridItem({
    super.key,
    required this.bankCid,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tokens = AddCardMaterialTokens(isDark);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: tokens.surfaceContainer,
        shape: RoundedRectangleBorder(
          borderRadius: tokens.controlRadius,
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: tokens.controlRadius,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: tokens.primaryContainer,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: tokens.primary.withValues(alpha: 0.24),
                    ),
                  ),
                  child: Icon(
                    CupertinoIcons.building_2_fill,
                    size: 19,
                    color: tokens.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    BankAssetResolver.displayName(bankCid),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: SwalletText.bodyMedium.copyWith(
                      fontSize: 15,
                      height: 1.2,
                      color: tokens.onSurface,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  CupertinoIcons.chevron_right,
                  size: 22,
                  color: tokens.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
