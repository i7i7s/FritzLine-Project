import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/pilih_kursi_controller.dart';

class PilihKursiView extends GetView<PilihKursiController> {
  const PilihKursiView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(),
          GetBuilder<PilihKursiController>(
            builder: (controller) {
              return Column(
                children: [
                  SizedBox(height: context.mediaQueryPadding.top),
                  _buildHeader(),
                  _buildLegend(),
                  const SizedBox(height: 10),
                  _buildSeatMap(),
                  _buildSubmitButton(),
                ],
              );
            },
          ),
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

  Widget _buildHeader() {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            "Pilih Tempat\nDuduk",
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333E63),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                controller.trainData.value['namaKereta'] ?? 'Nama Kereta',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                controller.namaGerbong.isEmpty
                    ? "..."
                    : controller.namaGerbong[controller.indexGerbong.value],
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF656CEE),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      height: 50,
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ItemStatus(status: "Tersedia", color: Colors.white),
          ItemStatus(status: "Terisi", color: Colors.orangeAccent),
          ItemStatus(status: "Dipilih", color: Colors.deepPurpleAccent),
        ],
      ),
    );
  }

  Widget _buildSeatMap() {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          children: [
            _buildSeatGrid(),
            const SizedBox(height: 15),
            _buildGerbongList(),
          ],
        ),
      ),
    );
  }

  Widget _buildGerbongList() {
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: controller.namaGerbong.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => controller.gantiGerbong(index),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              height: 60,
              width: 100,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black38),
                borderRadius: BorderRadius.circular(10),
                color: controller.indexGerbong.value == index
                    ? Colors.deepPurpleAccent
                    : Colors.white,
              ),
              child: Center(
                child: Text(
                  controller.namaGerbong[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: controller.indexGerbong.value == index
                        ? Colors.white
                        : Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSeatGrid() {
    return Expanded(
      child: Column(
        children: [
          _buildSeatColumnLabels(),
          const SizedBox(height: 10),
          Expanded(
            child: Container(
              child: (controller.gerbong.isEmpty ||
                      controller.indexGerbong.value >=
                          controller.gerbong.length)
                  ? const Center(child: Text("Loading gerbong..."))
                  : GridView.builder(
                      padding: const EdgeInsets.all(0),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        crossAxisCount: 5,
                      ),
                      itemCount: controller
                          .gerbong[controller.indexGerbong.value].length,
                      itemBuilder: (context, index) {
                        final seat = controller
                            .gerbong[controller.indexGerbong.value][index];
                        return _buildSeatItem(seat, index);
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeatColumnLabels() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        SizedBox(width: 10),
        Expanded(
            child: Center(child: Text("A", style: TextStyle(fontSize: 18)))),
        Expanded(
            child: Center(child: Text("B", style: TextStyle(fontSize: 18)))),
        Expanded(
            child:
                Center(child: Icon(Icons.arrow_downward, color: Colors.grey))),
        Expanded(
            child: Center(child: Text("C", style: TextStyle(fontSize: 18)))),
        Expanded(
            child: Center(child: Text("D", style: TextStyle(fontSize: 18)))),
      ],
    );
  }

  Widget _buildSeatItem(Map<String, dynamic> seat, int index) {
    String status = seat["status"];
    String id = seat["id"];

    if (status == "aisle") {
      int baris = (index ~/ 5) + 1;
      return Center(
          child: Text("$baris",
              style: const TextStyle(
                  color: Colors.grey, fontWeight: FontWeight.bold)));
    }

    if (status == "empty") {
      return Container();
    }

    return GestureDetector(
      onTap: () => controller.selectKursi(index),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.black38,
          ),
          color: status == "available"
              ? Colors.white
              : status == "filled"
                  ? Colors.orangeAccent
                  : Colors.deepPurpleAccent,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      height: 100,
      child: Center(
        child: ElevatedButton(
          onPressed: () => controller.goToNextPage(),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF656CEE),
            fixedSize: Size(Get.width * 0.8, 50),
          ),
          child: const Text(
            "Pilih Tempat Duduk",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class ItemStatus extends StatelessWidget {
  const ItemStatus({
    super.key,
    required this.status,
    required this.color,
  });

  final String status;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 25,
          width: 25,
          decoration: BoxDecoration(
            color: color,
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        const SizedBox(width: 7),
        Text(
          status,
          style: const TextStyle(
            fontSize: 18,
          ),
        ),
      ],
    );
  }
}