import 'package:swallet/models/card_network.dart';

class CardNumberFormat {
  static const String standardTemplate = '**** **** **** ****';
  static const String amexTemplate = '**** ****** *****';

  static String digitsOnly(String input) {
    return input.replaceAll(RegExp(r'[^0-9]'), '');
  }

  static bool isAmexNumber(String input) {
    final digits = digitsOnly(input);
    return digits.startsWith('34') || digits.startsWith('37');
  }

  static int maxLengthForNumber(String input) {
    return isAmexNumber(input) ? 15 : 16;
  }

  static int cvvLengthForNetwork(CardNetwork? network) {
    return network == CardNetwork.amex ? 4 : 3;
  }

  static String format(String input) {
    final digits = digitsOnly(input);
    final maxLength = maxLengthForNumber(digits);
    final limitedLength = digits.length > maxLength ? maxLength : digits.length;
    final limited = digits.substring(0, limitedLength);
    final groups = isAmexNumber(limited) ? const [4, 6, 5] : const [4, 4, 4, 4];
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
    final template = isAmexNumber(clean) ? amexTemplate : standardTemplate;
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
      return isAmexNumber(clean) ? amexTemplate : standardTemplate;
    }

    if (isAmexNumber(clean)) {
      return '${clean.substring(0, 4)} ****** ${clean.substring(clean.length - 5)}';
    }

    return '${clean.substring(0, 4)} **** **** ${clean.substring(clean.length - 4)}';
  }
}
