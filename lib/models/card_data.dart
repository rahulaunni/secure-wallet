import 'package:hive/hive.dart';
import 'card_network.dart';
import 'card_type.dart';

part 'card_data.g.dart';

@HiveType(typeId: 0)
class CardData {
  @HiveField(0)
  final String bankCid;

  @HiveField(1)
  final CardNetwork cardNetwork;

  @HiveField(2)
  final CardType cardType;

  @HiveField(3)
  final String cardNumber;

  @HiveField(4)
  final String expiry;

  @HiveField(5)
  final String holderName;

  @HiveField(6)
  final String cvv;

  @HiveField(7)
  final String? customBankName;

  @HiveField(8)
  final String? customBankLogoPath;

  @HiveField(9)
  final int? customGradientStartColor;

  @HiveField(10)
  final int? customGradientEndColor;

  const CardData({
    required this.bankCid,
    required this.cardNetwork,
    required this.cardType,
    required this.cardNumber,
    required this.expiry,
    required this.holderName,
    required this.cvv,
    this.customBankName,
    this.customBankLogoPath,
    this.customGradientStartColor,
    this.customGradientEndColor,
  });
}
