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

  test('Colombia list uses DAVIbank after Scotiabank transition', () {
    final colombia = BankAssets.supportedCountries.firstWhere(
      (country) => country.id == 'colombia',
    );

    expect(colombia.bankIds, contains('colombia__davibank'));
    expect(colombia.bankIds, isNot(contains('colombia__scotiabank_colpatria')));
    expect(importedBankGradients, contains('colombia__davibank'));
    expect(
      importedBankGradients,
      isNot(contains('colombia__scotiabank_colpatria')),
    );
  });

  test('Denmark list uses AL Sydbank after AL and Vestjysk merger', () {
    final denmark = BankAssets.supportedCountries.firstWhere(
      (country) => country.id == 'denmark',
    );

    expect(denmark.bankIds, contains('denmark__sydbank'));
    expect(
      denmark.bankIds,
      isNot(contains('denmark__arbejdernes_landsbank')),
    );
    expect(denmark.bankIds, isNot(contains('denmark__vestjysk_bank')));

    final sydbank = BankAssets.importedBanks.firstWhere(
      (bank) => bank.id == 'denmark__sydbank',
    );
    expect(sydbank.name, 'AL Sydbank');

    expect(importedBankGradients, contains('denmark__sydbank'));
    expect(
      importedBankGradients,
      isNot(contains('denmark__arbejdernes_landsbank')),
    );
    expect(importedBankGradients, isNot(contains('denmark__vestjysk_bank')));
  });

  test('Netherlands list uses current consumer brands after mergers', () {
    final netherlands = BankAssets.supportedCountries.firstWhere(
      (country) => country.id == 'netherlands',
    );

    expect(netherlands.bankIds, contains('netherlands__asn_bank'));
    expect(netherlands.bankIds, isNot(contains('netherlands__de_volksbank')));
    expect(netherlands.bankIds, isNot(contains('netherlands__regiobank')));
    expect(netherlands.bankIds, isNot(contains('netherlands__sns_bank')));
    expect(netherlands.bankIds, isNot(contains('netherlands__aegon')));
    expect(netherlands.bankIds, isNot(contains('netherlands__nibc_bank')));

    final ing = BankAssets.importedBanks.firstWhere(
      (bank) => bank.id == 'netherlands__ing_group',
    );
    expect(ing.name, 'ING Bank');

    final knab = BankAssets.importedBanks.firstWhere(
      (bank) => bank.id == 'netherlands__knab',
    );
    expect(knab.name, 'Knab');

    expect(importedBankGradients, contains('netherlands__asn_bank'));
    expect(importedBankGradients, isNot(contains('netherlands__de_volksbank')));
    expect(importedBankGradients, isNot(contains('netherlands__regiobank')));
    expect(importedBankGradients, isNot(contains('netherlands__sns_bank')));
    expect(importedBankGradients, isNot(contains('netherlands__aegon')));
    expect(importedBankGradients, isNot(contains('netherlands__nibc_bank')));
  });

  test('Greece list uses CrediaBank after Attica and Pancreta merger', () {
    final greece = BankAssets.supportedCountries.firstWhere(
      (country) => country.id == 'greece',
    );

    expect(greece.bankIds, contains('greece__crediabank'));
    expect(greece.bankIds, isNot(contains('greece__attica_bank')));
    expect(greece.bankIds, isNot(contains('greece__pancreta_bank')));

    final crediaBank = BankAssets.importedBanks.firstWhere(
      (bank) => bank.id == 'greece__crediabank',
    );
    expect(crediaBank.name, 'CrediaBank');
    expect(crediaBank.website, 'https://www.crediabank.com');

    final aegeanBalticBank = BankAssets.importedBanks.firstWhere(
      (bank) => bank.id == 'greece__aegean_baltic_bank',
    );
    expect(aegeanBalticBank.website, 'https://aegeanbalticbank.com');

    final optimaBank = BankAssets.importedBanks.firstWhere(
      (bank) => bank.id == 'greece__optima_bank',
    );
    expect(optimaBank.website, 'https://www.optimabank.gr/en');

    expect(importedBankGradients, contains('greece__crediabank'));
    expect(importedBankGradients, isNot(contains('greece__attica_bank')));
    expect(importedBankGradients, isNot(contains('greece__pancreta_bank')));
  });

  test('Indonesia list follows top ten banks by total assets', () {
    final indonesia = BankAssets.supportedCountries.firstWhere(
      (country) => country.id == 'indonesia',
    );

    expect(indonesia.bankIds, [
      'indonesia__bank_mandiri',
      'indonesia__bri',
      'indonesia__bca',
      'indonesia__bni',
      'indonesia__bank_tabungan_negara',
      'indonesia__bank_syariah_indonesia',
      'indonesia__cimb_niaga',
      'indonesia__ocbc_nisp',
      'indonesia__permatabank',
      'indonesia__bank_danamon',
    ]);
    expect(indonesia.bankIds, isNot(contains('indonesia__bank_panin')));

    final expectedNames = {
      'indonesia__bri': 'Bank Rakyat Indonesia (BRI)',
      'indonesia__bca': 'Bank Central Asia (BCA)',
      'indonesia__bni': 'Bank Negara Indonesia (BNI)',
      'indonesia__bank_tabungan_negara': 'Bank Tabungan Negara (BTN)',
      'indonesia__bank_syariah_indonesia': 'Bank Syariah Indonesia (BSI)',
      'indonesia__cimb_niaga': 'Bank CIMB Niaga',
      'indonesia__ocbc_nisp': 'Bank OCBC Indonesia',
      'indonesia__permatabank': 'Permata Bank',
    };

    for (final entry in expectedNames.entries) {
      final bank = BankAssets.importedBanks.firstWhere(
        (bank) => bank.id == entry.key,
      );
      expect(bank.name, entry.value);
    }

    expect(importedBankGradients, contains('indonesia__bank_tabungan_negara'));
    expect(importedBankGradients, isNot(contains('indonesia__bank_panin')));
  });

  test('Israel list keeps Pepper alongside licensed banks', () {
    final israel = BankAssets.supportedCountries.firstWhere(
      (country) => country.id == 'israel',
    );

    expect(israel.bankIds, contains('israel__bank_massad'));
    expect(israel.bankIds, contains('israel__esh_bank'));
    expect(israel.bankIds, contains('israel__mercantile'));
    expect(israel.bankIds, contains('israel__bank_yahav'));
    expect(israel.bankIds, contains('israel__pepper'));

    final massad = BankAssets.importedBanks.firstWhere(
      (bank) => bank.id == 'israel__bank_massad',
    );
    expect(massad.website, 'https://www.bankmassad.co.il');

    final esh = BankAssets.importedBanks.firstWhere(
      (bank) => bank.id == 'israel__esh_bank',
    );
    expect(esh.website, 'https://esh.com/en/home');

    expect(importedBankGradients, contains('israel__bank_massad'));
    expect(importedBankGradients, contains('israel__esh_bank'));
    expect(importedBankGradients, contains('israel__pepper'));
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
