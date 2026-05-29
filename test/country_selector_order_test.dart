import 'package:flutter_test/flutter_test.dart';
import 'package:swallet/data/bank_assets.dart' show BankAssets, BankCountry;

void main() {
  test('supported countries are sorted alphabetically', () {
    final countryNames =
        BankAssets.supportedCountries.map((country) => country.name).toList();
    final sortedNames = [...countryNames]..sort((a, b) {
        return a.toLowerCase().compareTo(b.toLowerCase());
      });

    expect(countryNames, sortedNames);
  });

  test('india is the default add card country', () {
    expect(BankAssets.defaultCountryId, 'in');
    expect(
      BankAssets.supportedCountries,
      anyElement(
        predicate<BankCountry>(
          (country) => country.id == BankAssets.defaultCountryId,
        ),
      ),
    );
  });
}
