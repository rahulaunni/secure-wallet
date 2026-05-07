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
}
