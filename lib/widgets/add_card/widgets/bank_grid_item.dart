import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

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

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: tokens.surfaceContainerHigh,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  CupertinoIcons.building_2_fill,
                  size: 19,
                  color: tokens.primary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  BankAssetResolver.displayName(bankCid),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.roboto(
                    fontSize: 15,
                    height: 1.2,
                    fontWeight: FontWeight.w600,
                    color: tokens.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                CupertinoIcons.chevron_right,
                size: 24,
                color: tokens.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
