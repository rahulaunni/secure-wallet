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
    expect(CardNumberFormat.maxLengthForNumber('5555555555554444'), 16);
  });

  test('supports long Visa PAN format and valid lengths', () {
    expect(CardNetworkDetector.detect('4'), CardNetwork.visa);
    expect(CardNumberFormat.maxLengthForNumber('4'), 19);
    expect(
      CardNumberFormat.format('4123456789012345678'),
      '4123 4567 8901 2345 678',
    );
    expect(
      CardNumberFormat.isValidLengthForNetwork(
        network: CardNetwork.visa,
        length: 13,
      ),
      isTrue,
    );
    expect(
      CardNumberFormat.isValidLengthForNetwork(
        network: CardNetwork.visa,
        length: 19,
      ),
      isTrue,
    );
  });

  test('detects Mastercard 2-series and additional RuPay prefixes', () {
    expect(CardNetworkDetector.detect('2221'), CardNetwork.mastercard);
    expect(CardNetworkDetector.detect('2720'), CardNetwork.mastercard);
    expect(CardNumberFormat.maxLengthForNumber('2221000000000000'), 16);
    expect(CardNetworkDetector.detect('508'), CardNetwork.rupay);
    expect(CardNetworkDetector.detect('353'), CardNetwork.rupay);
    expect(CardNetworkDetector.detect('356'), CardNetwork.rupay);
    expect(CardNetworkDetector.detect('36'), CardNetwork.rupay);
    expect(CardNetworkDetector.detect('606'), CardNetwork.rupay);
    expect(CardNetworkDetector.detect('607'), CardNetwork.rupay);
    expect(CardNetworkDetector.detect('608'), CardNetwork.rupay);
    expect(CardNetworkDetector.detect('6521'), CardNetwork.rupay);
    expect(CardNetworkDetector.detect('6522'), CardNetwork.rupay);
    expect(CardNetworkDetector.detect('6529'), CardNetwork.rupay);
    expect(CardNetworkDetector.detect('6530'), CardNetwork.rupay);
    expect(CardNumberFormat.networkForNumber('607628'), CardNetwork.rupay);
    expect(CardNumberFormat.maxLengthForNumber('6529000000000000'), 16);
  });

  test('keeps Amex ahead of RuPay co-branded 3-series detection', () {
    expect(CardNetworkDetector.detect('34'), CardNetwork.amex);
    expect(CardNetworkDetector.detect('37'), CardNetwork.amex);
    expect(CardNetworkDetector.detect('3666063139224171'), CardNetwork.rupay);
  });

  test('uses a 4 digit CID length for Amex only', () {
    expect(CardNumberFormat.cvvLengthForNetwork(CardNetwork.amex), 4);
    expect(CardNumberFormat.cvvLengthForNetwork(CardNetwork.visa), 3);
  });
}
