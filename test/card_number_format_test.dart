import 'package:flutter_test/flutter_test.dart';
import 'package:swallet/models/card_network.dart';
import 'package:swallet/utils/card_network_detector.dart';
import 'package:swallet/utils/card_number_format.dart';

void main() {
  test('formats Amex numbers as 4-6-5 and caps at 15 digits', () {
    expect(CardNetworkDetector.detect('34'), CardNetwork.amex);
    expect(CardNetworkDetector.detect('37'), CardNetwork.amex);
    expect(
      CardNumberFormat.format('3782822463100059'),
      '3782 822463 10005',
    );
    expect(CardNumberFormat.maxLengthForNumber('3782822463100059'), 15);
  });

  test('keeps standard card numbers as 4-4-4-4', () {
    expect(
      CardNumberFormat.format('4111111111111111'),
      '4111 1111 1111 1111',
    );
    expect(CardNumberFormat.maxLengthForNumber('4111111111111111'), 16);
  });

  test('uses a 4 digit CID length for Amex only', () {
    expect(CardNumberFormat.cvvLengthForNetwork(CardNetwork.amex), 4);
    expect(CardNumberFormat.cvvLengthForNetwork(CardNetwork.visa), 3);
  });
}
