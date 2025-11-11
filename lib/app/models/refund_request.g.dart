// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'refund_request.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RefundRequestAdapter extends TypeAdapter<RefundRequest> {
  @override
  final int typeId = 5;

  @override
  RefundRequest read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RefundRequest(
      requestId: fields[0] as String,
      ticketId: fields[1] as String,
      trainId: fields[2] as String,
      trainName: fields[3] as String,
      travelDate: fields[4] as DateTime,
      requestDate: fields[5] as DateTime,
      reason: fields[6] as String,
      originalAmount: fields[7] as double,
      refundAmount: fields[8] as double,
      refundPercentage: fields[9] as double,
      daysBeforeDeparture: fields[10] as int,
      status: fields[11] as String,
      bankAccount: fields[12] as String?,
      bankName: fields[13] as String?,
      processedDate: fields[14] as DateTime?,
      adminNotes: fields[15] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, RefundRequest obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.requestId)
      ..writeByte(1)
      ..write(obj.ticketId)
      ..writeByte(2)
      ..write(obj.trainId)
      ..writeByte(3)
      ..write(obj.trainName)
      ..writeByte(4)
      ..write(obj.travelDate)
      ..writeByte(5)
      ..write(obj.requestDate)
      ..writeByte(6)
      ..write(obj.reason)
      ..writeByte(7)
      ..write(obj.originalAmount)
      ..writeByte(8)
      ..write(obj.refundAmount)
      ..writeByte(9)
      ..write(obj.refundPercentage)
      ..writeByte(10)
      ..write(obj.daysBeforeDeparture)
      ..writeByte(11)
      ..write(obj.status)
      ..writeByte(12)
      ..write(obj.bankAccount)
      ..writeByte(13)
      ..write(obj.bankName)
      ..writeByte(14)
      ..write(obj.processedDate)
      ..writeByte(15)
      ..write(obj.adminNotes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RefundRequestAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
