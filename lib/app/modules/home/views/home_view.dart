import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => Stack(
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
          // IndexedStack untuk menyimpan state setiap halaman/tab
          IndexedStack(
            index: controller.tabIndex.value,
            children: [
              _buildBerandaPage(context), // Tab 0: Beranda
              _buildTiketPage(), // Tab 1: Tiket
              _buildProfilPage(), // Tab 2: Profil
            ],
          ),
        ],
      )),
      bottomNavigationBar: Obx(() => BottomNavigationBar(
        currentIndex: controller.tabIndex.value,
        onTap: controller.changeTabIndex,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF656CEE),
        unselectedItemColor: Colors.grey,
        elevation: 10,
        type: BottomNavigationBarType.fixed, // Mencegah item bergeser
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.confirmation_number_rounded),
            label: 'Tiket',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Profil',
          ),
        ],
      )),
    );
  }

  // Halaman Tab 0: Beranda
  Widget _buildBerandaPage(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Mau pergi ke\nmana kali ini?",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333E63),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.menu, size: 30, color: Color(0xFF333E63)),
                  onPressed: () {
                    // Logika untuk membuka drawer (jika ada)
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Kartu Booking
            _buildBookingCard(context),

            const SizedBox(height: 30),

            // Section "Tiket saya"
            const Text(
              "Tiket saya",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333E63),
              ),
            ),
            const SizedBox(height: 10),
            _buildMyTicketsList(),

            const SizedBox(height: 30),

            // Section "Berita"
            const Text(
              "Berita",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333E63),
              ),
            ),
            const SizedBox(height: 10),
            _buildNewsList(),

            const SizedBox(height: 20), // Padding di bawah
          ],
        ),
      ),
    );
  }

  // Widget untuk Kartu Booking (DENGAN NAVIGASI)
  Widget _buildBookingCard(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Row Keberangkatan & Tujuan
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                Expanded(
                  child: GestureDetector(
                    onTap: () => controller.showCitySelection(context, true),
                    child: Obx(() => _buildStationInfo(
                          "Keberangkatan",
                          controller.selectedDeparture['code']!,
                          "Stasiun ${controller.selectedDeparture['name']!}",
                        )),
                  ),
                ),

                // Tombol Swap
                GestureDetector(
                  onTap: () => controller.swapCities(),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 25.0, left: 8, right: 8), 
                    child: const Icon(Icons.swap_horiz, color: Color(0xFF656CEE), size: 28),
                  ),
                ),

                Expanded(
                  child: GestureDetector(
                    onTap: () => controller.showCitySelection(context, false),
                    child: Obx(() => _buildStationInfo(
                          "Tujuan",
                          controller.selectedArrival['code']!,
                          "Stasiun ${controller.selectedArrival['name']!}",
                          align: CrossAxisAlignment.end,
                        )),
                  ),
                ),
              ],
            ),
            const Divider(height: 25, thickness: 1),

            // Row Tanggal & Tipe Pergi
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Tombol Tanggal
                GestureDetector(
                  onTap: () => controller.selectDate(context),
                  child: Obx(() => _buildInfoColumn(
                        "Tanggal keberangkatan",
                        controller.getFormattedDate(controller.selectedDate.value),
                      )),
                ),
                // Switch "Pulang pergi"
                Row(
                  children: [
                    Obx(() => Switch(
                      value: controller.isRoundTrip.value,
                      onChanged: (val) => controller.toggleRoundTrip(val),
                      activeColor: const Color(0xFF656CEE),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    )),
                    const Text("Pulang pergi", style: TextStyle(fontSize: 12)),
                  ],
                ),
              ],
            ),
            const Divider(height: 25, thickness: 1),

            // Row Penumpang & Cari Tiket
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Jumlah penumpang",
                        style: TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        _buildPassengerButton(Icons.remove, controller.decrementPassenger),
                        Obx(() => Text(" ${controller.passengerCount.value} ",
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold))),
                        _buildPassengerButton(Icons.add, controller.incrementPassenger),
                      ],
                    )
                  ],
                ),
                
                // === INI BAGIAN YANG DIUPDATE ===
                ElevatedButton(
                  onPressed: () {
                    // Navigasi ke halaman detail jadwal
                    Get.toNamed(
                      '/detail-jadwal', // Pastikan route ini ada di app_pages
                      arguments: {
                        "departure": controller.selectedDeparture,
                        "arrival": controller.selectedArrival,
                        "date": controller.selectedDate.value,
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF656CEE),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: const Text("CARI TIKET",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                // === AKHIR BAGIAN YANG DIUPDATE ===
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper untuk info stasiun (Dengan fix layout)
  Widget _buildStationInfo(String title, String code, String station,
      {CrossAxisAlignment align = CrossAxisAlignment.start}) {
    return Column(
      crossAxisAlignment: align,
      children: [
        Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 5),
        Text(code,
            style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333E63))),
        const SizedBox(height: 5),
        
        // Membungkus Text dengan Row + Flexible untuk memaksa wrapping
        Row(
          mainAxisAlignment: (align == CrossAxisAlignment.end) 
              ? MainAxisAlignment.end 
              : MainAxisAlignment.start,
          children: [
            Flexible(
              child: Text(
                station,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Helper untuk info tanggal
  Widget _buildInfoColumn(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 5),
        Text(subtitle,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333E63))),
      ],
    );
  }

  // Helper untuk tombol +/- penumpang
  Widget _buildPassengerButton(IconData icon, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Icon(icon, size: 16, color: Colors.black54),
      ),
    );
  }

  // Horizontal List untuk "Tiket saya" (Layout "Ceper")
  Widget _buildMyTicketsList() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: controller.myTicketsList.map((ticket) {
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 160,
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade100,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              ticket["status"]!,
                              style: TextStyle(
                                  color: Colors.orange.shade800,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            ticket["nama_kereta"]!,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(ticket["rute"]!,
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_rounded,
                        color: Color(0xFF656CEE)),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // Horizontal List untuk "Berita"
  Widget _buildNewsList() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: controller.newsList.map((news) {
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Container(
              width: 180,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(10)),
                      image: DecorationImage(
                        // Ganti dengan Image.asset(news["image"]!) jika gambar ada
                        image: NetworkImage(
                            'https://via.placeholder.com/180x100.png?text=Berita'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          news["kategori"]!,
                          style: const TextStyle(
                              color: Color(0xFF656CEE),
                              fontWeight: FontWeight.bold,
                              fontSize: 12),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          news["judul"]!,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // Halaman Tab 1: Tiket (Placeholder)
  Widget _buildTiketPage() {
    return const Center(
      child: Text(
        "Halaman Tiket Saya",
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  // Halaman Tab 2: Profil (Placeholder)
  Widget _buildProfilPage() {
    return const Center(
      child: Text(
        "Halaman Profil",
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }
}