enum PassengerType {
  adult,
  childWithSeat,
  infant,
}

class PassengerInfo {
  final PassengerType type;
  final String name;
  final String idNumber;
  final String idType;
  final int? age;
  final bool needsSeat;
  final bool needsPayment;
  String? seatNumber;
  String? seatCarriage;
  final int passengerIndex;
  final String gender;

  PassengerInfo({
    required this.type,
    required this.name,
    required this.idNumber,
    required this.idType,
    this.age,
    required this.needsSeat,
    required this.needsPayment,
    this.seatNumber,
    this.seatCarriage,
    required this.passengerIndex,
    required this.gender,
  });

  factory PassengerInfo.fromType({
    required PassengerType type,
    required String name,
    required String idNumber,
    required String idType,
    int? age,
    required int passengerIndex,
    String? seatNumber,
    String? seatCarriage,
    required String gender,
  }) {
    switch (type) {
      case PassengerType.adult:
        return PassengerInfo(
          type: type,
          name: name,
          idNumber: idNumber,
          idType: idType,
          age: age,
          needsSeat: true,
          needsPayment: true,
          passengerIndex: passengerIndex,
          seatNumber: seatNumber,
          seatCarriage: seatCarriage,
          gender: gender,
        );
      case PassengerType.childWithSeat:
        return PassengerInfo(
          type: type,
          name: name,
          idNumber: idNumber,
          idType: idType,
          age: age,
          needsSeat: true,
          needsPayment: true,
          passengerIndex: passengerIndex,
          seatNumber: seatNumber,
          seatCarriage: seatCarriage,
          gender: gender,
        );
      case PassengerType.infant:
        return PassengerInfo(
          type: type,
          name: name,
          idNumber: idNumber,
          idType: idType,
          age: age,
          needsSeat: false,
          needsPayment: false,
          passengerIndex: passengerIndex,
          seatNumber: seatNumber,
          seatCarriage: seatCarriage,
          gender: gender,
        );
    }
  }

  String get typeLabel {
    switch (type) {
      case PassengerType.adult:
        return 'Dewasa';
      case PassengerType.childWithSeat:
        return 'Anak (≥3 tahun)';
      case PassengerType.infant:
        return 'Bayi (<3 tahun)';
    }
  }

  String get typeDescription {
    switch (type) {
      case PassengerType.adult:
        return 'Perlu kursi & bayar';
      case PassengerType.childWithSeat:
        return 'Perlu kursi & bayar';
      case PassengerType.infant:
        return 'Gratis, tanpa kursi';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.toString(),
      'name': name,
      'idNumber': idNumber,
      'idType': idType,
      'age': age,
      'needsSeat': needsSeat,
      'needsPayment': needsPayment,
      'seatNumber': seatNumber,
      'seatCarriage': seatCarriage,
      'passengerIndex': passengerIndex,
      'gender': gender,
    };
  }

  factory PassengerInfo.fromJson(Map<String, dynamic> json) {
    return PassengerInfo(
      type: PassengerType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => PassengerType.adult,
      ),
      name: json['name'] ?? '',
      idNumber: json['idNumber'] ?? '',
      idType: json['idType'] ?? 'KTP',
      age: json['age'],
      needsSeat: json['needsSeat'] ?? true,
      needsPayment: json['needsPayment'] ?? true,
      seatNumber: json['seatNumber'],
      seatCarriage: json['seatCarriage'],
      passengerIndex: json['passengerIndex'] ?? 0,
      gender: json['gender'] ?? 'Laki-laki',
    );
  }
}
