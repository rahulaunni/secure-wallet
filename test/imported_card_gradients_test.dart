import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:swallet/constants/imported_card_gradients.dart';
import 'package:swallet/data/bank_assets.dart';

void main() {
  test('every imported bank has an explicit card gradient', () {
    final missing = BankAssets.importedBanks
        .where((bank) => !importedBankGradients.containsKey(bank.id))
        .map((bank) => bank.id)
        .toList();

    expect(missing, isEmpty);
  });

  test('argentina banks use distinct brand gradient colors', () {
    expect(
      importedBankGradients['argentina__bbva_argentina']!.first,
      const Color(0xFF004481),
    );
    expect(
      importedBankGradients['argentina__banco_galicia']!.first,
      const Color(0xFFFA6400),
    );
    expect(
      importedBankGradients['argentina__brubank']!.first,
      const Color(0xFF614AD9),
    );
    expect(
      importedBankGradients['argentina__santander_r_o']!.first,
      const Color(0xFFEC0000),
    );

    final argentinaGradients = importedBankGradients.entries
        .where((entry) => entry.key.startsWith('argentina__'))
        .map((entry) => entry.value.map((color) => color.toARGB32()).join(','))
        .toSet();

    expect(argentinaGradients.length, 10);
  });

  test('austria banks use distinct brand gradient colors', () {
    expect(
      importedBankGradients['austria__bank_austria']!.first,
      const Color(0xFFE2001A),
    );
    expect(
      importedBankGradients['austria__btv']!.first,
      const Color(0xFF0095B7),
    );
    expect(
      importedBankGradients['austria__hypo_vorarlberg']!.first,
      const Color(0xFF0079C2),
    );
    expect(
      importedBankGradients['austria__raiffeisen_bank']!.first,
      const Color(0xFFFFD400),
    );

    final austriaGradients = importedBankGradients.entries
        .where((entry) => entry.key.startsWith('austria__'))
        .map((entry) => entry.value.map((color) => color.toARGB32()).join(','))
        .toSet();

    expect(austriaGradients.length, 10);
  });
}
