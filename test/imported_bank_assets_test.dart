import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:swallet/constants/imported_card_gradients.dart';
import 'package:swallet/data/bank_assets.dart';
import 'package:swallet/utils/bank_asset_resolver.dart';
import 'package:swallet/widgets/bank/bank_logo.dart';

void main() {
  test('every imported bank has an explicit brand gradient', () {
    final bankIds = BankAssets.importedBanks.map((bank) => bank.id).toSet();

    expect(importedBankGradients.keys.toSet(), bankIds);

    for (final bank in BankAssets.importedBanks) {
      final colors = importedBankGradients[bank.id];

      expect(colors, isNotNull, reason: '${bank.id} needs a gradient');
      expect(
        colors,
        hasLength(3),
        reason:
            '${bank.id} should have exactly three editable card gradient stops',
      );
    }
  });

  test('Belgium list excludes AXA Bank after Crelan integration', () {
    expect(
      BankAssets.importedBanks.map((bank) => bank.id),
      isNot(contains('belgium__axa_bank')),
    );

    final belgium = BankAssets.supportedCountries.firstWhere(
      (country) => country.id == 'belgium',
    );
    expect(belgium.bankIds, isNot(contains('belgium__axa_bank')));
    expect(importedBankGradients, isNot(contains('belgium__axa_bank')));
  });

  test('imported bank gradients are unique per bank', () {
    final gradientKeys = <String>{};

    for (final bank in BankAssets.importedBanks) {
      final colors = importedBankGradients[bank.id]!;
      final key = colors.map((color) => color.toARGB32()).join(',');

      expect(
        gradientKeys.add(key),
        isTrue,
        reason: '${bank.id} should not share the exact same gradient',
      );
    }
  });

  test('every imported bank resolves to a local svg logo asset', () {
    for (final bank in BankAssets.importedBanks) {
      final logoPath = BankAssetResolver.logoPath(bank.id);

      expect(logoPath, isNotNull, reason: '${bank.id} needs a local logo path');
      expect(
        logoPath,
        endsWith('.svg'),
        reason: '${bank.id} should use a replaceable SVG asset',
      );
      expect(
        File(logoPath!).existsSync(),
        isTrue,
        reason: '$logoPath should exist for ${bank.id}',
      );
    }
  });

  testWidgets('generated svg logo assets can be loaded by the logo widget',
      (tester) async {
    await tester.pumpWidget(
      const BankLogo(
        bankCid: 'argentina__bbva_argentina',
        size: 28,
        width: 120,
      ),
    );

    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
