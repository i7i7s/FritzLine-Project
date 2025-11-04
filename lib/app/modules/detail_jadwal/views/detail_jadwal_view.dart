import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/detail_jadwal_controller.dart';

class DetailJadwalView extends GetView<DetailJadwalController> {
  const DetailJadwalView({super.key});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(),
          _buildBody(currencyFormatter),
          _buildFilterButton(),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      width: Get.width,
      height: Get.height,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/bg.png'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildBody(NumberFormat currencyFormatter) {
    return Column(
      children: [
        _buildCustomAppBar(),
        _buildSelectedDateInfo(),
        _buildTrainList(currencyFormatter),
      ],
    );
  }

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
            Expanded(
              child: Obx(() => Text(
                    "${controller.departure['name']} - ${controller.arrival['name']}",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333E63),
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedDateInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      color: Colors.white.withOpacity(0.5),
      child: Obx(() => Text(
            controller.getFormattedDate(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333E63),
            ),
          )),
    );
  }

  Widget _buildTrainList(NumberFormat currencyFormatter) {
    return Expanded(
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.trainList.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.train_outlined, size: 80, color: Colors.grey),
                SizedBox(height: 16),
                Text("Tidak Ada Jadwal",
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text("Coba cari rute atau tanggal lain, atau ubah filter Anda.",
                    style: TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center),
              ],
            ),
          );
        }

        return ListView.builder(
          padding:
              const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 100),
          itemCount: controller.trainList.length,
          itemBuilder: (context, index) {
            final train = controller.trainList[index];
            return _buildTrainCard(train, currencyFormatter);
          },
        );
      }),
    );
  }

  Widget _buildTrainCard(
      Map<String, dynamic> train, NumberFormat currencyFormatter) {
    String kelas = train["kelas"] ?? "Ekonomi";
    Color tagColor = Colors.pink;
    if (kelas.toLowerCase().contains("eksekutif")) {
      tagColor = Colors.deepPurple;
      kelas = "Executive";
    } else if (kelas.toLowerCase().contains("campuran")) {
      tagColor = Colors.orange;
      kelas = "Campuran";
    } else {
      tagColor = Colors.pink;
      kelas = "Economy";
    }

    int sisaTiket = train["sisaTiket"] as int? ?? 0;
    bool isSoldOut = sisaTiket <= 0;
    String statusText = "Available";
    Color statusColor = Colors.green;

    if (isSoldOut) {
      statusText = "Habis";
      statusColor = Colors.grey;
    } else if (sisaTiket <= 20) {
      statusText = "$sisaTiket Seat${sisaTiket == 1 ? '' : 's'} Remaining";
      statusColor = Colors.red;
    }

    return Opacity(
      opacity: isSoldOut ? 0.6 : 1.0,
      child: Card(
        elevation: 3,
        shadowColor: Colors.black.withOpacity(0.1),
        margin: const EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: InkWell(
          onTap: isSoldOut ? null : () => controller.selectTrain(train),
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildClassTag(kelas, tagColor),
                    _buildStatusTag(statusText, statusColor),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  train["namaKereta"],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333E63),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildTimeColumn(
                      train["jadwalBerangkat"],
                      train["stasiunBerangkat"],
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            train["durasi"],
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const DottedLine(),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    _buildTimeColumn(
                      train["jadwalTiba"],
                      train["stasiunTiba"],
                      align: CrossAxisAlignment.end,
                    ),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Prices Starting From:",
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "${currencyFormatter.format(train["harga"])} / Pax",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF656CEE),
                          ),
                        ),
                      ],
                    ),
                    OutlinedButton(
                      onPressed: isSoldOut ? null : () {},
                      child: const Text("Train Details"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF656CEE),
                        side: const BorderSide(color: Color(0xFF656CEE)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildClassTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildStatusTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildFilterButton() {
    return Positioned(
      bottom: 30,
      left: 0,
      right: 0,
      child: Center(
        child: ElevatedButton.icon(
          onPressed: () => controller.showFilterBottomSheet(),
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

  Widget _buildTimeColumn(
    String time,
    String code, {
    CrossAxisAlignment align = CrossAxisAlignment.start,
  }) {
    return Column(
      crossAxisAlignment: align,
      children: [
        Text(
          time,
          style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333E63)),
        ),
        const SizedBox(height: 4),
        Text(code, style: const TextStyle(fontSize: 14, color: Colors.grey)),
      ],
    );
  }
}

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