import '../models/card_network.dart';

class CardNetworkDetector {
  static CardNetwork? detect(String input) {
    final digits = input.replaceAll(RegExp(r'\D'), '');

    if (digits.isEmpty) return null;

    // AMERICAN EXPRESS: 34 or 37, 15 digits, 4-digit CID/CVV
    if (digits.startsWith('34') || digits.startsWith('37')) {
      return CardNetwork.amex;
    }

    // VISA: starts with 4
    if (digits.startsWith('4')) {
      return CardNetwork.visa;
    }

    // MASTERCARD: 51–55 or 2221–2720
    final firstTwo =
        int.tryParse(digits.substring(0, digits.length >= 2 ? 2 : 1));
    final firstFour =
        int.tryParse(digits.substring(0, digits.length >= 4 ? 4 : 1));

    if (firstTwo != null && firstTwo >= 51 && firstTwo <= 55) {
      return CardNetwork.mastercard;
    }

    if (firstFour != null && firstFour >= 2221 && firstFour <= 2720) {
      return CardNetwork.mastercard;
    }

    // RUPAY
    if (digits.startsWith('60') ||
        digits.startsWith('65') ||
        digits.startsWith('81') ||
        digits.startsWith('82')) {
      return CardNetwork.rupay;
    }

    return null;
  }
}
