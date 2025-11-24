import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/pilih_kursi_controller.dart';

class PilihKursiView extends GetView<PilihKursiController> {
  const PilihKursiView({super.key});

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFFF5F7FA);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          GetBuilder<PilihKursiController>(
            builder: (controller) {
              return Obx(() {
                if (controller.isLoadingSeats.value) {
                  const primaryColor = Color(0xFF656CEE);

                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            primaryColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Memuat kursi tersedia...",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  );
                }

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
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    const primaryColor = Color(0xFF656CEE);
    const primaryDark = Color(0xFF4147D5);
    const accentColor = Color(0xFFFF6B35);
    const accentLight = Color(0xFFFF8C5A);
    const textPrimary = Color(0xFF1B1B1F);
    const textSecondary = Color(0xFF49454F);
    const cardBackground = Colors.white;

    return Container(
      padding: const EdgeInsets.fromLTRB(25, 20, 25, 10),
      decoration: BoxDecoration(
        color: cardBackground,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: primaryColor,
                  ),
                  onPressed: () => Get.back(),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Pilih Tempat Duduk",
                      style: TextStyle(
                        fontSize: 13,
                        color: textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      controller.trainData['namaKereta'] ?? 'Nama Kereta',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [primaryColor, primaryDark],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Obx(
                  () => Text(
                    "${controller.selectedSeats.length}/${controller.passengerCount.value}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Obx(() {
            if (controller.isTimerActive.value) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [accentColor, accentLight],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.access_time_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Waktu tersisa: ${controller.getFormattedTime()}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    const primaryColor = Color(0xFF656CEE);
    const accentColor = Color(0xFFFF6B35);
    const cardBackground = Colors.white;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildLegendItem(
            icon: Icons.event_seat_rounded,
            label: "Tersedia",
            color: cardBackground,
            borderColor: primaryColor.withOpacity(0.3),
          ),
          _buildLegendItem(
            icon: Icons.event_seat,
            label: "Terisi",
            color: accentColor,
            borderColor: accentColor,
          ),
          _buildLegendItem(
            icon: Icons.event_seat,
            label: "Dipilih",
            color: primaryColor,
            borderColor: primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem({
    required IconData icon,
    required String label,
    required Color color,
    required Color borderColor,
  }) {
    const primaryColor = Color(0xFF656CEE);
    const textSecondary = Color(0xFF333E63);
    const cardBackground = Colors.white;

    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderColor, width: 2),
          ),
          child: Icon(
            icon,
            size: 16,
            color: color == cardBackground
                ? primaryColor
                : cardBackground,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: textSecondary,
          ),
        ),
      ],
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
    const primaryColor = Color(0xFF656CEE);
    const primaryDark = Color(0xFF4147D5);
    const textSecondary = Color(0xFF333E63);
    const cardBackground = Colors.white;

    return SizedBox(
      height: 70,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: controller.namaGerbong.length,
        itemBuilder: (context, index) {
          final isSelected = controller.indexGerbong.value == index;
          return GestureDetector(
            onTap: () => controller.gantiGerbong(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 6),
              height: 70,
              width: 110,
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [primaryColor, primaryDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isSelected ? null : cardBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? Colors.transparent
                      : primaryColor.withOpacity(0.3),
                  width: 2,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.train_rounded,
                    color: isSelected ? cardBackground : primaryColor,
                    size: 24,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    controller.namaGerbong[index],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isSelected
                          ? cardBackground
                          : textSecondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
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

  Widget _buildSeatGrid() {
    return Expanded(
      child: Column(
        children: [
          _buildSeatColumnLabels(),
          const SizedBox(height: 10),
          Expanded(
            child: Container(
              child:
                  (controller.gerbong.isEmpty ||
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
                          .gerbong[controller.indexGerbong.value]
                          .length,
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
          child: Center(child: Text("A", style: TextStyle(fontSize: 18))),
        ),
        Expanded(
          child: Center(child: Text("B", style: TextStyle(fontSize: 18))),
        ),
        Expanded(
          child: Center(child: Icon(Icons.arrow_downward, color: Colors.grey)),
        ),
        Expanded(
          child: Center(child: Text("C", style: TextStyle(fontSize: 18))),
        ),
        Expanded(
          child: Center(child: Text("D", style: TextStyle(fontSize: 18))),
        ),
      ],
    );
  }

  Widget _buildSeatItem(Map<String, dynamic> seat, int index) {
    const primaryColor = Color(0xFF656CEE);
    const accentColor = Color(0xFFFF6B35);
    const cardBackground = Colors.white;

    String status = seat["status"];

    if (status == "aisle") {
      int baris = (index ~/ 5) + 1;
      return Center(
        child: Text(
          "$baris",
          style: const TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    if (status == "empty") {
      return Container();
    }

    return GestureDetector(
      onTap: () => controller.selectKursi(index),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black38),
          color: status == "available"
              ? cardBackground
              : status == "filled"
              ? accentColor
              : primaryColor,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    const primaryColor = Color(0xFF656CEE);
    const cardBackground = Colors.white;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBackground,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Obx(() {
        final isValid =
            controller.selectedSeats.length == controller.passengerCount.value;
        final hasSelected = controller.selectedSeats.isNotEmpty;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isValid && hasSelected)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: Colors.orange.shade700,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Pilih ${controller.passengerCount.value - controller.selectedSeats.length} kursi lagi",
                        style: TextStyle(
                          color: Colors.orange.shade900,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ElevatedButton(
              onPressed: isValid ? () => controller.goToNextPage() : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                disabledBackgroundColor: Colors.grey.shade300,
                foregroundColor: Colors.white,
                disabledForegroundColor: Colors.grey.shade500,
                fixedSize: Size(Get.width, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
                shadowColor: Colors.transparent,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isValid ? "Lanjutkan" : "Pilih Kursi",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (isValid) ...[
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_rounded, size: 20),
                  ],
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}
