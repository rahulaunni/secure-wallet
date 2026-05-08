import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:swallet/constants/card_visuals.dart';
import 'package:swallet/data/bank_assets.dart';
import 'package:swallet/widgets/card/creative_bank_pattern_painter.dart';

const fixedReferenceMotifs = {
  'axis': CreativeBankPatternMotif.figmaPurpleOrbs,
  'hdfc': CreativeBankPatternMotif.figmaCoralDiagonals,
  'bandhan': CreativeBankPatternMotif.figmaBlueBubbles,
  'bank_of_baroda': CreativeBankPatternMotif.figmaMintChevrons,
  'bank_of_india': CreativeBankPatternMotif.figmaVioletArcs,
  'bank_of_maharashtra': CreativeBankPatternMotif.figmaLimeSlashes,
  'idbi': CreativeBankPatternMotif.figmaEmeraldBlocks,
  'dcb': CreativeBankPatternMotif.figmaNoirRings,
  'indusind': CreativeBankPatternMotif.figmaBronzeArcs,
  'csb': CreativeBankPatternMotif.figmaGoldSplit,
  'idfc': CreativeBankPatternMotif.figmaSoftVerticalStripes,
  'kotak': CreativeBankPatternMotif.figmaRedLiquid,
};

void main() {
  test('one creative card overlay pattern is assigned to each Indian bank', () {
    expect(CardVisuals.creativePatternCount, BankAssets.supportedBanks.length);
  });

  test('every supported Indian bank has a creative overlay pattern', () {
    final missing = BankAssets.supportedBanks
        .where((bankId) => !CardVisuals.hasCreativePatternForBank(bankId))
        .toList();

    expect(missing, isEmpty);
  });

  test('the twelve reference SVG card motifs stay fixed', () {
    for (final entry in fixedReferenceMotifs.entries) {
      expect(
        CardVisuals.debugCreativeMotifForBank(entry.key),
        entry.value,
        reason: '${entry.key} should keep its imported reference motif',
      );
    }
  });

  test('the remaining bank overlay motifs are unique to each other', () {
    final remainingBanks = BankAssets.supportedBanks
        .where((bankId) => !fixedReferenceMotifs.containsKey(bankId))
        .toList();
    final motifs = {
      for (final bankId in remainingBanks)
        bankId: CardVisuals.debugCreativeMotifForBank(bankId)
    };
    final uniqueMotifs = motifs.values.toSet();

    expect(
      uniqueMotifs.length,
      remainingBanks.length,
      reason: 'Non-reference banks should not share overlay motifs: $motifs',
    );
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
