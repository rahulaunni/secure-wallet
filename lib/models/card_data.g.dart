// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card_data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CardDataAdapter extends TypeAdapter<CardData> {
  @override
  final int typeId = 0;

  @override
  CardData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CardData(
      bankCid: fields[0] as String,
      cardNetwork: fields[1] as CardNetwork,
      cardType: fields[2] as CardType,
      cardNumber: fields[3] as String,
      expiry: fields[4] as String,
      holderName: fields[5] as String,
      cvv: fields[6] as String,
      customBankName: fields[7] as String?,
      customBankLogoPath: fields[8] as String?,
      customGradientStartColor: fields[9] as int?,
      customGradientEndColor: fields[10] as int?,
      customCardImagePath: fields[11] as String?,
      customCardVisualMode: fields[12] as int?,
      customCardImageAlignmentX: fields[13] as double?,
      customCardImageAlignmentY: fields[14] as double?,
      customCardPatternAssetPath: fields[15] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, CardData obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.bankCid)
      ..writeByte(1)
      ..write(obj.cardNetwork)
      ..writeByte(2)
      ..write(obj.cardType)
      ..writeByte(3)
      ..write(obj.cardNumber)
      ..writeByte(4)
      ..write(obj.expiry)
      ..writeByte(5)
      ..write(obj.holderName)
      ..writeByte(6)
      ..write(obj.cvv)
      ..writeByte(7)
      ..write(obj.customBankName)
      ..writeByte(8)
      ..write(obj.customBankLogoPath)
      ..writeByte(9)
      ..write(obj.customGradientStartColor)
      ..writeByte(10)
      ..write(obj.customGradientEndColor)
      ..writeByte(11)
      ..write(obj.customCardImagePath)
      ..writeByte(12)
      ..write(obj.customCardVisualMode)
      ..writeByte(13)
      ..write(obj.customCardImageAlignmentX)
      ..writeByte(14)
      ..write(obj.customCardImageAlignmentY)
      ..writeByte(15)
      ..write(obj.customCardPatternAssetPath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CardDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
