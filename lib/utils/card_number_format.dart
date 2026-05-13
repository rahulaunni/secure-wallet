import 'package:swallet/models/card_network.dart';
import 'package:swallet/utils/card_network_detector.dart';

class CardNumberFormat {
  static const String standardTemplate = '**** **** **** ****';
  static const String longTemplate = '**** **** **** **** ***';
  static const String amexTemplate = '**** ****** *****';

  static String digitsOnly(String input) {
    return input.replaceAll(RegExp(r'[^0-9]'), '');
  }

  static bool isAmexNumber(String input) {
    final digits = digitsOnly(input);
    return digits.startsWith('34') || digits.startsWith('37');
  }

  static CardNetwork? networkForNumber(String input) {
    return CardNetworkDetector.detect(input);
  }

  static int maxLengthForNumber(String input) {
    return maxLengthForNetwork(networkForNumber(input));
  }

  static int maxLengthForNetwork(CardNetwork? network) {
    return switch (network) {
      CardNetwork.amex => 15,
      CardNetwork.mastercard || CardNetwork.rupay => 16,
      CardNetwork.visa => 19,
      _ => 19,
    };
  }

  static bool isValidLengthForNetwork({
    required CardNetwork? network,
    required int length,
  }) {
    return switch (network) {
      CardNetwork.amex => length == 15,
      CardNetwork.mastercard || CardNetwork.rupay => length == 16,
      CardNetwork.visa => length == 13 || length == 16 || length == 19,
      _ => false,
    };
  }

  static int cvvLengthForNetwork(CardNetwork? network) {
    return network == CardNetwork.amex ? 4 : 3;
  }

  static String format(String input) {
    final digits = digitsOnly(input);
    final maxLength = maxLengthForNumber(digits);
    final limitedLength = digits.length > maxLength ? maxLength : digits.length;
    final limited = digits.substring(0, limitedLength);
    final groups = _groupsForNumber(limited);
    final buffer = StringBuffer();
    int offset = 0;

    for (final groupSize in groups) {
      if (offset >= limited.length) break;
      if (buffer.isNotEmpty) buffer.write(' ');

      final groupEnd = offset + groupSize;
      final end = groupEnd > limited.length ? limited.length : groupEnd;
      buffer.write(limited.substring(offset, end));
      offset = end;
    }

    return buffer.toString();
  }

  static String progressiveMask(String input) {
    final clean = digitsOnly(input);
    final template = _templateForNumber(clean);
    final buffer = StringBuffer();
    int digitIndex = 0;

    for (int i = 0; i < template.length; i++) {
      if (template[i] == '*') {
        if (digitIndex < clean.length) {
          buffer.write(clean[digitIndex]);
          digitIndex++;
        } else {
          buffer.write('*');
        }
      } else {
        buffer.write(template[i]);
      }
    }

    return buffer.toString();
  }

  static String masked(String input) {
    final clean = digitsOnly(input);
    if (clean.length < 8) {
      return _templateForNumber(clean);
    }

    if (isAmexNumber(clean)) {
      return '${clean.substring(0, 4)} ****** ${clean.substring(clean.length - 5)}';
    }

    return '${clean.substring(0, 4)} **** **** ${clean.substring(clean.length - 4)}';
  }

  static List<int> _groupsForNumber(String input) {
    final network = networkForNumber(input);
    if (network == CardNetwork.amex) return const [4, 6, 5];
    if (network == CardNetwork.visa && digitsOnly(input).length > 16) {
      return const [4, 4, 4, 4, 3];
    }
    return const [4, 4, 4, 4];
  }

  static String _templateForNumber(String input) {
    final network = networkForNumber(input);
    if (network == CardNetwork.amex) return amexTemplate;
    if (network == CardNetwork.visa && digitsOnly(input).length > 16) {
      return longTemplate;
    }
    return standardTemplate;
  }
}
