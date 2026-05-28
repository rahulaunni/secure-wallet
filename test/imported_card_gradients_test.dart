import 'package:flutter_test/flutter_test.dart';
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
    final argentinaGradients = importedBankGradients.entries
        .where((entry) => entry.key.startsWith('argentina__'))
        .map((entry) => entry.value.map((color) => color.toARGB32()).join(','))
        .toSet();

    expect(argentinaGradients.length, 10);
    expect(
      importedBankGradients['argentina__bbva_argentina'],
      hasLength(3),
    );
    expect(importedBankGradients['argentina__banco_galicia'], hasLength(3));
    expect(importedBankGradients['argentina__brubank'], hasLength(3));
    expect(importedBankGradients['argentina__santander_r_o'], hasLength(3));
  });

  test('austria banks use distinct brand gradient colors', () {
    final austriaGradients = importedBankGradients.entries
        .where((entry) => entry.key.startsWith('austria__'))
        .map((entry) => entry.value.map((color) => color.toARGB32()).join(','))
        .toSet();

    expect(austriaGradients.length, 10);
    expect(importedBankGradients['austria__bank_austria'], hasLength(3));
    expect(importedBankGradients['austria__btv'], hasLength(3));
    expect(importedBankGradients['austria__hypo_vorarlberg'], hasLength(3));
    expect(importedBankGradients['austria__raiffeisen_bank'], hasLength(3));
  });
}
