import 'package:hive/hive.dart';
import 'passenger.dart';

part 'user.g.dart';

@HiveType(typeId: 1)
class User extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String email;

  @HiveField(2)
  String password;

  @HiveField(3)
  HiveList<Passenger> savedPassengers;

  @HiveField(4)
  int? loyaltyPoints;

  @HiveField(5)
  String? memberTier;

  User({
    required this.name,
    required this.email,
    required this.password,
    required this.savedPassengers,
    this.loyaltyPoints = 0,
    this.memberTier = 'Bronze',
  });
}
