import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/pilih_kursi_controller.dart';
import '../../../models/passenger_type.dart';

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
                    _buildPassengerList(),
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
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          size: 12,
                          color: textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('EEEE, dd MMM yyyy', 'id_ID')
                              .format(controller.tanggalKeberangkatan),
                          style: const TextStyle(
                            fontSize: 11,
                            color: textSecondary,
                          ),
                        ),
                      ],
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

  Widget _buildPassengerList() {
    const primaryColor = Color(0xFF656CEE);
    const accentColor = Color(0xFFFF6B35);
    const cardBackground = Colors.white;

    final passengers = controller.bookingService.passengerInfoList;

    if (passengers.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.people_rounded,
                  color: primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daftar Penumpang',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1B1B1F),
                      ),
                    ),
                    Text(
                      'Tap nama untuk memilih kursi',
                      style: TextStyle(fontSize: 11, color: Color(0xFF49454F)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Obx(
            () => Wrap(
              spacing: 8,
              runSpacing: 8,
              children: passengers.asMap().entries.map((entry) {
                final index = entry.key;
                final passenger = entry.value;
                final isSelected =
                    controller.currentSelectingPassengerIndex.value == index;
                final hasSeat = controller.seatAssignments.containsKey(index);
                final seatInfo = controller.seatAssignments[index];

                if (!passenger.needsSeat) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey.shade300,
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.child_care_rounded,
                              size: 16,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              passenger.name,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Tidak perlu kursi',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return GestureDetector(
                  onTap: () {
                    if (hasSeat) {
                      Get.snackbar(
                        'Info',
                        '${passenger.name} sudah memiliki kursi ${seatInfo!['id']} di ${seatInfo['nama_gerbong']}',
                        snackPosition: SnackPosition.TOP,
                        duration: const Duration(seconds: 2),
                      );
                    } else {
                      controller.currentSelectingPassengerIndex.value = index;
                      Get.snackbar(
                        'Mode Pilih Kursi',
                        'Pilih kursi untuk ${passenger.name}',
                        snackPosition: SnackPosition.TOP,
                        backgroundColor: primaryColor,
                        colorText: Colors.white,
                        duration: const Duration(seconds: 2),
                      );
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: hasSeat
                          ? Colors.green.shade50
                          : (isSelected
                                ? primaryColor.withOpacity(0.1)
                                : Colors.white),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: hasSeat
                            ? Colors.green
                            : (isSelected
                                  ? primaryColor
                                  : Colors.grey.shade300),
                        width: isSelected || hasSeat ? 2 : 1.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              hasSeat
                                  ? Icons.check_circle_rounded
                                  : (passenger.type == PassengerType.adult
                                        ? Icons.person_rounded
                                        : Icons.child_friendly_rounded),
                              size: 16,
                              color: hasSeat
                                  ? Colors.green
                                  : (isSelected ? primaryColor : accentColor),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              passenger.name,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: hasSeat
                                    ? Colors.green.shade700
                                    : (isSelected
                                          ? primaryColor
                                          : const Color(0xFF1B1B1F)),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              passenger.gender == 'Perempuan'
                                  ? Icons.female
                                  : Icons.male,
                              size: 14,
                              color: passenger.gender == 'Perempuan'
                                  ? Colors.pink.shade300
                                  : Colors.blue.shade400,
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          hasSeat
                              ? '${seatInfo!['id']} - ${seatInfo['nama_gerbong']}'
                              : passenger.typeLabel,
                          style: TextStyle(
                            fontSize: 10,
                            color: hasSeat
                                ? Colors.green.shade600
                                : Colors.grey.shade600,
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
                      color: isSelected ? cardBackground : textSecondary,
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

    Color seatColor;
    if (status == "available") {
      seatColor = cardBackground;
    } else if (status == "filled") {
      final gender = seat["gender"] as String?;
      seatColor = (gender == "Perempuan") ? Colors.pink.shade300 : accentColor;
    } else {
      seatColor = primaryColor;
    }

    return GestureDetector(
      onTap: () => controller.selectKursi(index),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black38),
          color: seatColor,
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
      },
      )
    ); 
  }

}
