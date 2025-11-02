import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return _buildBerandaPage(context);
  }

  Widget _buildBerandaPage(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            _buildBerandaHeader(),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildBookingCard(context),
            ),
            const SizedBox(height: 30),
            _buildBerandaSectionTitle("Berita"),
            const SizedBox(height: 10),
            _buildNewsList(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildBerandaHeader() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        "Mau pergi ke\nmana kali ini?",
        style: TextStyle(
          fontSize: 24,
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
          color: Color(0xFF333E63),
        ),
      ),
    );
  }

  Widget _buildBookingCard(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _buildStationRow(context),
            const Divider(height: 25, thickness: 1),
            _buildDateRow(context),
            const Divider(height: 25, thickness: 1),
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
                  controller.selectedDeparture.value['code'] ?? "",
                  controller.selectedDeparture.value['name'] ?? '...',
                )),
          ),
        ),
        GestureDetector(
          onTap: () => controller.swapCities(),
          child: const Padding(
            padding: EdgeInsets.only(top: 25.0, left: 8, right: 8),
            child: Icon(Icons.swap_horiz, color: Color(0xFF656CEE), size: 28),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () => controller.showCitySelection(context, false),
            child: Obx(() => _buildStationInfo(
                  "Tujuan",
                  controller.selectedArrival.value['code'] ?? "",
                  controller.selectedArrival.value['name'] ?? '...',
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
            const Text("Pulang pergi", style: TextStyle(fontSize: 12)),
          ],
        ),
      ],
    );
  }

  Widget _buildPassengerRow() {
    return Row(
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
                _buildPassengerButton(
                    Icons.remove, controller.decrementPassenger),
                Obx(() => Text(" ${controller.passengerCount.value} ",
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold))),
                _buildPassengerButton(Icons.add, controller.incrementPassenger),
              ],
            )
          ],
        ),
        ElevatedButton(
          onPressed: () => controller.cariTiket(),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF656CEE),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          child: const Text("CARI TIKET",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildStationInfo(String title, String code, String station,
      {CrossAxisAlignment align = CrossAxisAlignment.start}) {
    return Column(
      crossAxisAlignment: align,
      children: [
        Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 5),
        Text(code.isEmpty ? "..." : code,
            style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333E63))),
        const SizedBox(height: 5),
        Row(
          mainAxisAlignment: (align == CrossAxisAlignment.end)
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          children: [
            Flexible(
              child: Text(
                "Stasiun $station",
                style: const TextStyle(color: Colors.grey, fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

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

  Widget _buildNewsList() {
    return SizedBox(
      height: 190,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: controller.newsList.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final news = controller.newsList[index];
          return SizedBox(
            width: Get.width * 0.8,
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 110,
                    width: double.infinity,
                    color: Colors.grey.shade300,
                    alignment: Alignment.center,
                    child: Text(
                      "Gambar Berita ${index + 1}",
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
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
                ],
              ),
            ),
          );
        },
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
              labelText: "Cari stasiun (cth: GMR atau Gambir)",
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
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