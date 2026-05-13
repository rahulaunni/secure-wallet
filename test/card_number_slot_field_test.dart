import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swallet/widgets/add_card/sections/widgets/card_number_slot_field.dart';

void main() {
  Future<void> pumpField(
    WidgetTester tester, {
    String initialValue = '',
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CardNumberSlotField(
            isDark: false,
            initialValue: initialValue,
            onChanged: (_) {},
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('shows detected network logo in card number field',
      (tester) async {
    await pumpField(tester);

    final field = find.byType(TextField);

    await tester.enterText(field, '4111111111111111');
    await tester.pump();
    expect(
      tester.widgetList<SvgPicture>(find.byType(SvgPicture)).last.bytesLoader,
      isA<SvgAssetLoader>().having((loader) => loader.assetName, 'assetName',
          'assets/images/networks/visa.svg'),
    );

    await tester.enterText(field, '5555555555554444');
    await tester.pump();
    expect(
      tester.widgetList<SvgPicture>(find.byType(SvgPicture)).last.bytesLoader,
      isA<SvgAssetLoader>().having((loader) => loader.assetName, 'assetName',
          'assets/images/networks/mastercard.svg'),
    );

    await tester.enterText(field, '6011111111111111');
    await tester.pump();
    expect(
      tester.widgetList<SvgPicture>(find.byType(SvgPicture)).last.bytesLoader,
      isA<SvgAssetLoader>().having((loader) => loader.assetName, 'assetName',
          'assets/images/networks/rupay.svg'),
    );

    await tester.enterText(field, '6076281111111111');
    await tester.pump();
    expect(
      tester.widgetList<SvgPicture>(find.byType(SvgPicture)).last.bytesLoader,
      isA<SvgAssetLoader>().having((loader) => loader.assetName, 'assetName',
          'assets/images/networks/rupay.svg'),
    );

    await tester.enterText(field, '371449635398431');
    await tester.pump();
    expect(
      tester.widgetList<SvgPicture>(find.byType(SvgPicture)).last.bytesLoader,
      isA<SvgAssetLoader>().having((loader) => loader.assetName, 'assetName',
          'assets/images/networks/amex.svg'),
    );
  });
}
