import 'package:hive/hive.dart';

part 'card_type.g.dart';

@HiveType(typeId: 2)
enum CardType {
  @HiveField(0)
  credit,

  @HiveField(1)
  debit,
}
