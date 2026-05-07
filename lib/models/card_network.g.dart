// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card_network.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CardNetworkAdapter extends TypeAdapter<CardNetwork> {
  @override
  final int typeId = 1;

  @override
  CardNetwork read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return CardNetwork.visa;
      case 1:
        return CardNetwork.mastercard;
      case 2:
        return CardNetwork.rupay;
      case 3:
        return CardNetwork.amex;
      case 4:
        return CardNetwork.unknown;
      default:
        return CardNetwork.visa;
    }
  }

  @override
  void write(BinaryWriter writer, CardNetwork obj) {
    switch (obj) {
      case CardNetwork.visa:
        writer.writeByte(0);
        break;
      case CardNetwork.mastercard:
        writer.writeByte(1);
        break;
      case CardNetwork.rupay:
        writer.writeByte(2);
        break;
      case CardNetwork.amex:
        writer.writeByte(3);
        break;
      case CardNetwork.unknown:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CardNetworkAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
