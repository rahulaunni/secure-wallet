import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:swallet/constants/card_visuals.dart';

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
    final colors = CardVisuals.editableGradientColorsForBank(
      'argentina__bbva_argentina',
    );

    expect(colors, const [
      Color(0xFF004481),
      Color(0xFF0045AF),
      Color(0xFF02182C),
    ]);
  });
}
