import 'package:hive/hive.dart';

part 'card_network.g.dart';

@HiveType(typeId: 1)
enum CardNetwork {
  @HiveField(0)
  visa,

  @HiveField(1)
  mastercard,

  @HiveField(2)
  rupay,

  @HiveField(3)
  amex,

  @HiveField(4)
  unknown;

  String get assetPath {
    switch (this) {
      case CardNetwork.visa:
        return 'assets/images/networks/visa.svg';
      case CardNetwork.mastercard:
        return 'assets/images/networks/mastercard.svg';
      case CardNetwork.rupay:
        return 'assets/images/networks/rupay.svg';
      case CardNetwork.amex:
        return 'assets/images/networks/amex.svg';
      case CardNetwork.unknown:
        return '';
    }
  }
}
