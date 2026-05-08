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

  @HiveField(11)
  final String? customCardImagePath;

  @HiveField(12)
  final int? customCardVisualMode;

  @HiveField(13)
  final double? customCardImageAlignmentX;

  @HiveField(14)
  final double? customCardImageAlignmentY;

  @HiveField(15)
  final String? customCardPatternAssetPath;

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
    this.customCardImagePath,
    this.customCardVisualMode,
    this.customCardImageAlignmentX,
    this.customCardImageAlignmentY,
    this.customCardPatternAssetPath,
  });

  CardData copyWith({
    String? bankCid,
    CardNetwork? cardNetwork,
    CardType? cardType,
    String? cardNumber,
    String? expiry,
    String? holderName,
    String? cvv,
    String? customBankName,
    String? customBankLogoPath,
    int? customGradientStartColor,
    int? customGradientEndColor,
    String? customCardImagePath,
    int? customCardVisualMode,
    double? customCardImageAlignmentX,
    double? customCardImageAlignmentY,
    String? customCardPatternAssetPath,
    bool clearCustomGradient = false,
    bool clearCustomCardImage = false,
    bool clearCustomCardVisualMode = false,
    bool clearCustomCardImageAlignment = false,
    bool clearCustomCardPattern = false,
  }) {
    return CardData(
      bankCid: bankCid ?? this.bankCid,
      cardNetwork: cardNetwork ?? this.cardNetwork,
      cardType: cardType ?? this.cardType,
      cardNumber: cardNumber ?? this.cardNumber,
      expiry: expiry ?? this.expiry,
      holderName: holderName ?? this.holderName,
      cvv: cvv ?? this.cvv,
      customBankName: customBankName ?? this.customBankName,
      customBankLogoPath: customBankLogoPath ?? this.customBankLogoPath,
      customGradientStartColor: clearCustomGradient
          ? null
          : customGradientStartColor ?? this.customGradientStartColor,
      customGradientEndColor: clearCustomGradient
          ? null
          : customGradientEndColor ?? this.customGradientEndColor,
      customCardImagePath: clearCustomCardImage
          ? null
          : customCardImagePath ?? this.customCardImagePath,
      customCardVisualMode: clearCustomCardVisualMode
          ? null
          : customCardVisualMode ?? this.customCardVisualMode,
      customCardImageAlignmentX: clearCustomCardImageAlignment
          ? null
          : customCardImageAlignmentX ?? this.customCardImageAlignmentX,
      customCardImageAlignmentY: clearCustomCardImageAlignment
          ? null
          : customCardImageAlignmentY ?? this.customCardImageAlignmentY,
      customCardPatternAssetPath: clearCustomCardPattern
          ? null
          : customCardPatternAssetPath ?? this.customCardPatternAssetPath,
    );
  }
}
