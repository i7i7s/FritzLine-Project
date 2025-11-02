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
            Obx(() => Text(
                  "${controller.departure['name']} - ${controller.arrival['name']}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333E63),
                  ),
                )),
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
            _buildTrainCardHeader(train, currencyFormatter),
            const SizedBox(height: 16),
            _buildTrainCardRoute(train),
            const SizedBox(height: 16),
            _buildTrainCardFooter(train),
          ],
        ),
      ),
    );
  }

  Widget _buildTrainCardHeader(
      Map<String, dynamic> train, NumberFormat currencyFormatter) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            train["namaKereta"],
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              currencyFormatter.format(train["harga"]),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF656CEE),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTrainCardRoute(Map<String, dynamic> train) {
    return Row(
      children: [
        _buildTimeColumn(
          train["stasiunBerangkat"],
          train["jadwalBerangkat"],
        ),
        const SizedBox(width: 10),
        const Expanded(child: DottedLine()),
        const SizedBox(width: 10),
        _buildTimeColumn(
          train["stasiunTiba"],
          train["jadwalTiba"],
          align: CrossAxisAlignment.end,
        ),
      ],
    );
  }

  Widget _buildTrainCardFooter(Map<String, dynamic> train) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTag(train["kelas"]),
            const SizedBox(height: 5),
            Text(
              train["durasi"],
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
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
            onPressed: () => controller.selectTrain(train),
          ),
        ),
      ],
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