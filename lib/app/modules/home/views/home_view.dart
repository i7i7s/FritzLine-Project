import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHomeHeader(context),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: _buildBookingCard(context),
              ),
              _buildBerandaSectionTitle("Berita"),
              const SizedBox(height: 16),
              _buildNewsList(),
              const SizedBox(height: 24),
              _buildBerandaSectionTitle("Stasiun Terdekat Anda"),
              _buildNearestStationsCard(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHomeHeader(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Text(
        "Mau pergi ke\nmana kali ini?",
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Color(0xFF333E63),
        ),
      ),
    );
  }

  Widget _buildBerandaSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1B1B1F),
        ),
      ),
    );
  }

  Widget _buildBookingCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF656CEE).withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _buildStationRow(context),
            const Divider(height: 25, thickness: 1, color: Color(0xFFE0E0FF)),
            _buildDateRow(context),
            const Divider(height: 25, thickness: 1, color: Color(0xFFE0E0FF)),
            _buildPassengerRow(),
          ],
        ),
      ),
    );
  }

  Widget _buildStationRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => controller.showCitySelection(context, true),
            child: Obx(() => _buildStationInfo(
                  "Keberangkatan",
                  controller.selectedDeparture.value['code'] ?? "...",
                  controller.selectedDeparture.value['name'] ?? 'Pilih Stasiun',
                )),
          ),
        ),
        GestureDetector(
          onTap: () => controller.swapCities(),
          child: Container(
            margin: const EdgeInsets.only(top: 16.0, left: 8, right: 8),
            padding: const EdgeInsets.all(4),
            child:
                const Icon(Icons.swap_horiz, color: Color(0xFF656CEE), size: 28),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () => controller.showCitySelection(context, false),
            child: Obx(() => _buildStationInfo(
                  "Tujuan",
                  controller.selectedArrival.value['code'] ?? "...",
                  controller.selectedArrival.value['name'] ?? 'Pilih Stasiun',
                  align: CrossAxisAlignment.end,
                )),
          ),
        ),
      ],
    );
  }

  Widget _buildDateRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => controller.selectDate(context),
            child: Obx(() => _buildInfoColumn(
                  "Tanggal keberangkatan",
                  controller.getFormattedDate(controller.selectedDate.value),
                )),
          ),
        ),
        const SizedBox(width: 10),
        Row(
          children: [
            Obx(() => Switch(
                  value: controller.isRoundTrip.value,
                  onChanged: (val) => controller.toggleRoundTrip(val),
                  activeColor: const Color(0xFF656CEE),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                )),
            const Text("Pulang pergi",
                style: TextStyle(fontSize: 12, color: Color(0xFF49454F))),
          ],
        ),
      ],
    );
  }

  Widget _buildPassengerRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Jumlah penumpang",
                style: TextStyle(color: Color(0xFF49454F), fontSize: 12)),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildPassengerButton(
                    Icons.remove, controller.decrementPassenger),
                Obx(() => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text("${controller.passengerCount.value}",
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1B1B1F))),
                    )),
                _buildPassengerButton(Icons.add, controller.incrementPassenger),
              ],
            )
          ],
        ),
        GestureDetector(
          onTap: () => controller.cariTiket(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF656CEE), Color(0xFF4147D5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF656CEE).withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Text(
              "CARI",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStationInfo(String title, String code, String station,
      {CrossAxisAlignment align = CrossAxisAlignment.start}) {
    return Column(
      crossAxisAlignment: align,
      children: [
        Text(title,
            style: const TextStyle(color: Color(0xFF49454F), fontSize: 12)),
        const SizedBox(height: 5),
        Text(code,
            style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333E63))),
        const SizedBox(height: 5),
        Text(
          station,
          style: const TextStyle(color: Color(0xFF49454F), fontSize: 12),
          overflow: TextOverflow.ellipsis,
          textAlign:
              (align == CrossAxisAlignment.end) ? TextAlign.end : TextAlign.start,
        ),
      ],
    );
  }

  Widget _buildInfoColumn(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(color: Color(0xFF49454F), fontSize: 12)),
        const SizedBox(height: 8),
        Text(subtitle,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B1B1F))),
      ],
    );
  }

  Widget _buildPassengerButton(IconData icon, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFDCDCDC)),
        ),
        child: Icon(icon, size: 16, color: const Color(0xFF333E63)),
      ),
    );
  }

  Widget _buildNewsList() {
    return SizedBox(
      height: 210,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: controller.newsList.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final news = controller.newsList[index];
          return SizedBox(
            width: Get.width * 0.7,
            child: Card(
              elevation: 2,
              shadowColor: Colors.black.withOpacity(0.05),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    height: 110,
                    width: double.infinity,
                    color: Colors.grey.shade200,
                    alignment: Alignment.center,
                    child: Text(
                      "Gambar Berita ${index + 1}",
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            news["kategori"] ?? "",
                            style: const TextStyle(
                                color: Color(0xFF656CEE),
                                fontWeight: FontWeight.bold,
                                fontSize: 12),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            news["judul"] ?? "",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNearestStationsCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Card(
        elevation: 2,
        color: Colors.white,
        shadowColor: Colors.black.withOpacity(0.05),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Stasiun Terdekat",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B1B1F),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => controller.fetchNearestStationsLBS(),
                    child: const Row(
                      children: [
                        Icon(Icons.refresh,
                            size: 18, color: Color(0xFF656CEE)),
                        SizedBox(width: 4),
                        Text(
                          "Refresh",
                          style: TextStyle(
                              color: Color(0xFF656CEE),
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Obx(() {
                if (controller.isLoadingStasiunLBS.isTrue) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          CircularProgressIndicator(
                            strokeWidth: 3,
                          ),
                          SizedBox(height: 10),
                          Text("Mencari stasiun..."),
                        ],
                      ),
                    ),
                  );
                }

                if (controller.stasiunTerdekat.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        "Gagal. Pastikan izin lokasi (GPS) Anda aktif.",
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                return Column(
                  children: controller.stasiunTerdekat.map((stasiun) {
                    return ListTile(
                      leading:
                          const Icon(Icons.train, color: Color(0xFF656CEE)),
                      title: Text("${stasiun['nama']} (${stasiun['id']})",
                          style: const TextStyle(fontWeight: FontWeight.w500)),
                      subtitle:
                          Text("${stasiun['distance_km']} km dari lokasi Anda"),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                    );
                  }).toList(),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class StationSearchDialog extends StatefulWidget {
  final HomeController controller;
  final bool isDeparture;

  const StationSearchDialog({
    super.key,
    required this.controller,
    required this.isDeparture,
  });

  @override
  State<StationSearchDialog> createState() => _StationSearchDialogState();
}

class _StationSearchDialogState extends State<StationSearchDialog> {
  late TextEditingController _searchC;
  final _filteredStations = <Map<String, dynamic>>[].obs;

  @override
  void initState() {
    super.initState();
    _searchC = TextEditingController();
    _filteredStations.value = widget.controller.allStations;
    _searchC.addListener(_filterList);
  }

  @override
  void dispose() {
    _searchC.removeListener(_filterList);
    _searchC.dispose();
    super.dispose();
  }

  void _filterList() {
    final query = _searchC.text;
    if (query.isEmpty) {
      _filteredStations.value = widget.controller.allStations;
    } else {
      _filteredStations.value =
          widget.controller.allStations.where((station) {
        final stationName = station['nama'].toString().toLowerCase();
        final stationCode = station['id'].toString().toLowerCase();
        final searchLower = query.toLowerCase();
        return stationName.contains(searchLower) ||
            stationCode.contains(searchLower);
      }).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: Get.width * 0.8,
      height: Get.height * 0.5,
      child: Column(
        children: [
          TextField(
            controller: _searchC,
            decoration: InputDecoration(
              hintText: "Cari stasiun (cth: GMR atau Gambir)",
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFDCDCDC)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF333E63)),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 10),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Obx(() => ListView.builder(
                  itemCount: _filteredStations.length,
                  itemBuilder: (context, index) {
                    final station = _filteredStations[index];
                    return ListTile(
                      title: Text("${station['nama']} (${station['id']})"),
                      onTap: () {
                        widget.controller.selectStation(
                          station,
                          widget.isDeparture,
                        );
                      },
                    );
                  },
                )),
          ),
        ],
      ),
    );
  }
}