import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHomeHeader(context),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                child: _buildBookingCard(context),
              ),
              _buildBerandaSectionTitle("Berita Terkini"),
              const SizedBox(height: 16),
              _buildNewsList(),
              const SizedBox(height: 28),
              _buildBerandaSectionTitle("Stasiun Terdekat"),
              _buildNearestStationsCard(),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHomeHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF656CEE).withOpacity(0.05),
            Colors.transparent,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(
                'assets/images/logo.png',
                width: 52,
                height: 52,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  "FritzLine",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF333E63),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            "Mau pergi ke\nmana kali ini?",
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1B1B1F),
              height: 1.2,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Temukan perjalanan terbaik Anda",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF49454F).withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBerandaSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF656CEE), Color(0xFFFF6B35)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1B1B1F),
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF656CEE).withOpacity(0.08),
            blurRadius: 24,
            spreadRadius: 0,
            offset: const Offset(8, 8),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.9),
            blurRadius: 24,
            spreadRadius: 0,
            offset: const Offset(-8, -8),
          ),
          BoxShadow(
            color: const Color(0xFF656CEE).withOpacity(0.05),
            blurRadius: 40,
            spreadRadius: 4,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            _buildStationRow(context),
            const SizedBox(height: 20),
            Divider(height: 1, thickness: 1, color: Colors.grey.shade200),
            const SizedBox(height: 20),
            _buildDateRow(context),
            const SizedBox(height: 20),
            Divider(height: 1, thickness: 1, color: Colors.grey.shade200),
            const SizedBox(height: 20),
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
            child: Obx(
              () => _buildStationInfo(
                "Keberangkatan",
                controller.selectedDeparture['code'] ?? "...",
                controller.selectedDeparture['name'] ?? 'Pilih Stasiun',
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () => controller.swapCities(),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.only(top: 20.0, left: 12, right: 12),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF656CEE).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.swap_horiz_rounded,
              color: Color(0xFF656CEE),
              size: 26,
            ),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () => controller.showCitySelection(context, false),
            child: Obx(
              () => _buildStationInfo(
                "Tujuan",
                controller.selectedArrival['code'] ?? "...",
                controller.selectedArrival['name'] ?? 'Pilih Stasiun',
                align: CrossAxisAlignment.end,
              ),
            ),
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
            child: Obx(
              () => _buildInfoColumn(
                "Tanggal Keberangkatan",
                controller.getFormattedDate(controller.selectedDate.value),
                icon: Icons.calendar_today_rounded,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Row(
          children: [
            Obx(
              () => Transform.scale(
                scale: 0.9,
                child: Switch(
                  value: controller.isRoundTrip.value,
                  onChanged: (val) => controller.toggleRoundTrip(val),
                  activeColor: const Color(0xFF656CEE),
                  activeTrackColor: const Color(0xFF656CEE).withOpacity(0.3),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ),
            const SizedBox(width: 4),
            const Text(
              "Pulang pergi",
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF49454F),
                fontWeight: FontWeight.w500,
              ),
            ),
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
            Text(
              "PENUMPANG".toUpperCase(),
              style: TextStyle(
                color: const Color(0xFF49454F).withOpacity(0.7),
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF5F7FA),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF656CEE).withOpacity(0.15),
                  width: 1.5,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Row(
                children: [
                  _buildPassengerButton(
                    Icons.remove_rounded,
                    controller.decrementPassenger,
                  ),
                  Obx(
                    () => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        "${controller.passengerCount.value}",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1B1B1F),
                        ),
                      ),
                    ),
                  ),
                  _buildPassengerButton(
                    Icons.add_rounded,
                    controller.incrementPassenger,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () => controller.cariTiket(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF656CEE), Color(0xFF4147D5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF656CEE).withOpacity(0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_rounded, color: Colors.white, size: 22),
                  SizedBox(width: 8),
                  Text(
                    "CARI TIKET",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStationInfo(
    String title,
    String code,
    String station, {
    CrossAxisAlignment align = CrossAxisAlignment.start,
  }) {
    return Column(
      crossAxisAlignment: align,
      children: [
        Text(
          title.toUpperCase(),
          style: TextStyle(
            color: const Color(0xFF49454F).withOpacity(0.7),
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          code,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: Color(0xFF333E63),
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          station,
          style: const TextStyle(
            color: Color(0xFF49454F),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
          textAlign: (align == CrossAxisAlignment.end)
              ? TextAlign.end
              : TextAlign.start,
        ),
      ],
    );
  }

  Widget _buildInfoColumn(String title, String subtitle, {IconData? icon}) {
    return Row(
      children: [
        if (icon != null) ...[
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF656CEE).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: const Color(0xFF656CEE)),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title.toUpperCase(),
                style: TextStyle(
                  color: const Color(0xFF49454F).withOpacity(0.7),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1B1B1F),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPassengerButton(IconData icon, VoidCallback onPressed) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF656CEE).withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, size: 20, color: const Color(0xFF656CEE)),
        ),
      ),
    );
  }

  Widget _buildNewsList() {
    return SizedBox(
      height: 230,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: controller.newsList.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final news = controller.newsList[index];
          return Container(
            width: Get.width * 0.72,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  height: 130,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF656CEE).withOpacity(0.7),
                        const Color(0xFFFF6B35).withOpacity(0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.article_rounded,
                        color: Colors.white.withOpacity(0.5),
                        size: 48,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Berita ${index + 1}",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF656CEE).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            news["kategori"] ?? "",
                            style: const TextStyle(
                              color: Color(0xFF656CEE),
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          news["judul"] ?? "",
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: Color(0xFF1B1B1F),
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildNearestStationsCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF656CEE).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.location_on_rounded,
                          size: 20,
                          color: Color(0xFF656CEE),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "Stasiun Terdekat",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1B1B1F),
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => controller.fetchNearestStationsLBS(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF656CEE).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.refresh_rounded,
                            size: 18,
                            color: Color(0xFF656CEE),
                          ),
                          SizedBox(width: 4),
                          Text(
                            "Refresh",
                            style: TextStyle(
                              color: Color(0xFF656CEE),
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Obx(() {
                if (controller.isLoadingStasiunLBS.isTrue) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          CircularProgressIndicator(strokeWidth: 3),
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
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F7FA),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFF656CEE).withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF656CEE), Color(0xFF4147D5)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.train_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${stasiun['nama']} (${stasiun['id']})",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                    color: Color(0xFF1B1B1F),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.near_me_rounded,
                                      size: 14,
                                      color: const Color(
                                        0xFF656CEE,
                                      ).withOpacity(0.7),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      "${stasiun['distance_km']} km dari lokasi Anda",
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: const Color(
                                          0xFF49454F,
                                        ).withOpacity(0.8),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
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
      _filteredStations.value = widget.controller.allStations.where((station) {
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
    return Container(
      width: Get.width * 0.85,
      height: Get.height * 0.6,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF656CEE).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.search_rounded,
                  color: Color(0xFF656CEE),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.isDeparture
                      ? "Pilih Stasiun Keberangkatan"
                      : "Pilih Stasiun Tujuan",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1B1B1F),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _searchC,
            autofocus: true,
            decoration: InputDecoration(
              hintText: "Cari stasiun (cth: GMR atau Gambir)",
              hintStyle: TextStyle(
                color: const Color(0xFF49454F).withOpacity(0.5),
              ),
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: Color(0xFF656CEE),
              ),
              filled: true,
              fillColor: const Color(0xFFF5F7FA),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Color(0xFF656CEE),
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Obx(
              () => _filteredStations.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            size: 64,
                            color: const Color(0xFF49454F).withOpacity(0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "Stasiun tidak ditemukan",
                            style: TextStyle(
                              fontSize: 16,
                              color: const Color(0xFF49454F).withOpacity(0.6),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: _filteredStations.length,
                      itemBuilder: (context, index) {
                        final station = _filteredStations[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F7FA),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF656CEE),
                                    Color(0xFF4147D5),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.train_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            title: Text(
                              station['nama'] ?? '',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                color: Color(0xFF1B1B1F),
                              ),
                            ),
                            subtitle: Text(
                              "(${station['id']})",
                              style: TextStyle(
                                fontSize: 13,
                                color: const Color(0xFF49454F).withOpacity(0.7),
                              ),
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 16,
                              color: Color(0xFF656CEE),
                            ),
                            onTap: () {
                              widget.controller.selectStation(
                                station,
                                widget.isDeparture,
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
