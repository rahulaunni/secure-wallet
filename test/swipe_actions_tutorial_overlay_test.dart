import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swallet/theme/swallet_theme.dart';
import 'package:swallet/widgets/home/swipe_actions_tutorial_overlay.dart';

void main() {
  testWidgets('swipe actions tutorial shows animation copy and completes',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 740));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    var completed = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: SwalletTheme.theme(false),
        home: SwipeActionsTutorialOverlay(
          isDark: false,
          onDone: () => completed = true,
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Swipe left'), findsOneWidget);
    expect(find.text('Reveal Edit and Delete for each saved card.'),
        findsOneWidget);
    expect(find.byIcon(Icons.edit_rounded), findsOneWidget);
    expect(find.byIcon(Icons.delete_rounded), findsOneWidget);

    await tester.tap(find.text('OK'));
    await tester.pump();

    expect(completed, isTrue);
    expect(tester.takeException(), isNull);
  });
}
