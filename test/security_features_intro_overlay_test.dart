import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swallet/theme/swallet_theme.dart';
import 'package:swallet/widgets/app_lock/security_features_intro_overlay.dart';

void main() {
  testWidgets('security intro walks through three trust slides and completes',
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

    expect(find.text('Hive encrypted vault'), findsOneWidget);
    expect(find.text('What if someone peeks at app storage?'), findsOneWidget);
    expect(find.text('They meet cipher soup, not your card number.'),
        findsOneWidget);
    expect(find.text('Next'), findsOneWidget);

    await tester.tap(
      find.byKey(
        const ValueKey('security_intro_primary_button_Hive encrypted vault'),
      ),
    );
    await tester.pump(const Duration(milliseconds: 320));
    expect(find.text('No internet required'), findsOneWidget);
    expect(find.text('Cable unplugged and Wi-Fi panicking?'), findsOneWidget);
    expect(find.text('Still fine. Swallet keeps your cards local.'),
        findsOneWidget);

    await tester.tap(
      find.byKey(
        const ValueKey('security_intro_primary_button_No internet required'),
      ),
    );
    await tester.pump(const Duration(milliseconds: 520));
    expect(find.text('Private unlock'), findsOneWidget);
    expect(find.text('Can anyone just open the vault?'), findsOneWidget);
    expect(find.text('Only after your PIN or device unlock says yes.'),
        findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);

    await tester.tap(
      find.byKey(
        const ValueKey('security_intro_primary_button_Private unlock'),
      ),
    );
    await tester.pump(const Duration(milliseconds: 120));

    expect(completed, isTrue);
    expect(tester.takeException(), isNull);
  });
}
