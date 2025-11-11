import 'package:hive/hive.dart';

part 'passenger.g.dart';

@HiveType(typeId: 0)
class Passenger extends HiveObject {
  @HiveField(0)
  String nama;

  @HiveField(1)
  String idType;

  @HiveField(2)
  String idNumber;

  Passenger({
    required this.nama,
    required this.idType,
    required this.idNumber,
  });

  Map<String, String> toMap() {
    return {
      "nama": nama,
      "id_type": idType,
      "id_number": idNumber,
    };
  }
}