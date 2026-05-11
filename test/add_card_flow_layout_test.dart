import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:swallet/models/card_data.dart';
import 'package:swallet/screens/add_card_flow/add_card_flow_screen.dart';

void main() {
  testWidgets(
    'embedded add card flow renders inside a landscape tablet side pane',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(1200, 800)),
            child: Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: 420,
                height: 800,
                child: AddCardFlowScreen(
                  isDark: false,
                  embedded: true,
                  onCardAdded: (CardData _) {},
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Choose a bank'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'embedded back from a selected bank returns to the bank list',
    (tester) async {
      final controller = AddCardFlowController();
      var closed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, _) {
              if (didPop) return;
              if (!controller.handleBack()) {
                closed = true;
              }
            },
            child: AddCardFlowScreen(
              isDark: false,
              embedded: true,
              controller: controller,
              onClose: () => closed = true,
              onCardAdded: (CardData _) {},
            ),
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('AU Small Finance Bank'));
      await tester.pumpAndSettle();
      expect(find.text('Add payment card'), findsOneWidget);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(find.text('Choose a bank'), findsOneWidget);
      expect(closed, isFalse);
      expect(tester.takeException(), isNull);
    },
  );
}
