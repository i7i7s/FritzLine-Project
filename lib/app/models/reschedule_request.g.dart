// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reschedule_request.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RescheduleRequestAdapter extends TypeAdapter<RescheduleRequest> {
  @override
  final int typeId = 6;

  @override
  RescheduleRequest read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RescheduleRequest(
      requestId: fields[0] as String,
      originalTicketId: fields[1] as String,
      originalTrainId: fields[2] as String,
      originalTrainName: fields[3] as String,
      originalTravelDate: fields[4] as DateTime,
      originalDeparture: fields[5] as String,
      originalArrival: fields[6] as String,
      newTrainId: fields[7] as String?,
      newTrainName: fields[8] as String?,
      newTravelDate: fields[9] as DateTime?,
      newSeatNumber: fields[10] as String?,
      requestDate: fields[11] as DateTime,
      reason: fields[12] as String,
      originalAmount: fields[13] as double,
      rescheduleFee: fields[14] as double,
      additionalCharge: fields[15] as double,
      totalCharge: fields[16] as double,
      daysBeforeDeparture: fields[17] as int,
      status: fields[18] as String,
      newTicketId: fields[19] as String?,
      processedDate: fields[20] as DateTime?,
      adminNotes: fields[21] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, RescheduleRequest obj) {
    writer
      ..writeByte(22)
      ..writeByte(0)
      ..write(obj.requestId)
      ..writeByte(1)
      ..write(obj.originalTicketId)
      ..writeByte(2)
      ..write(obj.originalTrainId)
      ..writeByte(3)
      ..write(obj.originalTrainName)
      ..writeByte(4)
      ..write(obj.originalTravelDate)
      ..writeByte(5)
      ..write(obj.originalDeparture)
      ..writeByte(6)
      ..write(obj.originalArrival)
      ..writeByte(7)
      ..write(obj.newTrainId)
      ..writeByte(8)
      ..write(obj.newTrainName)
      ..writeByte(9)
      ..write(obj.newTravelDate)
      ..writeByte(10)
      ..write(obj.newSeatNumber)
      ..writeByte(11)
      ..write(obj.requestDate)
      ..writeByte(12)
      ..write(obj.reason)
      ..writeByte(13)
      ..write(obj.originalAmount)
      ..writeByte(14)
      ..write(obj.rescheduleFee)
      ..writeByte(15)
      ..write(obj.additionalCharge)
      ..writeByte(16)
      ..write(obj.totalCharge)
      ..writeByte(17)
      ..write(obj.daysBeforeDeparture)
      ..writeByte(18)
      ..write(obj.status)
      ..writeByte(19)
      ..write(obj.newTicketId)
      ..writeByte(20)
      ..write(obj.processedDate)
      ..writeByte(21)
      ..write(obj.adminNotes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RescheduleRequestAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
