import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:swallet/constants/card_visuals.dart';
import 'package:swallet/data/bank_assets.dart';

void main() {
  test('at least fifty creative card overlay patterns are available', () {
    expect(CardVisuals.creativePatternCount, greaterThanOrEqualTo(50));
  });

  test('every supported Indian bank has a creative overlay pattern', () {
    final missing = BankAssets.supportedBanks
        .where((bankId) => !CardVisuals.hasCreativePatternForBank(bankId))
        .toList();

    expect(missing, isEmpty);
  });

  test('key Indian bank cards use brand-led visual palettes', () {
    final axis = CardVisuals.forBank('axis').gradient as LinearGradient;
    final bandhan = CardVisuals.forBank('bandhan').gradient as LinearGradient;
    final maharashtra =
        CardVisuals.forBank('bank_of_maharashtra').gradient as LinearGradient;

    expect(axis.colors, const [
      Color(0xFFAE275F),
      Color(0xFF7C123F),
      Color(0xFF3F071F),
    ]);
    expect(bandhan.colors, const [
      Color(0xFF0A3152),
      Color(0xFFA71E1F),
      Color(0xFFEF3B23),
    ]);
    expect(maharashtra.colors, const [
      Color(0xFF0E88D3),
      Color(0xFF075E9B),
    ]);
  });

  test('every supported Indian bank resolves to a multi-stop brand gradient',
      () {
    for (final bankId in BankAssets.supportedBanks) {
      final gradient = CardVisuals.forBank(bankId).gradient as LinearGradient;

      expect(
        gradient.colors.length,
        greaterThanOrEqualTo(2),
        reason: '$bankId should have a resolved bank palette',
      );
    }
  });
}
