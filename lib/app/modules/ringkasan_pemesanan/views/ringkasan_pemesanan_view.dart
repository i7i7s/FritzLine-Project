import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/ringkasan_pemesanan_controller.dart';
// Import DottedLine dari detail_jadwal_view (jika file-nya terpisah)
// Jika DottedLine ada di detail_jadwal_view.dart, Anda bisa pindahkan
// ke folder /widgets/ atau copy-paste ke file ini.
// Untuk sementara, saya asumsikan Anda akan copy-paste.

class RingkasanPemesananView extends GetView<RingkasanPemesananController> {
  const RingkasanPemesananView({super.key});

  @override
  Widget build(BuildContext context) {
    // Format mata uang
    final currencyFormatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

    return Scaffold(
      body: Stack(
        children: [
          // Background konsisten
          Container(
            width: Get.width,
            height: Get.height,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/bg.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Konten Utama
          Column(
            children: [
              _buildCustomAppBar(),
              // Bagian yang bisa di-scroll
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Kartu Kereta
                      _buildTrainCard(currencyFormatter),
                      const SizedBox(height: 24),
                      // Penumpang Tersimpan
                      _buildSavedPassengers(),
                      const SizedBox(height: 24),
                      // Detail Penumpang
                      _buildPassengerDetails(),
                      const SizedBox(height: 120), // Spacer untuk tombol bawah
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Tombol Bawah
          _buildBottomButtons(context),
        ],
      ),
    );
  }

  // Widget untuk App Bar Kustom
  Widget _buildCustomAppBar() {
    return SafeArea(
      bottom: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        width: Get.width,
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xFF333E63)),
              onPressed: () => Get.back(),
            ),
            const SizedBox(width: 10),
            const Text(
              "Ringkasan pemesanan",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333E63),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget untuk Kartu Kereta (Mirip detail_jadwal)
  Widget _buildTrainCard(NumberFormat currencyFormatter) {
    // Ambil data dari controller (yang didapat dari arguments)
    final train = controller.trainData;
    if (train.isEmpty) {
      return const Center(child: Text("Memuat data kereta..."));
    }

    return Card(
      elevation: 3,
      shadowColor: Colors.black.withOpacity(0.1),
      margin: const EdgeInsets.only(top: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Baris Atas: Nama Kereta & Harga
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  train["nama"]!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      currencyFormatter.format(int.parse(train["harga"]!)),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF656CEE),
                      ),
                    ),
                    Text(
                      "${controller.passengerCount.value} penumpang",
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Baris Tengah: Rute & Jam
            Row(
              children: [
                _buildTimeColumn(
                    train["berangkat_kode"]!, train["berangkat_jam"]!),
                const SizedBox(width: 10),
                const Expanded(child: DottedLine()), // Gunakan DottedLine
                const SizedBox(width: 10),
                _buildTimeColumn(train["tiba_kode"]!, train["tiba_jam"]!,
                    align: CrossAxisAlignment.end),
              ],
            ),
            const SizedBox(height: 16),
            // Baris Bawah: Kelas, Durasi & Tombol
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTag(train["kelas"]!),
                    const SizedBox(height: 5),
                    Text(
                      train["durasi"]!,
                      style:
                          const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D63C6).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_forward,
                        color: Color(0xFF0D63C6)),
                    onPressed: () => Get.back(), // Tombol ini bawa kembali
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widget untuk Penumpang Tersimpan
  Widget _buildSavedPassengers() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.favorite, color: Colors.deepOrange.shade400, size: 20),
            const SizedBox(width: 8),
            const Text(
              "Penumpang tersimpan",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333E63),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: controller.savedPassengers.map((passenger) {
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Container(
                  width: 150,
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        passenger["nama"]!,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        passenger["email"]!,
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          onPressed: () {
                            // Logic untuk isi form
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange.shade700,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding:
                                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text("Tambahkan",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 10)),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // Widget untuk Detail Penumpang (Form)
  Widget _buildPassengerDetails() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.people_alt,
                    color: Colors.deepOrange.shade400, size: 20),
                const SizedBox(width: 8),
                const Text(
                  "Detail penumpang",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333E63),
                  ),
                ),
              ],
            ),
            TextButton.icon(
              onPressed: () {},
              icon: Icon(Icons.add, size: 16, color: Colors.orange.shade700),
              label: Text(
                "Tambah penumpang",
                style: TextStyle(color: Colors.orange.shade700, fontSize: 12),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Sesuai screenshot, ini adalah ExpansionTile
        Obx(() => ExpansionTile(
              initiallyExpanded: controller.isExpanded.value,
              onExpansionChanged: controller.toggleExpansion,
              backgroundColor: Colors.white.withOpacity(0.8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              collapsedShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              title: Row(
                children: [
                  Icon(Icons.account_circle,
                      color: Colors.orange.shade700, size: 24),
                  const SizedBox(width: 8),
                  const Text(
                    "Penumpang 1",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87),
                  ),
                ],
              ),
              children: [
                // Konten Form di dalam tile
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Column(
                    children: [
                      // Baris Jenis & Nomor Identitas
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: _buildDropdownField(),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 3,
                            child: _buildTextField(
                              label: "Nomor identitas",
                              controller: controller.idNumberController,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Baris Nama Lengkap
                      _buildTextField(
                        label: "Nama lengkap",
                        controller: controller.fullNameController,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Penumpang bayi tidak mendapat kursi sendiri. Penumpang dibawah 18 tahun dapat mengisi dengan nomor tanda pengenal",
                        style:
                            TextStyle(color: Colors.grey.shade600, fontSize: 12),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ],
            )),
      ],
    );
  }

  // Widget untuk Tombol Bawah
  Widget _buildBottomButtons(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding:
            EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).padding.bottom + 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Tombol Pilih Kursi
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  // Navigasi ke Pilih Kursi
                  Get.toNamed('/pilih-kursi');
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  foregroundColor: const Color(0xFF656CEE),
                  side: const BorderSide(color: Color(0xFF656CEE), width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "PILIH KURSI",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Tombol Lanjut
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  // Logic lanjut (ke pembayaran, dll)
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.orange.shade700,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "LANJUT",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper untuk Form
  Widget _buildTextField(
      {required String label, required TextEditingController controller}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            isDense: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  // Helper untuk Dropdown
  Widget _buildDropdownField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Jenis Identitas",
            style: TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Obx(() => DropdownButtonFormField<String>(
              value: controller.selectedIdType.value,
              items: controller.idTypes.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, style: const TextStyle(fontSize: 14)),
                );
              }).toList(),
              onChanged: controller.changeIdType,
              decoration: InputDecoration(
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            )),
      ],
    );
  }

  // Helper widget (copy dari detail_jadwal_view)
  Widget _buildTimeColumn(String code, String time,
      {CrossAxisAlignment align = CrossAxisAlignment.start}) {
    return Column(
      crossAxisAlignment: align,
      children: [
        Text(
          code,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          time,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
  }

  // Helper widget (copy dari detail_jadwal_view)
  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.orange.shade100,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.orange.shade800,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}

// Widget kustom untuk garis putus-putus
// (Letakkan di bawah kelas RingkasanPemesananView)
class DottedLine extends StatelessWidget {
  final double height;
  final Color color;
  final double dashWidth;
  const DottedLine(
      {super.key,
      this.height = 1,
      this.color = Colors.grey,
      this.dashWidth = 4.0});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final boxWidth = constraints.constrainWidth();
        final dashCount = (boxWidth / (2 * dashWidth)).floor();
        return Flex(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: height,
              child: DecoratedBox(
                decoration: BoxDecoration(color: color),
              ),
            );
          }),
        );
      },
    );
  }
}