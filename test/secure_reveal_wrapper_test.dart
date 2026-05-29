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

  testWidgets('revealed card auto-locks after scrolling outside the viewport',
      (tester) async {
    var autoLockCount = 0;
    var revealed = true;

    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) {
            return SizedBox(
              height: 320,
              child: ListView(
                children: [
                  const SizedBox(height: 24),
                  SecureRevealWrapper(
                    revealed: revealed,
                    onAutoLock: () {
                      autoLockCount++;
                      setState(() => revealed = false);
                    },
                    child: const SizedBox(width: 280, height: 164),
                  ),
                  const SizedBox(height: 900),
                ],
              ),
            );
          },
        ),
      ),
    );
    await tester.pump();

    await tester.drag(find.byType(ListView), const Offset(0, -520));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(autoLockCount, 1);
  });
}
