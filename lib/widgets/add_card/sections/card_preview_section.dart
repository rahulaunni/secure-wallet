import 'package:flutter/material.dart';
import '../../card/bank_card.dart';
import '../../card/secure_reveal_wrapper.dart';

class CardPreview extends StatelessWidget {
  final String bankCid;
  final String cardType;
  final String cardNumber;
  final String validThru;
  final String holderName;
  final String networkLogo;

  const CardPreview({
    super.key,
    required this.bankCid,
    required this.cardType,
    required this.cardNumber,
    required this.validThru,
    required this.holderName,
    // ❌ gradient removed (BankCard handles it now)
    required this.networkLogo,
  });

  String _maskedPreview(String raw) {
    final digits = raw.replaceAll(' ', '');
    if (digits.isEmpty) return '****************';

    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      buffer.write(i < 2 ? digits[i] : '*');
      if ((i + 1) % 4 == 0 && i != digits.length - 1) {
        buffer.write(' ');
      }
    }
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    return SecureRevealWrapper(
      revealed: true,
      onAutoLock: () {},
      child: BankCard(
        bankLogo: bankCid,
        networkLogo: networkLogo,
        cardType: cardType,
        cardNumber: _maskedPreview(cardNumber),
        validThru: validThru.isEmpty ? 'MM/YY' : validThru,
        holderName: holderName.isEmpty ? 'CARD HOLDER' : holderName,
        cvv: '***', // 🔒 PREVIEW NEVER SHOWS REAL CVV
        // ❌ gradient: gradient, <--- REMOVED
        onEyeTap: () {},
        onShareTap: null,
      ),
    );
  }
}
