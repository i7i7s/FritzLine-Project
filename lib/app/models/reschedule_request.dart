import 'package:hive/hive.dart';

part 'reschedule_request.g.dart';

@HiveType(typeId: 6)
class RescheduleRequest extends HiveObject {
  @HiveField(0)
  String requestId;

  @HiveField(1)
  String originalTicketId;

  @HiveField(2)
  String originalTrainId;

  @HiveField(3)
  String originalTrainName;

  @HiveField(4)
  DateTime originalTravelDate;

  @HiveField(5)
  String originalDeparture;

  @HiveField(6)
  String originalArrival;

  @HiveField(7)
  String? newTrainId;

  @HiveField(8)
  String? newTrainName;

  @HiveField(9)
  DateTime? newTravelDate;

  @HiveField(10)
  String? newSeatNumber;

  @HiveField(11)
  DateTime requestDate;

  @HiveField(12)
  String reason;

  @HiveField(13)
  double originalAmount;

  @HiveField(14)
  double rescheduleFee;

  @HiveField(15)
  double additionalCharge; // if new ticket is more expensive

  @HiveField(16)
  double totalCharge;

  @HiveField(17)
  int daysBeforeDeparture;

  @HiveField(18)
  String status; // pending, approved, rejected, completed

  @HiveField(19)
  String? newTicketId;

  @HiveField(20)
  DateTime? processedDate;

  @HiveField(21)
  String? adminNotes;

  RescheduleRequest({
    required this.requestId,
    required this.originalTicketId,
    required this.originalTrainId,
    required this.originalTrainName,
    required this.originalTravelDate,
    required this.originalDeparture,
    required this.originalArrival,
    this.newTrainId,
    this.newTrainName,
    this.newTravelDate,
    this.newSeatNumber,
    required this.requestDate,
    required this.reason,
    required this.originalAmount,
    required this.rescheduleFee,
    this.additionalCharge = 0,
    required this.totalCharge,
    required this.daysBeforeDeparture,
    this.status = 'pending',
    this.newTicketId,
    this.processedDate,
    this.adminNotes,
  });
}
