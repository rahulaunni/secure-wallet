import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swallet/widgets/card/secure_reveal_wrapper.dart';

void main() {
  testWidgets('revealed card auto-locks when removed from the tree',
      (tester) async {
    var autoLocked = false;

    await tester.pumpWidget(
      MaterialApp(
        home: SecureRevealWrapper(
          revealed: true,
          onAutoLock: () => autoLocked = true,
          child: const SizedBox(width: 120, height: 80),
        ),
      ),
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: SizedBox.shrink(),
      ),
    );
    await tester.pump();

    expect(autoLocked, isTrue);
  });
}
