import 'package:hive/hive.dart';

part 'review.g.dart';

@HiveType(typeId: 3)
class Review extends HiveObject {
  @HiveField(0)
  String ticketId;

  @HiveField(1)
  String trainId;

  @HiveField(2)
  String trainName;

  @HiveField(3)
  int rating; // 1-5

  @HiveField(4)
  String? comment;

  @HiveField(5)
  List<String> tags; // ["Bersih", "Tepat Waktu", "AC Dingin", dll]

  @HiveField(6)
  DateTime reviewDate;

  @HiveField(7)
  String userId;

  @HiveField(8)
  String userName;

  Review({
    required this.ticketId,
    required this.trainId,
    required this.trainName,
    required this.rating,
    this.comment,
    required this.tags,
    required this.reviewDate,
    required this.userId,
    required this.userName,
  });
}
