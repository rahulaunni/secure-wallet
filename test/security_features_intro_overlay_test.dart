import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swallet/theme/swallet_theme.dart';
import 'package:swallet/widgets/app_lock/security_features_intro_overlay.dart';

void main() {
  testWidgets('security intro shows three trust features and completes',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 740));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    var completed = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: SwalletTheme.theme(false),
        home: SecurityFeaturesIntroOverlay(
          isDark: false,
          onDone: () => completed = true,
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Built for private card storage'), findsOneWidget);
    expect(find.text('Offline by design'), findsOneWidget);
    expect(find.text('Hive encrypted vault'), findsOneWidget);
    expect(find.text('Private unlock'), findsOneWidget);

    await tester.tap(find.text('Continue'));
    await tester.pump();

    expect(completed, isTrue);
    expect(tester.takeException(), isNull);
  });
}
