enum PassengerType {
  adult,
  childWithSeat,
  infant,
}

class PassengerInfo {
  final PassengerType type;
  final String name;
  final String idNumber;
  final int? age;
  final bool needsSeat;
  final bool needsPayment;

  PassengerInfo({
    required this.type,
    required this.name,
    required this.idNumber,
    this.age,
    required this.needsSeat,
    required this.needsPayment,
  });

  factory PassengerInfo.fromType({
    required PassengerType type,
    required String name,
    required String idNumber,
    int? age,
  }) {
    switch (type) {
      case PassengerType.adult:
        return PassengerInfo(
          type: type,
          name: name,
          idNumber: idNumber,
          age: age,
          needsSeat: true,
          needsPayment: true,
        );
      case PassengerType.childWithSeat:
        return PassengerInfo(
          type: type,
          name: name,
          idNumber: idNumber,
          age: age,
          needsSeat: true,
          needsPayment: true,
        );
      case PassengerType.infant:
        return PassengerInfo(
          type: type,
          name: name,
          idNumber: idNumber,
          age: age,
          needsSeat: false,
          needsPayment: false,
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
      'type': type.name,
      'name': name,
      'idNumber': idNumber,
      'age': age,
      'needsSeat': needsSeat,
      'needsPayment': needsPayment,
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
      age: json['age'],
      needsSeat: json['needsSeat'] ?? true,
      needsPayment: json['needsPayment'] ?? true,
    );
  }
}
