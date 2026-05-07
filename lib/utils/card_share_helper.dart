import 'package:share_plus/share_plus.dart';

import '../models/card_data.dart';
import '../models/card_type.dart';
import '../utils/bank_asset_resolver.dart';
import 'card_number_format.dart';

class CardShareHelper {
  static Future<void> shareCard(CardData card) async {
    final text = _buildShareText(card);
    await Share.share(text);
  }

  static String _buildShareText(CardData card) {
    final bankName = card.customBankName?.trim().isNotEmpty == true
        ? card.customBankName!.trim()
        : BankAssetResolver.displayName(card.bankCid);

    return '''
Card Details

Bank: $bankName
Cardholder: ${card.holderName}
Card Number: ${_formatCardNumber(card.cardNumber)}
Expiry: ${card.expiry}
CVV: 
Type: ${card.cardType == CardType.credit ? 'Credit Card' : 'Debit Card'}
'''
        .trim();
  }

  static String _formatCardNumber(String number) {
    return CardNumberFormat.format(number);
  }
}
