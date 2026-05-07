import 'package:flutter_test/flutter_test.dart';
import 'package:swallet/utils/adaptive_layout.dart';

void main() {
  test('uses compact phone canvas below medium width', () {
    expect(AdaptiveLayout.usesPhoneCanvas(390), isTrue);
    expect(AdaptiveLayout.cardPaneCountForWidth(390), 1);
  });

  test('keeps one full-size card when medium width cannot fit two panes', () {
    expect(AdaptiveLayout.usesPhoneCanvas(600), isFalse);
    expect(AdaptiveLayout.cardPaneCountForWidth(600), 1);
  });

  test('uses two full-size card panes for roomy foldable widths', () {
    expect(AdaptiveLayout.cardPaneCountForWidth(780), 2);
    expect(AdaptiveLayout.cardPaneCountForWidth(839), 2);
  });

  test('uses three card panes for expanded tablet widths', () {
    expect(AdaptiveLayout.cardPaneCountForWidth(840), 2);
    expect(AdaptiveLayout.cardPaneCountForWidth(1180), 3);
  });
}
