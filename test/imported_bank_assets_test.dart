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

  test('foreign bank country logos reuse the shared brand asset', () {
    const sharedLogos = {
      'assets/icons/banks/argentina/bbva_argentina.svg':
          'assets/icons/banks/spain/bbva.svg',
      'assets/icons/banks/colombia/bbva_colombia.svg':
          'assets/icons/banks/spain/bbva.svg',
      'assets/icons/banks/mexico/bbva_m_xico.svg':
          'assets/icons/banks/spain/bbva.svg',
      'assets/icons/banks/peru/bbva_per.svg':
          'assets/icons/banks/spain/bbva.svg',
      'assets/icons/banks/argentina/santander_r_o.svg':
          'assets/icons/banks/spain/banco_santander.svg',
      'assets/icons/banks/brazil/banco_santander_brasil.svg':
          'assets/icons/banks/spain/banco_santander.svg',
      'assets/icons/banks/chile/santander_chile.svg':
          'assets/icons/banks/spain/banco_santander.svg',
      'assets/icons/banks/mexico/santander_m_xico.svg':
          'assets/icons/banks/spain/banco_santander.svg',
      'assets/icons/banks/poland/santander_bank_polska.svg':
          'assets/icons/banks/spain/banco_santander.svg',
      'assets/icons/banks/portugal/santander_totta.svg':
          'assets/icons/banks/spain/banco_santander.svg',
      'assets/icons/banks/united_kingdom/santander_uk.svg':
          'assets/icons/banks/spain/banco_santander.svg',
      'assets/icons/banks/chile/scotiabank_chile.svg':
          'assets/icons/banks/canada/scotiabank.svg',
      'assets/icons/banks/mexico/scotiabank_m_xico.svg':
          'assets/icons/banks/canada/scotiabank.svg',
      'assets/icons/banks/peru/scotiabank_per.svg':
          'assets/icons/banks/canada/scotiabank.svg',
      'assets/icons/banks/mexico/hsbc_m_xico.svg':
          'assets/icons/banks/united_kingdom/hsbc_uk.svg',
      'assets/icons/banks/australia/hsbc_australia.svg':
          'assets/icons/banks/united_kingdom/hsbc_uk.svg',
      'assets/icons/banks/egypt/hsbc_egypt.svg':
          'assets/icons/banks/united_kingdom/hsbc_uk.svg',
      'assets/icons/banks/malaysia/hsbc_malaysia.svg':
          'assets/icons/banks/united_kingdom/hsbc_uk.svg',
      'assets/icons/banks/philippines/hsbc_philippines.svg':
          'assets/icons/banks/united_kingdom/hsbc_uk.svg',
      'assets/icons/banks/qatar/hsbc_qatar.svg':
          'assets/icons/banks/united_kingdom/hsbc_uk.svg',
      'assets/icons/banks/singapore/hsbc_sg.svg':
          'assets/icons/banks/united_kingdom/hsbc_uk.svg',
      'assets/icons/banks/uae/hsbc_uae.svg':
          'assets/icons/banks/united_kingdom/hsbc_uk.svg',
      'assets/icons/banks/vietnam/hsbc_vietnam.svg':
          'assets/icons/banks/united_kingdom/hsbc_uk.svg',
      'assets/icons/banks/india/standard_chartered_bank.svg':
          'assets/icons/banks/united_kingdom/standard_chartered.svg',
      'assets/icons/banks/kenya/standard_chartered_ke.svg':
          'assets/icons/banks/united_kingdom/standard_chartered.svg',
      'assets/icons/banks/malaysia/standard_chartered_malaysia.svg':
          'assets/icons/banks/united_kingdom/standard_chartered.svg',
      'assets/icons/banks/oman/standard_chartered_oman.svg':
          'assets/icons/banks/united_kingdom/standard_chartered.svg',
      'assets/icons/banks/qatar/standard_chartered_qatar.svg':
          'assets/icons/banks/united_kingdom/standard_chartered.svg',
      'assets/icons/banks/singapore/standard_chartered_sg.svg':
          'assets/icons/banks/united_kingdom/standard_chartered.svg',
      'assets/icons/banks/uae/standard_chartered_uae.svg':
          'assets/icons/banks/united_kingdom/standard_chartered.svg',
      'assets/icons/banks/vietnam/standard_chartered_vietnam.svg':
          'assets/icons/banks/united_kingdom/standard_chartered.svg',
      'assets/icons/banks/india/citibank.svg':
          'assets/icons/banks/united_states/citibank.svg',
      'assets/icons/banks/singapore/citibank_sg.svg':
          'assets/icons/banks/united_states/citibank.svg',
      'assets/icons/banks/uae/citibank_uae.svg':
          'assets/icons/banks/united_states/citibank.svg',
      'assets/icons/banks/united_states/bmo_us.svg':
          'assets/icons/banks/canada/bmo.svg',
      'assets/icons/banks/australia/bank_of_china_australia.svg':
          'assets/icons/banks/china/bank_of_china.svg',
      'assets/icons/banks/malaysia/bank_of_china_malaysia.svg':
          'assets/icons/banks/china/bank_of_china.svg',
      'assets/icons/banks/new_zealand/bank_of_china_nz.svg':
          'assets/icons/banks/china/bank_of_china.svg',
      'assets/icons/banks/singapore/bank_of_china_singapore.svg':
          'assets/icons/banks/china/bank_of_china.svg',
      'assets/icons/banks/thailand/bank_of_china_thailand.svg':
          'assets/icons/banks/china/bank_of_china.svg',
      'assets/icons/banks/new_zealand/anz_nz.svg':
          'assets/icons/banks/australia/anz.svg',
      'assets/icons/banks/new_zealand/westpac_nz.svg':
          'assets/icons/banks/australia/westpac.svg',
      'assets/icons/banks/new_zealand/rabobank_nz.svg':
          'assets/icons/banks/netherlands/rabobank.svg',
      'assets/icons/banks/ireland/bunq_ireland.svg':
          'assets/icons/banks/netherlands/bunq.svg',
      'assets/icons/banks/ireland/n26_ireland.svg':
          'assets/icons/banks/germany/n26.svg',
      'assets/icons/banks/ireland/revolut_ireland.svg':
          'assets/icons/banks/united_kingdom/revolut.svg',
      'assets/icons/banks/finland/danske_bank_finland.svg':
          'assets/icons/banks/denmark/danske_bank.svg',
      'assets/icons/banks/finland/handelsbanken_finland.svg':
          'assets/icons/banks/sweden/handelsbanken.svg',
      'assets/icons/banks/norway/nordea_norway.svg':
          'assets/icons/banks/finland/nordea_finland.svg',
      'assets/icons/banks/sweden/nordea_sweden.svg':
          'assets/icons/banks/finland/nordea_finland.svg',
      'assets/icons/banks/czech_republic/raiffeisenbank_cz.svg':
          'assets/icons/banks/austria/raiffeisen_bank.svg',
      'assets/icons/banks/hungary/raiffeisen_hungary.svg':
          'assets/icons/banks/austria/raiffeisen_bank.svg',
      'assets/icons/banks/hungary/erste_bank_hungary.svg':
          'assets/icons/banks/austria/erste_group.svg',
      'assets/icons/banks/czech_republic/unicredit_bank_cr.svg':
          'assets/icons/banks/italy/unicredit.svg',
      'assets/icons/banks/hungary/unicredit_hungary.svg':
          'assets/icons/banks/italy/unicredit.svg',
      'assets/icons/banks/belgium/bnp_paribas_fortis.svg':
          'assets/icons/banks/france/bnp_paribas.svg',
      'assets/icons/banks/poland/bnp_paribas_poland.svg':
          'assets/icons/banks/france/bnp_paribas.svg',
      'assets/icons/banks/egypt/credit_agricole_egypt.svg':
          'assets/icons/banks/france/cr_dit_agricole.svg',
      'assets/icons/banks/poland/credit_agricole_poland.svg':
          'assets/icons/banks/france/cr_dit_agricole.svg',
      'assets/icons/banks/morocco/cr_dit_agricole_du_maroc.svg':
          'assets/icons/banks/france/cr_dit_agricole.svg',
      'assets/icons/banks/morocco/soci_t_g_n_rale_maroc.svg':
          'assets/icons/banks/france/soci_t_g_n_rale.svg',
      'assets/icons/banks/argentina/icbc_argentina.svg':
          'assets/icons/banks/china/icbc.svg',
      'assets/icons/banks/singapore/icbc_singapore.svg':
          'assets/icons/banks/china/icbc.svg',
      'assets/icons/banks/oman/bank_of_baroda.svg':
          'assets/icons/banks/india/bank_of_baroda.svg',
      'assets/icons/banks/uae/bank_of_baroda_uae.svg':
          'assets/icons/banks/india/bank_of_baroda.svg',
      'assets/icons/banks/oman/state_bank_of_india.svg':
          'assets/icons/banks/india/state_bank_of_india.svg',
      'assets/icons/banks/oman/first_abu_dhabi_bank.svg':
          'assets/icons/banks/uae/first_abu_dhabi_bank.svg',
      'assets/icons/banks/indonesia/ocbc_nisp.svg':
          'assets/icons/banks/singapore/ocbc_bank.svg',
      'assets/icons/banks/malaysia/ocbc_malaysia.svg':
          'assets/icons/banks/singapore/ocbc_bank.svg',
      'assets/icons/banks/indonesia/cimb_niaga.svg':
          'assets/icons/banks/malaysia/cimb.svg',
      'assets/icons/banks/thailand/cimb_thai.svg':
          'assets/icons/banks/malaysia/cimb.svg',
      'assets/icons/banks/singapore/maybank_sg.svg':
          'assets/icons/banks/malaysia/maybank.svg',
      'assets/icons/banks/malaysia/uob_malaysia.svg':
          'assets/icons/banks/singapore/uob.svg',
      'assets/icons/banks/thailand/uob_thailand.svg':
          'assets/icons/banks/singapore/uob.svg',
      'assets/icons/banks/vietnam/uob_vietnam.svg':
          'assets/icons/banks/singapore/uob.svg',
      'assets/icons/banks/vietnam/shinhan_bank_vietnam.svg':
          'assets/icons/banks/south_korea/shinhan_bank.svg',
      'assets/icons/banks/portugal/bankinter_portugal.svg':
          'assets/icons/banks/spain/bankinter.svg',
      'assets/icons/banks/peru/banco_falabella_per.svg':
          'assets/icons/banks/chile/banco_falabella.svg',
    };

    for (final entry in sharedLogos.entries) {
      final countryLogo = File(entry.key);
      final sharedLogo = File(entry.value);

      expect(countryLogo.existsSync(), isTrue, reason: '${entry.key} exists');
      expect(sharedLogo.existsSync(), isTrue, reason: '${entry.value} exists');
      expect(
        countryLogo.readAsBytesSync(),
        sharedLogo.readAsBytesSync(),
        reason: '${entry.key} should reuse ${entry.value}',
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
