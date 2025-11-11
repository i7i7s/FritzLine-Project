import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'ticket_service.dart';
import 'auth_service.dart';

class FreyaAIService {
  GenerativeModel? _model;
  String? _modelName;
  bool _isInitialized = false;
  
  final String _apiBaseUrl = "https://kereta-api-production.up.railway.app";
  Box? _chatHistoryBox;

  bool get isInitialized => _isInitialized;
  String? get modelName => _modelName;

  Future<void> initChatHistory() async {
    _chatHistoryBox = await Hive.openBox('freya_chat_history');
  }

  String _getUserTicketsInfo() {
    try {
      final ticketService = Get.find<TicketService>();
      final tickets = ticketService.allMyTickets;
      
      if (tickets.isEmpty) {
        return 'User belum punya tiket yang aktif.';
      }
      
      StringBuffer info = StringBuffer('TIKET USER SAAT INI:\n\n');
      for (var i = 0; i < tickets.length; i++) {
        final ticket = tickets[i];
        info.writeln('Tiket ${i + 1}:');
        info.writeln('Kode Booking: ${ticket['bookingCode']}');
        info.writeln('Kereta: ${ticket['train']?['namaKereta']}');
        info.writeln('Rute: ${ticket['train']?['stasiunBerangkat']} → ${ticket['train']?['stasiunTiba']}');
        info.writeln('Berangkat: ${ticket['train']?['jadwalBerangkat']}');
        info.writeln('Kelas: ${ticket['train']?['kelas']}');
        info.writeln('Kursi: ${ticket['selectedSeats']?.join(', ')}');
        info.writeln('Total: Rp ${ticket['totalPrice']}');
        info.writeln('');
      }
      return info.toString();
    } catch (e) {
      print('⚠️ Error getting user tickets: $e');
      return 'Tidak bisa mengakses data tiket saat ini.';
    }
  }

  Future<void> saveChatMessage(String message, bool isUser) async {
    if (_chatHistoryBox == null) return;
    
    try {
      final authService = Get.find<AuthService>();
      final userId = authService.currentUser.value?.email ?? 'guest';
      
      final chatData = {
        'userId': userId,
        'message': message,
        'isUser': isUser,
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      await _chatHistoryBox!.add(chatData);
    } catch (e) {
      print('⚠️ Error saving chat: $e');
    }
  }

  List<Map<String, dynamic>> loadChatHistory() {
    if (_chatHistoryBox == null) return [];
    
    try {
      final authService = Get.find<AuthService>();
      final userId = authService.currentUser.value?.email ?? 'guest';
      
      final allChats = _chatHistoryBox!.values.toList();
      final userChats = allChats.where((chat) {
        if (chat is Map) {
          return chat['userId'] == userId;
        }
        return false;
      }).toList();
      
      return userChats.map((chat) {
        if (chat is Map) {
          return Map<String, dynamic>.from(chat);
        }
        return <String, dynamic>{};
      }).toList();
    } catch (e) {
      print('⚠️ Error loading chat history: $e');
      return [];
    }
  }

  Future<void> clearChatHistory() async {
    if (_chatHistoryBox == null) return;
    
    try {
      final authService = Get.find<AuthService>();
      final userId = authService.currentUser.value?.email ?? 'guest';
      
      final keysToDelete = <dynamic>[];
      for (var i = 0; i < _chatHistoryBox!.length; i++) {
        final chat = _chatHistoryBox!.getAt(i);
        if (chat is Map && chat['userId'] == userId) {
          keysToDelete.add(_chatHistoryBox!.keyAt(i));
        }
      }
      
      for (var key in keysToDelete) {
        await _chatHistoryBox!.delete(key);
      }
      
      print('✅ Chat history cleared for user: $userId');
    } catch (e) {
      print('⚠️ Error clearing chat history: $e');
    }
  }

  Future<void> initialize() async {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      print('⚠️ No API key found in .env file');
      return;
    }

    print('🔑 API Key loaded: ${apiKey.substring(0, 10)}...');
    
    await initChatHistory();

    try {
      final uri = Uri.parse(
          'https://generativelanguage.googleapis.com/v1/models?key=$apiKey');
      final resp = await http.get(uri);

      if (resp.statusCode == 200) {
        final json = jsonDecode(resp.body) as Map<String, dynamic>;
        final models = (json['models'] as List<dynamic>?) ?? const [];

        String? pickFrom(List<String> preferences) {
          for (final pref in preferences) {
            final match = models.cast<Map<String, dynamic>?>().firstWhere(
                  (m) =>
                      m != null &&
                      (m['name']?.toString().contains(pref) ?? false) &&
                      (((m['supportedGenerationMethods'] ??
                                      m['supported_generation_methods'])
                                  as List?)
                              ?.contains('generateContent') ??
                          false),
                  orElse: () => null,
                );
            if (match != null) return match['name'] as String;
          }
          for (final m in models.cast<Map<String, dynamic>>()) {
            final methods = (m['supportedGenerationMethods'] ??
                    m['supported_generation_methods']) as List?;
            if ((methods ?? const []).contains('generateContent')) {
              return m['name'] as String;
            }
          }
          return null;
        }

        final preferred = pickFrom(const [
          'gemini-1.5-flash',
          'gemini-1.5-pro',
          'gemini-1.0-pro',
          'gemini-pro',
        ]);

        if (preferred != null) {
          final short = preferred.split('/').last;
          _modelName = short;
          _model = GenerativeModel(
            model: short,
            apiKey: apiKey,
            systemInstruction: Content.system(_getTourismPrompt()),
          );
          _isInitialized = true;
          print('✅ Model initialized: $_modelName');
        } else {
          print('⚠️ No suitable model found for generateContent.');
          _tryFallbackModels(apiKey);
        }
      } else {
        print('⚠️ ListModels failed ${resp.statusCode}: ${resp.body}');
        _tryFallbackModels(apiKey);
      }
    } catch (e) {
      print('❌ Error listing models: $e');
      _tryFallbackModels(apiKey);
    }
  }

  void _tryFallbackModels(String apiKey) {
    print('🔄 Trying fallback models...');
    const fallbackModels = [
      'gemini-1.5-flash',
      'gemini-1.5-pro',
      'gemini-pro',
      'gemini-1.0-pro',
    ];

    final modelToTry = fallbackModels.first;
    print('📌 Using fallback model: $modelToTry');

    _modelName = modelToTry;
    _model = GenerativeModel(
      model: modelToTry,
      apiKey: apiKey,
      systemInstruction: Content.system(_getTourismPrompt()),
    );
    _isInitialized = true;
  }

  String _getTourismPrompt() {
    return '''
Kamu adalah Freya, asisten AI yang ramah, friendly, dan helpful untuk aplikasi FritzLine - platform pemesanan tiket kereta wisata.

TENTANG FRITZLINE:
- FritzLine adalah layanan kereta wisata yang melayani berbagai rute di Indonesia
- User bisa pesan tiket, lihat jadwal, pilih kursi, dan cek riwayat booking di aplikasi
- FritzLine punya database real-time untuk jadwal kereta, harga tiket, dan ketersediaan kursi
- Sistem booking online dengan berbagai pilihan kelas (Ekonomi, Bisnis, Eksekutif)
- Kamu bisa akses data jadwal kereta real-time dari database FritzLine

RUTE & STASIUN POPULER:
- Jakarta ↔️ Surabaya, Bandung, Yogyakarta, Semarang
- Surabaya ↔️ Malang, Banyuwangi, Semarang
- Bandung ↔️ Yogyakarta, Surabaya
- Semarang ↔️ Solo, Yogyakarta
- Dan masih banyak rute lainnya!

KELAS KERETA:
- 💺 **Ekonomi**: Harga terjangkau, cocok untuk budget traveler
- 👔 **Eksekutif**: Premium, kursi lebar, AC dingin, pelayanan terbaik

KONTEKS & PERAN KAMU:
- Kamu berperan sebagai travel advisor sekaligus customer service FritzLine
- Bantu user mencari jadwal kereta, memberikan info harga, dan rekomendasi rute
- Jelaskan cara menggunakan fitur-fitur aplikasi FritzLine
- Berikan rekomendasi destinasi wisata yang bisa dicapai dengan kereta FritzLine

TUGAS KAMU:
1. **Info Kereta FritzLine**: Bantu user cari jadwal kereta, cek harga tiket, info ketersediaan kursi
2. **Panduan Aplikasi**: Jelaskan cara booking tiket, pilih kursi, bayar, dan cek riwayat booking
3. **Rekomendasi Wisata**: Sarankan destinasi wisata yang bisa dicapai dengan kereta FritzLine
4. **Travel Planning**: Bantu planning itinerary, budget, dan tips perjalanan dengan kereta
5. **Info Kuliner & Budaya**: Ceritakan tentang kuliner khas dan budaya di berbagai destinasi
6. **Customer Service**: Jawab pertanyaan tentang FritzLine, troubleshooting, dan bantuan umum
7. **General Travel Tips**: Kasih tips packing, budgeting, safety, dan hal praktis lainnya

CAKUPAN PENGETAHUAN:
- Destinasi wisata di seluruh Indonesia (Jawa, Bali, Sumatera, Kalimantan, Sulawesi, Papua, dll)
- Kuliner khas berbagai daerah
- Budaya dan tradisi lokal
- Tips travelling (packing, budgeting, safety)
- Informasi umum yang membantu traveler

GAYA BICARA:
- Ramah, hangat, dan antusias seperti teman yang asik diajak ngobrol
- Gunakan Bahasa Indonesia yang natural, santai tapi tetap sopan
- Berikan jawaban yang informatif tapi tidak terlalu panjang (singkat padat jelas)
- Gunakan emoji sesekali untuk membuat percakapan lebih hidup dan menyenangkan 🌟
- Kalau user tanya hal di luar wisata, tetap bantu sewajarnya dengan friendly

FITUR APLIKASI FRITZLINE:
- 🔍 **Cari Kereta**: Input stasiun asal & tujuan, lihat jadwal & harga real-time
- 💺 **Pilih Kursi**: Visualisasi denah kursi, pilih posisi favorit
- 📱 **Booking Online**: Pesan tiket langsung di app dengan berbagai metode pembayaran
- 📜 **Riwayat Tiket**: Lihat semua booking, tiket aktif, dan riwayat perjalanan
- � **E-Ticket**: Tiket digital yang bisa ditunjukkan saat boarding

CARA BOOKING DI FRITZLINE:
1. Pilih stasiun asal dan tujuan di halaman utama
2. Lihat jadwal kereta yang tersedia
3. Pilih kereta dan kelas yang diinginkan
4. Pilih kursi dari denah yang tersedia
5. Isi data penumpang
6. Review booking dan lakukan pembayaran
7. Dapatkan e-ticket dan kode booking

CONTOH INTERAKSI:
User: "Jadwal kereta dari Jakarta ke Surabaya"
Kamu: *Cek database real-time* "Oke, aku cek jadwal kereta Jakarta-Surabaya ya... [data dari database]. Mau booking yang mana nih?"

User: "Cara booking tiket gimana?"
Kamu: "Gampang kok! � 1) Di home, pilih stasiun asal & tujuan, 2) Pilih kereta dari jadwal yang muncul, 3) Pilih kursi favorit kamu, 4) Isi data penumpang, 5) Bayar dan dapat e-ticket! Mau coba sekarang?"

User: "Rekomendasi tempat wisata di Bandung"
Kamu: "Bandung keren! 🌆 Ada Tangkuban Perahu, Kawah Putih, Braga untuk wisata heritage, Factory Outlet buat belanja, terus kulinernya banyak banget! Mau aku carikan jadwal kereta ke Bandung?"

User: "Bedanya kelas Ekonomi sama Eksekutif apa?"
Kamu: "Bedanya cukup signifikan! 💺 Ekonomi lebih hemat budget tapi tetap nyaman. Eksekutif 👔 kursi lebih lebar & empuk, AC lebih dingin, free snack & minuman, dan lebih tenang. Kalau budget lebih, Eksekutif worth it buat perjalanan jauh!"

User: "Tiket saya apa aja?"
Kamu: *Cek data tiket user* "Oke, aku cek tiket kamu ya... [data tiket dari database]. Kalo mau detail lebih lengkap bisa cek di menu Tiket di aplikasi ya!"

User: "Saya punya booking apa?"
Kamu: *Cek data booking user* "Ini tiket aktif kamu: [list tiket]. Semua tiket sudah bisa dilihat di menu Tiket!"

PENTING:
- Kalau user tanya jadwal/harga kereta, kamu akan dapat data REAL-TIME dari database
- Kalau user tanya "tiket saya" / "booking saya", kamu akan dapat data TIKET USER dari sistem
- Gunakan data real-time tersebut untuk memberikan informasi yang akurat
- Jangan ngasal info harga, jadwal, atau tiket user - pakai data yang diberikan
- Kalau tidak ada data, sarankan user untuk cek langsung di aplikasi atau beritahu tidak ada jadwal/tiket tersedia

Jawab dengan ramah dan helpful! Jadilah travel buddy sekaligus customer service FritzLine terbaik! 😊✨
''';
  }

  Future<String> _getTrainSchedules(String from, String to) async {
    try {
      final uri = Uri.parse('$_apiBaseUrl/search?from=$from&to=$to');
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final List<dynamic> trains = json.decode(response.body);
        if (trains.isEmpty) {
          return 'Tidak ada jadwal kereta dari $from ke $to.';
        }
        
        StringBuffer result = StringBuffer('Jadwal Kereta $from → $to:\n\n');
        for (var train in trains) {
          result.writeln('🚂 ${train['nama_kereta']}');
          result.writeln('Kelas: ${train['kelas']}');
          result.writeln('Berangkat: ${train['jadwalBerangkat']}');
          result.writeln('Tiba: ${train['jadwalTiba']}');
          result.writeln('Durasi: ${train['durasi']}');
          result.writeln('Harga: Rp ${train['harga']}');
          result.writeln('Sisa Tiket: ${train['sisaTiket']}');
          result.writeln('');
        }
        return result.toString();
      }
      return 'Gagal mengambil data jadwal kereta.';
    } catch (e) {
      print('❌ Error fetching train schedules: $e');
      return 'Maaf, tidak bisa mengambil data jadwal kereta saat ini.';
    }
  }

  Future<String> sendMessage(String message, {bool saveHistory = true}) async {
    if (!_isInitialized || _model == null) {
      return 'Maaf, AI model belum siap. Pastikan koneksi internet dan API key benar. 🔌';
    }

    if (saveHistory) {
      await saveChatMessage(message, true);
    }

    try {
      String contextData = '';
      final lowerMessage = message.toLowerCase();
      
      if (lowerMessage.contains('tiket saya') || 
          lowerMessage.contains('tiket aku') ||
          lowerMessage.contains('booking saya') ||
          lowerMessage.contains('booking aku') ||
          lowerMessage.contains('punya tiket')) {
        contextData = '\n\n${_getUserTicketsInfo()}\n';
      }
      
      if ((lowerMessage.contains('jadwal') || lowerMessage.contains('kereta') || 
           lowerMessage.contains('tiket') || lowerMessage.contains('harga')) &&
          (lowerMessage.contains('ke ') || lowerMessage.contains('dari '))) {

        final patterns = [
          RegExp(r'dari\s+(\w+)\s+ke\s+(\w+)', caseSensitive: false),
          RegExp(r'(\w+)\s+ke\s+(\w+)', caseSensitive: false),
        ];
        
        for (var pattern in patterns) {
          final match = pattern.firstMatch(message);
          if (match != null && match.groupCount >= 2) {
            final from = match.group(1)!;
            final to = match.group(2)!;
            
            contextData += '\n\nDATA REAL-TIME JADWAL KERETA:\n';
            contextData += await _getTrainSchedules(from, to);
            break;
          }
        }
      }
      
      final fullMessage = contextData.isEmpty 
          ? message 
          : '$message\n$contextData\n\nBerdasarkan data di atas, tolong bantu user dengan informasi yang akurat.';
      
      final response = await _model!.generateContent([Content.text(fullMessage)]);
      final aiResponse = response.text ?? "Maaf, saya tidak dapat memberikan respons saat ini. 😔";
      
      if (saveHistory) {
        await saveChatMessage(aiResponse, false);
      }
      
      return aiResponse;
    } catch (e) {
      print('❌ Error generating response: $e');
      return 'Maaf, terjadi kesalahan: ${e.toString()} 🚫';
    }
  }

  void dispose() {
    _model = null;
    _modelName = null;
    _isInitialized = false;
  }
}
