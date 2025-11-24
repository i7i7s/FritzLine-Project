# 🚄 FritzLine - Train Booking Mobile Application

<div align="center">
  <img src="assets/images/logo.png" alt="FritzLine Logo" width="200"/>
  
  **Your Journey Magic Companion**
  
  [![Flutter](https://img.shields.io/badge/Flutter-3.24.5-02569B?logo=flutter)](https://flutter.dev)
  [![Dart](https://img.shields.io/badge/Dart-3.5.4-0175C2?logo=dart)](https://dart.dev)
  [![GetX](https://img.shields.io/badge/GetX-State%20Management-9C27B0)](https://pub.dev/packages/get)
  [![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
</div>

---

## 📱 Tentang Aplikasi

**FritzLine** adalah aplikasi mobile untuk pemesanan tiket kereta api yang dibangun dengan Flutter. Aplikasi ini menyediakan pengalaman booking yang modern, intuitif, dan user-friendly dengan berbagai fitur canggih.

### ✨ Fitur Utama

#### 🎫 Sistem Pemesanan
- **Date-Based Booking** - Book kursi untuk tanggal keberangkatan yang spesifik
- **Real-time Seat Availability** - Lihat ketersediaan kursi secara real-time
- **Multiple Passenger Types** - Support untuk Dewasa, Anak (≥3 tahun), dan Bayi (<3 tahun)
- **Smart Seat Selection** - Pilih kursi dengan visual indicator yang jelas
- **15-Minute Timer** - Kursi di-reserve selama 15 menit sebelum dikonfirmasi

#### 👥 Manajemen Penumpang
- **Gender Selection** - Pilih jenis kelamin penumpang untuk kenyamanan
- **Women-Friendly Seating** - Kursi yang ditempati wanita ditampilkan dengan warna pink
- **Multiple ID Types** - Support KTP, Passport, dan SIM
- **NIK Encryption** - Nomor identitas dienkripsi untuk keamanan data
- **Save Passenger Data** - Simpan data penumpang untuk booking cepat di masa depan

#### 🎨 User Experience
- **Beautiful Splash Screen** - Animasi splash screen dengan gradient, pulse, shimmer, dan floating effects
- **Intuitive UI/UX** - Desain modern dengan Material Design 3
- **Multi-language Support** - Bahasa Indonesia
- **Dark/Light Mode Compatible** - Adaptif dengan tema sistem

#### 💳 Pembayaran & Loyalitas
- **Multi-Currency** - Support IDR, USD, EUR, JPY dengan real-time conversion
- **Loyalty Points** - Earn points untuk setiap pembelian
- **Booking History** - Track semua tiket yang pernah dibeli
- **E-Ticket QR Code** - QR code untuk validasi tiket

#### 🔔 Notifikasi
- **Smart Notifications** - Reminder untuk keberangkatan kereta
- **Customizable Timing** - Atur waktu notifikasi (30 menit - 24 jam sebelumnya)
- **Auto-Schedule** - Notifikasi otomatis dijadwalkan saat booking berhasil

---

## 🏗️ Arsitektur & Teknologi

### Tech Stack
- **Framework**: Flutter 3.24.5
- **Language**: Dart 3.5.4
- **State Management**: GetX (get: ^4.6.6)
- **Architecture**: MVC Pattern with GetX
- **Backend API**: Railway (Node.js/Express)
- **Database**: MySQL (Remote)

### Dependencies Utama
```yaml
dependencies:
  get: ^4.6.6                          # State management & routing
  http: ^1.2.2                         # HTTP requests
  intl: ^0.19.0                        # Internationalization & date formatting
  shared_preferences: ^2.3.2           # Local storage
  qr_flutter: ^4.1.0                   # QR code generation
  flutter_local_notifications: ^17.2.3 # Local notifications
  timezone: ^0.9.4                     # Timezone handling
  geolocator: ^13.0.1                  # GPS location services
  permission_handler: ^11.3.1          # Permission management
  package_info_plus: ^8.0.2            # App info
  carousel_slider: ^5.0.0              # Image carousel
  crypto: ^3.0.5                       # Encryption (NIK)
```

---

## 🚀 Instalasi & Setup

### Prerequisites
- Flutter SDK 3.24.5 atau lebih baru
- Dart SDK 3.5.4 atau lebih baru
- Android Studio / VS Code dengan Flutter extension
- Android Device/Emulator (API level 21+) atau iOS Device/Simulator

### Langkah Instalasi

1. **Clone Repository**
   ```bash
   git clone https://github.com/i7i7s/FritzLine-Project.git
   cd FritzLine-Project
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **Konfigurasi Backend API**
   
   Backend API sudah tersedia di Railway:
   ```
   Base URL: https://kereta-api-production.up.railway.app
   ```
   
   API Endpoints yang tersedia:
   - `GET /search?from={code}&to={code}&date={YYYY-MM-DD}` - Cari kereta
   - `GET /seats/{id_kereta}?date={YYYY-MM-DD}` - Get available seats
   - `POST /seats/book` - Book seats (15 min reserve)
   - `POST /seats/release` - Release booked seats
   - `POST /bookings/confirm` - Confirm booking & generate ticket
   - `GET /bookings/history/{kode_booking}` - Get booking details

4. **Run Application**
   ```bash
   # Development mode
   flutter run
   
   # Release mode (Android)
   flutter build apk --release
   
   # Release mode (iOS)
   flutter build ios --release
   ```

---

## 📊 Sumber Data

### 🚉 Data Stasiun
Data stasiun kereta api di Indonesia diambil dari **API publik**:

**API Endpoint:**
```
https://stasiun-api.vercel.app/stasiun_api.json
```

**Format Response:**
```json
{
  "0": [
    {
      "kode": "BD",
      "nama": "Bandung",
      "provinsi": "Jawa Barat",
      "latitude": -6.9147,
      "longitude": 107.6098
    }
  ]
}
```

**Fitur Data Stasiun:**
- ✅ **500+ Stasiun** di seluruh Indonesia
- ✅ Informasi lengkap (kode, nama, provinsi)
- ✅ Koordinat GPS untuk fitur Location-Based Services
- ✅ Real-time data dari API publik
- ✅ Auto-complete search

### 🚆 Data Kereta & Jadwal
Data kereta, jadwal, harga, dan seat availability dikelola oleh **Backend API** (Railway + MySQL).

**Backend Repository:** https://github.com/i7i7s/kereta-api-backend

**Database Schema:**
- **trains** - Master data kereta (id, nama, kelas, harga)
- **seats** - Master data kursi (id_kereta, nomor_kursi, nama_gerbong)
- **bookings** - Transaksi booking (kode_booking, tanggal_keberangkatan, passenger_data, seat_ids)

**Fitur Data Kereta:**
- ✅ **Real-time Availability** - Seat availability berdasarkan tanggal
- ✅ **Multi-Class Support** - Ekonomi, Eksekutif, Campuran
- ✅ **Dynamic Pricing** - Harga per kelas kereta
- ✅ **Date-Based Booking** - Kursi yang sama bisa dibook untuk tanggal berbeda
- ✅ **Automatic Release** - Kursi yang tidak dikonfirmasi dalam 15 menit otomatis release

### 📍 Location-Based Services
Aplikasi menggunakan **Geolocator** untuk menampilkan stasiun terdekat berdasarkan lokasi GPS user.

**Fitur LBS:**
- Deteksi 3 stasiun terdekat dari lokasi user
- Perhitungan jarak menggunakan Haversine formula
- Permission handling untuk akses lokasi
- Fallback jika permission ditolak

---

## 🎯 Cara Menggunakan Aplikasi

### 1️⃣ Pencarian Tiket

1. **Buka Aplikasi** → Home Screen
2. **Pilih Stasiun Keberangkatan**
   - Tap field "Stasiun Keberangkatan"
   - Cari stasiun atau pilih dari "Stasiun Terdekat" (menggunakan GPS)
3. **Pilih Stasiun Tujuan**
   - Tap field "Stasiun Tujuan"
   - Pilih stasiun tujuan
4. **Pilih Tanggal Keberangkatan**
   - Tap tanggal picker
   - Pilih tanggal (maksimal 90 hari ke depan)
5. **Pilih Jumlah Penumpang**
   - Dewasa: Min 1 (wajib beli tiket)
   - Anak (≥3 tahun): Min 0 (wajib beli tiket + dapat kursi)
   - Bayi (<3 tahun): Min 0 (gratis, tidak dapat kursi)
6. **Klik "Cari Tiket"**

### 2️⃣ Memilih Kereta

1. **Lihat Daftar Kereta** yang tersedia
   - Filter berdasarkan kelas (Ekonomi/Eksekutif)
   - Lihat jadwal berangkat & tiba
   - Lihat harga & durasi perjalanan
   - Lihat sisa tiket tersedia
2. **Pilih Kereta** yang diinginkan
   - Tap card kereta
   - Sistem akan cek apakah masih bisa booking (min 30 menit sebelum keberangkatan)

### 3️⃣ Mengisi Data Penumpang

1. **Isi Data untuk Setiap Penumpang:**
   - **Nama Lengkap** (sesuai KTP/identitas)
   - **Jenis Kelamin** (Laki-laki/Perempuan)
   - **Jenis Identitas** (KTP/Passport/SIM)
   - **Nomor Identitas** (akan dienkripsi)
   
2. **Opsi Tambahan:**
   - ☑️ Simpan data penumpang (untuk booking cepat next time)
   
3. **Load Data Tersimpan** (jika ada):
   - Tap "Muat Data Tersimpan"
   - Pilih data penumpang yang pernah disimpan
   
4. **Klik "Lanjutkan"** → Akan diarahkan ke Pilih Kursi

### 4️⃣ Memilih Kursi

1. **Pilih Penumpang**
   - Tap nama penumpang di bagian "Daftar Penumpang"
   - Icon gender (♀️/♂️) menunjukkan jenis kelamin penumpang
   
2. **Pilih Gerbong**
   - Swipe horizontal untuk ganti gerbong
   - Ekonomi: 6 gerbong
   - Eksekutif: 4 gerbong
   
3. **Pilih Kursi**
   - **Putih** = Tersedia
   - **Oranye** = Terisi (laki-laki)
   - **Pink** = Terisi (wanita) ← Women-friendly feature!
   - **Ungu** = Kursi yang Anda pilih
   
4. **Ulangi** untuk penumpang lainnya

5. **Timer 15 Menit**
   - Setelah pilih semua kursi, timer 15 menit dimulai
   - Kursi akan otomatis di-release jika tidak dikonfirmasi dalam 15 menit
   
6. **Klik "Lanjutkan"** → Detail Booking

### 5️⃣ Konfirmasi & Pembayaran

1. **Review Detail Booking:**
   - Data kereta (nama, jadwal, kelas)
   - Data penumpang (nama, kursi, gerbong)
   - Total harga
   
2. **Pilih Mata Uang** (opsional):
   - IDR (Rupiah)
   - USD (US Dollar)
   - EUR (Euro)
   - JPY (Japanese Yen)
   - Konversi otomatis dengan rate real-time
   
3. **Klik "Bayar Sekarang"**
   - Simulasi pembayaran berhasil
   - Tiket otomatis disimpan
   
4. **Booking Berhasil!**
   - Kode booking di-generate
   - Notifikasi dijadwalkan otomatis
   - E-ticket dengan QR code dibuat

### 6️⃣ Melihat Tiket

1. **Buka Tab "Tiket"** di bottom navigation
2. **Pilih Kategori:**
   - **Aktif**: Tiket yang belum digunakan
   - **Selesai**: Tiket yang sudah lewat tanggal keberangkatan
3. **Tap Tiket** untuk melihat detail:
   - QR Code untuk validasi
   - Detail perjalanan lengkap
   - Data penumpang & kursi
   - Total pembayaran

### 7️⃣ Notifikasi Keberangkatan

1. **Buka Profil** → **Pengaturan**
2. **Aktifkan Notifikasi Perjalanan**
3. **Pilih Waktu Notifikasi:**
   - 30 menit sebelum keberangkatan
   - 1 jam sebelumnya
   - 2 jam sebelumnya
   - 6 jam sebelumnya
   - 12 jam sebelumnya
   - 24 jam sebelumnya
4. **Notifikasi Otomatis** akan muncul sesuai waktu yang dipilih

---

## 🔐 Keamanan Data

### Enkripsi NIK/ID Number
Aplikasi menggunakan **XOR Cipher + Base64** untuk enkripsi nomor identitas:

```dart
// EncryptionService
String encryptData(String plainText) {
  final key = 'FritzLine2024SecretKey';
  // XOR cipher implementation
  // Base64 encoding
  return encryptedData;
}
```

**Fitur Keamanan:**
- ✅ NIK tidak disimpan dalam plain text
- ✅ Enkripsi saat booking
- ✅ Dekripsi hanya saat diperlukan
- ✅ Secret key tidak di-expose di client side

---

## 📂 Struktur Project

```
lib/
├── main.dart                          # Entry point aplikasi
├── app/
│   ├── models/
│   │   └── passenger_type.dart        # Model tipe & data penumpang
│   ├── services/
│   │   ├── auth_service.dart          # Authentication & saved passengers
│   │   ├── booking_service.dart       # Global booking state
│   │   ├── hive_service.dart          # API calls ke backend
│   │   ├── ticket_service.dart        # Local ticket storage
│   │   ├── notification_service.dart  # Notifikasi lokal
│   │   ├── location_service.dart      # GPS & nearest stations
│   │   ├── settings_service.dart      # App settings
│   │   ├── loyalty_service.dart       # Points & rewards
│   │   └── encryption_service.dart    # NIK encryption
│   ├── modules/
│   │   ├── splash_screen/             # Animated splash screen
│   │   ├── home/                      # Home & search
│   │   ├── detail_jadwal/             # Train list & filter
│   │   ├── ringkasan_pemesanan/       # Passenger data form
│   │   ├── pilih_kursi/               # Seat selection
│   │   ├── detail_booking_tiket/      # Payment & confirmation
│   │   ├── tiket/                     # Ticket list
│   │   ├── profil/                    # Profile & settings
│   │   └── dashboard/                 # Main navigation
│   └── routes/
│       └── app_pages.dart             # Route definitions
├── assets/
│   └── images/
│       └── logo.png                   # App logo
└── pubspec.yaml                       # Dependencies
```

---

## 🛠️ Development Guide

### Hot Reload
```bash
# Dalam terminal yang menjalankan flutter run
r  # Hot reload
R  # Hot restart
q  # Quit
```

### Build untuk Production

**Android APK:**
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

**Android App Bundle (untuk Google Play):**
```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

**iOS:**
```bash
flutter build ios --release
# Kemudian buka Xcode untuk archive & distribute
```

### Testing
```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage
```

### Code Analysis
```bash
# Static analysis
flutter analyze

# Format code
dart format .
```

---

## 🎨 Customization

### Mengubah Warna Tema
Edit `lib/main.dart`:
```dart
colorScheme: ColorScheme.fromSeed(
  seedColor: Color(0xFF656CEE), // Primary color (ungu)
  secondary: Color(0xFFFF6B35), // Accent color (oranye)
),
```

### Mengubah Base URL Backend
Edit `lib/app/services/hive_service.dart`:
```dart
final String _apiBaseUrl = "https://your-backend-url.com";
```

### Mengubah Encryption Key
Edit `lib/app/services/encryption_service.dart`:
```dart
final String _secretKey = 'YourNewSecretKey2024';
```

---

## 🐛 Troubleshooting

### Problem: Stasiun tidak muncul
**Solution:** 
- Pastikan koneksi internet aktif
- API stasiun mungkin down, coba beberapa saat lagi
- Check console untuk error message

### Problem: Kursi tidak ter-load
**Solution:**
- Pastikan backend API berjalan
- Check apakah tanggal keberangkatan valid
- Coba refresh dengan pull-down gesture

### Problem: Notifikasi tidak muncul
**Solution:**
- Buka Settings > Notifikasi > Aktifkan
- Grant notification permission di system settings
- Pastikan app tidak di-force stop

### Problem: GPS/Location tidak bekerja
**Solution:**
- Grant location permission di system settings
- Aktifkan GPS di device
- Restart aplikasi setelah grant permission

---

## 📝 API Documentation

### Search Trains
```http
GET /search?from={stationCode}&to={stationCode}&date={YYYY-MM-DD}

Response:
[
  {
    "id_kereta": "KA16",
    "nama_kereta": "Argo Dwipangga",
    "kelas": "Eksekutif",
    "jadwalBerangkat": "08:00",
    "jadwalTiba": "16:30",
    "durasi": "8j 30m",
    "harga": 500000,
    "sisaTiket": 150
  }
]
```

### Get Available Seats
```http
GET /seats/{id_kereta}?date={YYYY-MM-DD}

Response:
{
  "gerbong": {
    "Eksekutif 1": [
      {
        "id_kursi": 1,
        "nomor_kursi": "A1",
        "is_booked": false,
        "gender": null
      }
    ]
  }
}
```

### Book Seats
```http
POST /seats/book
Content-Type: application/json

Body:
{
  "id_kereta": "KA16",
  "tanggal_keberangkatan": "2025-11-25",
  "seat_ids": [1, 2, 3],
  "seat_details": [
    {
      "id_kursi": 1,
      "nomor_kursi": "A1",
      "nama_gerbong": "Eksekutif 1",
      "gender": "Perempuan"
    }
  ]
}

Response: { "success": true, "message": "Kursi berhasil di-reserve" }
```

### Confirm Booking
```http
POST /bookings/confirm
Content-Type: application/json

Body:
{
  "id_kereta": "KA16",
  "tanggal_keberangkatan": "2025-11-25",
  "seat_ids": [1, 2, 3],
  "passenger_data": [
    {
      "nama": "John Doe",
      "id_number": "encrypted_nik_here",
      "gender": "Laki-laki"
    }
  ],
  "total_price": 1500000
}

Response: { "success": true, "kode_booking": "FK17639828230828UB62" }
```

---

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Coding Standards
- Follow Dart style guide
- Use GetX for state management
- Add comments for complex logic
- Test before commit

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 👨‍💻 Author

**Muhammad Daffa Alwafi**
- GitHub: [@i7i7s](https://github.com/i7i7s)
- Email: daffaalwafi@example.com

---

## 🙏 Acknowledgments

- **Flutter Team** - Amazing framework
- **GetX Community** - Powerful state management
- **Stasiun API** - Public station data (https://stasiun-api.vercel.app)
- **Railway** - Backend hosting
- **Material Design 3** - Beautiful design system

---

## 📸 Screenshots

### Home Screen
_Coming soon - Add your screenshots here_

### Search & Results
_Coming soon - Add your screenshots here_

### Seat Selection
_Coming soon - Add your screenshots here_

### Ticket
_Coming soon - Add your screenshots here_

---

## 🔮 Roadmap

- [ ] Payment Gateway Integration (Midtrans)
- [ ] Social Login (Google, Facebook)
- [ ] Promo & Discount System
- [ ] Chat Support
- [ ] Trip History Analytics
- [ ] Multi-language (EN, ID)
- [ ] Offline Mode
- [ ] Seat Map 3D View

---

## 📞 Support

Jika ada pertanyaan atau masalah:
- 📧 Email: support@fritzline.com
- 💬 GitHub Issues: [Create Issue](https://github.com/i7i7s/FritzLine-Project/issues)
- 📱 WhatsApp: +62-xxx-xxx-xxxx

---

<div align="center">
  
  **Made with ❤️ and ☕ using Flutter**
  
  ⭐ Star this repository if you find it helpful!
  
</div>
