import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; // Untuk format harga
import '../controllers/detail_jadwal_controller.dart';

class DetailJadwalView extends GetView<DetailJadwalController> {
  const DetailJadwalView({super.key});

  @override
  Widget build(BuildContext context) {
    // Format mata uang
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );

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
          // Konten
          Column(
            children: [
              _buildCustomAppBar(),
              _buildDateScroller(),
              _buildTrainList(currencyFormatter),
            ],
          ),
          // Tombol Filter
          _buildFilterButton(),
        ],
      ),
    );
  }

  // Widget untuk App Bar Kustom
  Widget _buildCustomAppBar() {
    return SafeArea(
      bottom: false, // Hanya safe area di atas
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
            Obx(
              () => Text(
                // Menampilkan nama kota, bukan kode
                "${controller.departure['name']} - ${controller.arrival['name']}",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333E63),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget untuk Scroller Tanggal
  Widget _buildDateScroller() {
    return Container(
      height: 70, // Tinggi tetap untuk scroller
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        // Center scroll di tanggal yg dipilih (butuh scroll controller)
        // Untuk simple, kita mulai dari kiri saja
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Obx(
          () => Row(
            children: controller.dateList.map((date) {
              // Cek apakah tanggal ini adalah tanggal yang aktif
              bool isActive =
                  controller.activeDate.value.day == date.day &&
                  controller.activeDate.value.month == date.month &&
                  controller.activeDate.value.year == date.year;

              return GestureDetector(
                onTap: () => controller.changeActiveDate(date),
                child: Container(
                  width: 55, // Lebar kartu tanggal
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: isActive
                        ? const Color(0xFF0D63C6) // Biru Sesuai Screenshot
                        : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        date.day.toString(), // 15, 16, 17
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isActive ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        controller.getDayAbbreviation(date), // SAB, MIN, SEN
                        style: TextStyle(
                          fontSize: 12,
                          color: isActive ? Colors.white70 : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  // Widget untuk List Kereta
  Widget _buildTrainList(NumberFormat currencyFormatter) {
    return Expanded(
      child: Obx(
        () => ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          itemCount: controller.trainList.length,
          itemBuilder: (context, index) {
            final train = controller.trainList[index];

            return Card(
              elevation: 3,
              shadowColor: Colors.black.withOpacity(0.1),
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                              currencyFormatter.format(
                                int.parse(train["harga"]!),
                              ),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF656CEE), // Ungu
                              ),
                            ),
                            if (train["sisa_tiket"] != null)
                              Text(
                                "Sisa ${train["sisa_tiket"]}",
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.red,
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
                          train["berangkat_kode"]!,
                          train["berangkat_jam"]!,
                        ),
                        const SizedBox(width: 10),
                        // Garis putus-putus
                        const Expanded(child: DottedLine()),
                        const SizedBox(width: 10),
                        _buildTimeColumn(
                          train["tiba_kode"]!,
                          train["tiba_jam"]!,
                          align: CrossAxisAlignment.end,
                        ),
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
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        // Tombol Panah
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF0D63C6).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.arrow_forward,
                              color: Color(0xFF0D63C6),
                            ),

                            // --- PERUBAHAN DI SINI ---
                            onPressed: () {
                              // Navigasi ke ringkasan pemesanan
                              Get.toNamed(
                                '/ringkasan-pemesanan', // Gunakan rute baru
                                arguments: train, // Kirim data kereta
                              );
                            },
                            // --- AKHIR PERUBAHAN ---
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Widget untuk Tombol Filter
  Widget _buildFilterButton() {
    return Positioned(
      bottom: 30,
      left: 0,
      right: 0,
      child: Center(
        child: ElevatedButton.icon(
          onPressed: () {
            // Logic filter (kosongkan dulu)
          },
          icon: const Icon(Icons.filter_list, color: Colors.white),
          label: const Text(
            "FILTER",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange.shade700,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
      ),
    );
  }

  // Helper widget untuk tag (Ekonomi-A, dll)
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

  // Helper widget untuk info jam
  Widget _buildTimeColumn(
    String code,
    String time, {
    CrossAxisAlignment align = CrossAxisAlignment.start,
  }) {
    return Column(
      crossAxisAlignment: align,
      children: [
        Text(
          code,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(time, style: const TextStyle(fontSize: 14, color: Colors.grey)),
      ],
    );
  }
}

// Widget kustom untuk garis putus-putus
// (Letakkan di bawah kelas DetailJadwalView)
class DottedLine extends StatelessWidget {
  final double height;
  final Color color;
  final double dashWidth;
  const DottedLine({
    super.key,
    this.height = 1,
    this.color = Colors.grey,
    this.dashWidth = 4.0,
  });

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
              child: DecoratedBox(decoration: BoxDecoration(color: color)),
            );
          }),
        );
      },
    );
  }
}
