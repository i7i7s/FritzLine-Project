// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'passenger.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PassengerAdapter extends TypeAdapter<Passenger> {
  @override
  final int typeId = 0;

  @override
  Passenger read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Passenger(
      nama: fields[0] as String,
      idType: fields[1] as String,
      idNumber: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Passenger obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.nama)
      ..writeByte(1)
      ..write(obj.idType)
      ..writeByte(2)
      ..write(obj.idNumber);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PassengerAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
