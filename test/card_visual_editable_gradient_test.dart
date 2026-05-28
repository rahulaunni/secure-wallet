import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:swallet/constants/card_visuals.dart';
import 'package:swallet/constants/imported_card_gradients.dart';

void main() {
  test('editable bank gradients use all three brand stops', () {
    final colors = CardVisuals.editableGradientColorsForBank(
      'au_small_finance',
    );

    expect(colors, const [
      Color(0xFF671773),
      Color(0xFFF47920),
      Color(0xFF360B3D),
    ]);
  });

  test('editable imported bank gradients use all three imported stops', () {
    const bankId = 'argentina__bbva_argentina';
    final colors = CardVisuals.editableGradientColorsForBank(
      bankId,
    );

    expect(colors, importedBankGradients[bankId]);
  });
}
