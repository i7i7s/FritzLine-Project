// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReviewAdapter extends TypeAdapter<Review> {
  @override
  final int typeId = 3;

  @override
  Review read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Review(
      ticketId: fields[0] as String,
      trainId: fields[1] as String,
      trainName: fields[2] as String,
      rating: fields[3] as int,
      comment: fields[4] as String?,
      tags: (fields[5] as List).cast<String>(),
      reviewDate: fields[6] as DateTime,
      userId: fields[7] as String,
      userName: fields[8] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Review obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.ticketId)
      ..writeByte(1)
      ..write(obj.trainId)
      ..writeByte(2)
      ..write(obj.trainName)
      ..writeByte(3)
      ..write(obj.rating)
      ..writeByte(4)
      ..write(obj.comment)
      ..writeByte(5)
      ..write(obj.tags)
      ..writeByte(6)
      ..write(obj.reviewDate)
      ..writeByte(7)
      ..write(obj.userId)
      ..writeByte(8)
      ..write(obj.userName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReviewAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
