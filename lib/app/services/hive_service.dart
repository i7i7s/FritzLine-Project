import 'package:hive_flutter/hive_flutter.dart';
import 'package:get/get.dart';

class HiveService extends GetxService {
  late Box trainBox;
  late Box userBox;
  late Box sessionBox;

  Future<HiveService> init() async {
    trainBox = await Hive.openBox('trains');
    userBox = await Hive.openBox('users');
    sessionBox = await Hive.openBox('auth_session');

    await seedTrainDatabase();
    return this;
  }

  Future<void> seedTrainDatabase() async {
    if (trainBox.isNotEmpty) {
      return;
    }

    List<Kereta> expandedList = _expandBidirectional(_baseRoutes);
    List<Map<String, dynamic>> listKeretaMap =
        expandedList.map((k) => k.toMap()).toList();

    Map<String, Map<String, dynamic>> trainMap = {
      for (var train in listKeretaMap) train['id']: train
    };

    await trainBox.putAll(trainMap);
  }

  Future<List<Map<String, dynamic>>> cariKereta(
      String kodeAsal, String kodeTujuan) async {
    final allTrains = trainBox.values.toList();

    List<Map<String, dynamic>> results = [];
    for (var k in allTrains) {
      final train = Map<String, dynamic>.from(k as Map);
      if (train["stasiunBerangkat"] == kodeAsal &&
          train["stasiunTiba"] == kodeTujuan) {
        results.add(train);
      }
    }
    return results;
  }

  int _toMinutes(String hhmm) {
    final p = hhmm.split(':');
    return (int.parse(p[0]) * 60 + int.parse(p[1])) % (24 * 60);
  }

  String _toHHMM(int minutes) {
    minutes = minutes % (24 * 60);
    final h = (minutes ~/ 60).toString().padLeft(2, '0');
    final m = (minutes % 60).toString().padLeft(2, '0');
    return "$h:$m";
  }

  String _durasiToText(int durasiMenit) {
    final j = durasiMenit ~/ 60, m = durasiMenit % 60;
    return "${j}j ${m}m";
  }

  String _arrival(String berangkatHHMM, int durasiMenit) {
    final arr = _toMinutes(berangkatHHMM) + durasiMenit;
    return _toHHMM(arr);
  }

  List<Kereta> _expandBidirectional(List<Map<String, dynamic>> base) {
    final result = <Kereta>[];
    for (final r in base) {
      final id = r["id"] as String;
      final nama = r["nama"] as String;
      final asal = r["asal"] as String;
      final tujuan = r["tujuan"] as String;
      final depFwd = r["dep"] as String;
      final kelas = r["kelas"] as String;
      final harga = r["harga"] as int;
      final dur = r["durasi"] as int;

      final tibaFwd = _arrival(depFwd, dur);
      result.add(Kereta(
        id: "${id}A",
        namaKereta: nama,
        stasiunBerangkat: asal,
        stasiunTiba: tujuan,
        jadwalBerangkat: depFwd,
        jadwalTiba: tibaFwd,
        kelas: kelas,
        harga: harga,
        durasi: _durasiToText(dur),
      ));

      final depRev = _toHHMM(_toMinutes(depFwd) + 11 * 60);
      final tibaRev = _arrival(depRev, dur);
      result.add(Kereta(
        id: "${id}B",
        namaKereta: nama,
        stasiunBerangkat: tujuan,
        stasiunTiba: asal,
        jadwalBerangkat: depRev,
        jadwalTiba: tibaRev,
        kelas: kelas,
        harga: harga,
        durasi: _durasiToText(dur),
      ));
    }
    return result;
  }

  final List<Map<String, dynamic>> _baseRoutes = [
    {"id": "K001", "nama": "Argo Bromo Anggrek", "asal": "GMR", "tujuan": "SBI", "dep": "06:00", "kelas": "Eksekutif", "harga": 550000, "durasi": 270},
    {"id": "K002", "nama": "Argo Wilis", "asal": "BD", "tujuan": "SGU", "dep": "07:00", "kelas": "Eksekutif", "harga": 550000, "durasi": 510},
    {"id": "K003", "nama": "Argo Semeru", "asal": "GMR", "tujuan": "SGU", "dep": "07:10", "kelas": "Eksekutif", "harga": 550000, "durasi": 480},
    {"id": "K004", "nama": "Argo Dwipangga", "asal": "GMR", "tujuan": "SLO", "dep": "08:00", "kelas": "Eksekutif", "harga": 550000, "durasi": 375},
    {"id": "K005", "nama": "Argo Lawu", "asal": "GMR", "tujuan": "SLO", "dep": "21:00", "kelas": "Eksekutif", "harga": 550000, "durasi": 375},
    {"id": "K006", "nama": "Taksaka", "asal": "GMR", "tujuan": "YK", "dep": "08:00", "kelas": "Eksekutif", "harga": 420000, "durasi": 360},
    {"id": "K007", "nama": "Bengawan", "asal": "PSE", "tujuan": "PWS", "dep": "11:00", "kelas": "Ekonomi", "harga": 74000, "durasi": 450},
    {"id": "K008", "nama": "Argo Muria", "asal": "GMR", "tujuan": "SMT", "dep": "07:30", "kelas": "Eksekutif", "harga": 550000, "durasi": 285},
    {"id": "K009", "nama": "Argo Sindoro", "asal": "GMR", "tujuan": "SMT", "dep": "16:30", "kelas": "Eksekutif", "harga": 550000, "durasi": 285},
    {"id": "K010", "nama": "Lodaya", "asal": "BD", "tujuan": "SLO", "dep": "07:20", "kelas": "Eksekutif", "harga": 420000, "durasi": 430},
    {"id": "K011", "nama": "Gajayana", "asal": "GMR", "tujuan": "ML", "dep": "17:40", "kelas": "Eksekutif", "harga": 550000, "durasi": 760},
    {"id": "K012", "nama": "Bima", "asal": "GMR", "tujuan": "ML", "dep": "16:00", "kelas": "Eksekutif", "harga": 550000, "durasi": 840},
    {"id": "K013", "nama": "Fajar Utama Yogya", "asal": "PSE", "tujuan": "LPN", "dep": "06:15", "kelas": "Ekonomi", "harga": 95000, "durasi": 415},
    {"id": "K014", "nama": "Senja Utama Yogya", "asal": "PSE", "tujuan": "LPN", "dep": "19:00", "kelas": "Ekonomi", "harga": 95000, "durasi": 405},
    {"id": "K015", "nama": "Fajar Utama Solo", "asal": "PSE", "tujuan": "SLO", "dep": "06:30", "kelas": "Ekonomi", "harga": 98000, "durasi": 450},
    {"id": "K016", "nama": "Senja Utama Solo", "asal": "PSE", "tujuan": "SLO", "dep": "20:00", "kelas": "Ekonomi", "harga": 98000, "durasi": 420},
    {"id": "K017", "nama": "Bogowonto", "asal": "PSE", "tujuan": "LPN", "dep": "21:10", "kelas": "Ekonomi", "harga": 85000, "durasi": 440},
    {"id": "K018", "nama": "Gajahwong", "asal": "PSE", "tujuan": "LPN", "dep": "06:45", "kelas": "Ekonomi", "harga": 85000, "durasi": 435},
    {"id": "K019", "nama": "Progo", "asal": "PSE", "tujuan": "LPN", "dep": "22:30", "kelas": "Ekonomi", "harga": 80000, "durasi": 450},
    {"id": "K020", "nama": "Sri Tanjung", "asal": "KTG", "tujuan": "LPN", "dep": "06:00", "kelas": "Ekonomi", "harga": 90000, "durasi": 490},
    {"id": "K021", "nama": "Kahuripan", "asal": "KAC", "tujuan": "BL", "dep": "18:00", "kelas": "Ekonomi", "harga": 88000, "durasi": 720},
    {"id": "K022", "nama": "Manahan", "asal": "GMR", "tujuan": "SLO", "dep": "11:00", "kelas": "Eksekutif", "harga": 420000, "durasi": 390},
    {"id": "K023", "nama": "Argo Parahyangan", "asal": "GMR", "tujuan": "BD", "dep": "07:00", "kelas": "Eksekutif", "harga": 550000, "durasi": 180},
    {"id": "K024", "nama": "Sembrani", "asal": "GMR", "tujuan": "SBI", "dep": "19:00", "kelas": "Eksekutif", "harga": 550000, "durasi": 690},
    {"id": "K025", "nama": "Turangga", "asal": "BD", "tujuan": "SGU", "dep": "19:30", "kelas": "Eksekutif", "harga": 420000, "durasi": 630},
    {"id": "K026", "nama": "Jayabaya", "asal": "PSE", "tujuan": "ML", "dep": "13:00", "kelas": "Ekonomi", "harga": 110000, "durasi": 960},
    {"id": "K027", "nama": "Harina", "asal": "BD", "tujuan": "SBI", "dep": "20:15", "kelas": "Eksekutif", "harga": 420000, "durasi": 675},
    {"id": "K028", "nama": "Mutiara Selatan", "asal": "BD", "tujuan": "ML", "dep": "16:10", "kelas": "Campuran", "harga": 380000, "durasi": 840},
    {"id": "K029", "nama": "Malabar", "asal": "BD", "tujuan": "ML", "dep": "15:45", "kelas": "Campuran", "harga": 370000, "durasi": 915},
    {"id": "K030", "nama": "Ranggajati", "asal": "CN", "tujuan": "JR", "dep": "06:00", "kelas": "Eksekutif", "harga": 420000, "durasi": 765},
    {"id": "K031", "nama": "Wijayakusuma", "asal": "CP", "tujuan": "KTG", "dep": "10:00", "kelas": "Eksekutif", "harga": 420000, "durasi": 810},
    {"id": "K032", "nama": "Kertajaya", "asal": "PSE", "tujuan": "SBI", "dep": "14:00", "kelas": "Ekonomi", "harga": 95000, "durasi": 750},
    {"id": "K033", "nama": "Matarmaja", "asal": "PSE", "tujuan": "ML", "dep": "15:20", "kelas": "Ekonomi", "harga": 95000, "durasi": 850},
    {"id": "K034", "nama": "Pasundan", "asal": "KAC", "tujuan": "SGU", "dep": "05:30", "kelas": "Ekonomi", "harga": 90000, "durasi": 780},
    {"id": "K035", "nama": "Serayu", "asal": "PSE", "tujuan": "PWT", "dep": "09:00", "kelas": "Ekonomi", "harga": 85000, "durasi": 420},
    {"id": "K036", "nama": "Logawa", "asal": "PWT", "tujuan": "JR", "dep": "06:30", "kelas": "Ekonomi", "harga": 90000, "durasi": 840},
    {"id": "K037", "nama": "Sribilah", "asal": "MDN", "tujuan": "RAP", "dep": "07:30", "kelas": "Ekonomi", "harga": 78000, "durasi": 270},
    {"id": "K038", "nama": "Rajabasa", "asal": "KPT", "tujuan": "TNK", "dep": "08:00", "kelas": "Ekonomi", "harga": 82000, "durasi": 390},
    {"id": "K039", "nama": "Argo Cheribon", "asal": "GMR", "tujuan": "CN", "dep": "17:00", "kelas": "Eksekutif", "harga": 550000, "durasi": 180},
    {"id": "K040", "nama": "Pangandaran", "asal": "GMR", "tujuan": "BJR", "dep": "07:05", "kelas": "Eksekutif", "harga": 420000, "durasi": 325},
    {"id": "K041", "nama": "Blambangan Ekspres", "asal": "KTG", "tujuan": "SMT", "dep": "08:00", "kelas": "Eksekutif", "harga": 420000, "durasi": 690},
    {"id": "K042", "nama": "Pandalungan", "asal": "GMR", "tujuan": "JR", "dep": "08:20", "kelas": "Eksekutif", "harga": 420000, "durasi": 630},
    {"id": "K043", "nama": "Sawunggalih", "asal": "KTA", "tujuan": "PSE", "dep": "07:00", "kelas": "Eksekutif", "harga": 400000, "durasi": 380},
    {"id": "K044", "nama": "Kutojaya Utara", "asal": "KTA", "tujuan": "PSE", "dep": "17:30", "kelas": "Ekonomi", "harga": 80000, "durasi": 400},
    {"id": "K045", "nama": "Kutojaya Selatan", "asal": "KTA", "tujuan": "KAC", "dep": "09:00", "kelas": "Ekonomi", "harga": 80000, "durasi": 330},
    {"id": "K046", "nama": "Purwojaya", "asal": "CP", "tujuan": "GMR", "dep": "14:00", "kelas": "Eksekutif", "harga": 420000, "durasi": 420},
    {"id": "K047", "nama": "Tawang Jaya", "asal": "SMP", "tujuan": "PSE", "dep": "22:00", "kelas": "Ekonomi", "harga": 85000, "durasi": 420},
    {"id": "K048", "nama": "Tegal Bahari", "asal": "TG", "tujuan": "PSE", "dep": "05:30", "kelas": "Eksekutif", "harga": 420000, "durasi": 240},
    {"id": "K049", "nama": "Menoreh", "asal": "SMT", "tujuan": "PSE", "dep": "19:30", "kelas": "Ekonomi", "harga": 85000, "durasi": 420},
    {"id": "K050", "nama": "Ambarawa Ekspres", "asal": "SMP", "tujuan": "SBI", "dep": "06:00", "kelas": "Eksekutif", "harga": 420000, "durasi": 360},
    {"id": "K051", "nama": "Blora Jaya", "asal": "CU", "tujuan": "SMP", "dep": "05:45", "kelas": "Ekonomi", "harga": 75000, "durasi": 205},
    {"id": "K052", "nama": "Dharmawangsa", "asal": "PSE", "tujuan": "SBI", "dep": "22:00", "kelas": "Ekonomi", "harga": 100000, "durasi": 750},
    {"id": "K053", "nama": "Brantas", "asal": "PSE", "tujuan": "BL", "dep": "17:00", "kelas": "Ekonomi", "harga": 100000, "durasi": 840},
    {"id": "K054", "nama": "Bangunkarta", "asal": "GMR", "tujuan": "JG", "dep": "15:00", "kelas": "Eksekutif", "harga": 420000, "durasi": 750},
    {"id": "K055", "nama": "Cikuray", "asal": "KAC", "tujuan": "GRT", "dep": "06:00", "kelas": "Ekonomi", "harga": 74000, "durasi": 120},
    {"id": "K056", "nama": "Gaya Baru Malam Selatan", "asal": "PSE", "tujuan": "SGU", "dep": "10:30", "kelas": "Ekonomi", "harga": 110000, "durasi": 870},
    {"id": "K057", "nama": "Airlangga", "asal": "PSE", "tujuan": "SBI", "dep": "11:00", "kelas": "Ekonomi", "harga": 95000, "durasi": 840},
    {"id": "K058", "nama": "Majapahit", "asal": "PSE", "tujuan": "ML", "dep": "18:30", "kelas": "Ekonomi", "harga": 110000, "durasi": 840},
    {"id": "K059", "nama": "Singasari", "asal": "PSE", "tujuan": "BL", "dep": "12:00", "kelas": "Ekonomi", "harga": 100000, "durasi": 930},
    {"id": "K060", "nama": "Mutiara Timur", "asal": "KTG", "tujuan": "SGU", "dep": "05:30", "kelas": "Eksekutif", "harga": 420000, "durasi": 450},
    {"id": "K061", "nama": "Sancaka", "asal": "YK", "tujuan": "SGU", "dep": "06:45", "kelas": "Eksekutif", "harga": 420000, "durasi": 300},
    {"id": "K062", "nama": "Baturraden Ekspres", "asal": "PWT", "tujuan": "BD", "dep": "05:50", "kelas": "Eksekutif", "harga": 400000, "durasi": 280},
    {"id": "K063", "nama": "Kamandaka", "asal": "PWT", "tujuan": "SMT", "dep": "06:00", "kelas": "Ekonomi", "harga": 85000, "durasi": 270},
    {"id": "K064", "nama": "Joglosemarkerto", "asal": "PWT", "tujuan": "SMT", "dep": "05:30", "kelas": "Ekonomi", "harga": 95000, "durasi": 510},
  ];
}

class Kereta {
  final String id;
  final String namaKereta;
  final String stasiunBerangkat;
  final String stasiunTiba;
  final String jadwalBerangkat;
  final String jadwalTiba;
  final String kelas;
  final int harga;
  final String durasi;

  Kereta({
    required this.id,
    required this.namaKereta,
    required this.stasiunBerangkat,
    required this.stasiunTiba,
    required this.jadwalBerangkat,
    required this.jadwalTiba,
    required this.kelas,
    required this.harga,
    required this.durasi,
  });

  Map<String, dynamic> toMap() => {
        "id": id,
        "namaKereta": namaKereta,
        "stasiunBerangkat": stasiunBerangkat,
        "stasiunTiba": stasiunTiba,
        "jadwalBerangkat": jadwalBerangkat,
        "jadwalTiba": jadwalTiba,
        "kelas": kelas,
        "harga": harga,
        "durasi": durasi,
      };
}