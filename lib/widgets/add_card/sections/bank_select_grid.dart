import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../data/bank_assets.dart';
import '../../../../../utils/bank_asset_resolver.dart';
import 'package:swallet/widgets/add_card/add_card_material_tokens.dart';
import '../widgets/bank_grid_item.dart';

class BankSelectGrid extends StatelessWidget {
  final ScrollController controller;
  final void Function(String bankCid) onBankSelected;
  final List<String> banks;
  final String searchQuery;

  const BankSelectGrid({
    super.key,
    required this.controller,
    required this.onBankSelected,
    this.banks = BankAssets.supportedBanks,
    this.searchQuery = '',
  });

  @override
  Widget build(BuildContext context) {
    final query = searchQuery.trim().toLowerCase();
    final visibleBanks = query.isEmpty
        ? banks
        : banks
            .where(
              (bank) => BankAssetResolver.displayName(bank)
                  .toLowerCase()
                  .contains(query),
            )
            .toList(growable: false);

    if (visibleBanks.isEmpty) {
      return ListView(
        controller: controller,
        padding: const EdgeInsets.fromLTRB(0, 12, 0, 32),
        physics: const ClampingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        children: [
          _NoBanksFound(searchQuery: searchQuery),
          const SizedBox(height: 10),
          BankGridItem(
            bankCid: BankAssets.otherBankId,
            onTap: () => onBankSelected(BankAssets.otherBankId),
          ),
        ],
      );
    }

    return ListView.separated(
      controller: controller,
      padding: const EdgeInsets.fromLTRB(0, 4, 0, 32),
      physics: const ClampingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      itemCount: visibleBanks.length + 1,
      separatorBuilder: (_, __) => const SizedBox(height: 2),
      itemBuilder: (context, index) {
        if (index == visibleBanks.length) {
          return BankGridItem(
            bankCid: BankAssets.otherBankId,
            onTap: () => onBankSelected(BankAssets.otherBankId),
          );
        }

        final cid = visibleBanks[index];

        return BankGridItem(
          bankCid: cid,
          onTap: () => onBankSelected(cid),
        );
      },
    );
  }
}

class _NoBanksFound extends StatelessWidget {
  final String searchQuery;

  const _NoBanksFound({
    required this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tokens = AddCardMaterialTokens(isDark);
    final query = searchQuery.trim();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        decoration: BoxDecoration(
          color: tokens.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          children: [
            Icon(
              CupertinoIcons.search_circle,
              color: tokens.onSurfaceVariant,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                query.isEmpty
                    ? 'No banks found'
                    : 'No banks found for "$query"',
                style: GoogleFonts.roboto(
                  color: tokens.onSurfaceVariant,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
