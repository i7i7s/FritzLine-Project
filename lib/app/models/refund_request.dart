import 'package:hive/hive.dart';

part 'refund_request.g.dart';

@HiveType(typeId: 5)
class RefundRequest extends HiveObject {
  @HiveField(0)
  String requestId;

  @HiveField(1)
  String ticketId;

  @HiveField(2)
  String trainId;

  @HiveField(3)
  String trainName;

  @HiveField(4)
  DateTime travelDate;

  @HiveField(5)
  DateTime requestDate;

  @HiveField(6)
  String reason;

  @HiveField(7)
  double originalAmount;

  @HiveField(8)
  double refundAmount;

  @HiveField(9)
  double refundPercentage;

  @HiveField(10)
  int daysBeforeDeparture;

  @HiveField(11)
  String status;

  @HiveField(12)
  String? bankAccount;

  @HiveField(13)
  String? bankName;

  @HiveField(14)
  DateTime? processedDate;

  @HiveField(15)
  String? adminNotes;

  RefundRequest({
    required this.requestId,
    required this.ticketId,
    required this.trainId,
    required this.trainName,
    required this.travelDate,
    required this.requestDate,
    required this.reason,
    required this.originalAmount,
    required this.refundAmount,
    required this.refundPercentage,
    required this.daysBeforeDeparture,
    this.status = 'pending',
    this.bankAccount,
    this.bankName,
    this.processedDate,
    this.adminNotes,
  });
}
