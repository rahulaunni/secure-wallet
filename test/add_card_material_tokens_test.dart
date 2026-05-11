import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swallet/widgets/add_card/add_card_material_tokens.dart';

void main() {
  test('light sheet tokens match the security storage palette', () {
    const tokens = AddCardMaterialTokens(false);

    expect(tokens.surface, const Color(0xFFF5F5F5));
    expect(tokens.surfaceContainer, const Color(0xFFEDEDED));
    expect(tokens.outlineVariant, const Color(0xFFDADADA));
    expect(tokens.onSurfaceVariant, const Color(0xFF9A9DA5));
    expect(tokens.primary, const Color(0xFF2F6BFF));
    expect(tokens.onPrimary, Colors.white);
    expect(tokens.segmentedSelected, const Color(0xFF2F6BFF));
    expect(tokens.onSegmentedSelected, Colors.white);
  });
}
