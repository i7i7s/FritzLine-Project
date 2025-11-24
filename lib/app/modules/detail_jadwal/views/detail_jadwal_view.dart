import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/detail_jadwal_controller.dart';

class DetailJadwalView extends GetView<DetailJadwalController> {
  const DetailJadwalView({super.key});

  static const bgColor = Color(0xFFF5F7FA);

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [_buildBody(currencyFormatter), _buildFilterButton()],
      ),
    );
  }

  Widget _buildBody(NumberFormat currencyFormatter) {
    return Column(
      children: [
        _buildCustomAppBar(),
        _buildDateSelector(),
        _buildTrainList(currencyFormatter),
      ],
    );
  }

  Widget _buildCustomAppBar() {
    const appBarBgColor = Colors.white;
    const iconBgColor = Color.fromARGB(255, 255, 255, 255);
    const iconColor = Color(0xFF656CEE);
    const subtitleColor = Color(0xFF49454F);
    const titleColor = Color(0xFF1B1B1F);

    return Container(
      decoration: const BoxDecoration(
        color: appBarBgColor,
        boxShadow: [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: iconBgColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: iconColor,
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
                      "Pilih Jadwal Kereta",
                      style: TextStyle(fontSize: 13, color: subtitleColor),
                    ),
                    const SizedBox(height: 4),
                    Obx(
                      () => Text(
                        "${controller.departure['code']} → ${controller.arrival['code']}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: titleColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    const containerBgColor = Colors.white;
    const iconBgColor = Color(0xFF656CEE);
    const iconColor = Color(0xFF656CEE);
    const dateTextColor = Color(0xFF1B1B1F);

    return Container(
      color: containerBgColor,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconBgColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.calendar_today_rounded,
                    size: 18,
                    color: iconColor,
                  ),
                ),
                const SizedBox(width: 12),
                Obx(
                  () => Text(
                    controller.getFormattedDate(),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: dateTextColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 90,
            child: Obx(() {
              final dates = controller.getDateRange();
              return ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                physics: const BouncingScrollPhysics(),
                itemCount: dates.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final date = dates[index];
                  final isSelected =
                      DateFormat(
                        'yyyy-MM-dd',
                      ).format(controller.selectedDate.value) ==
                      DateFormat('yyyy-MM-dd').format(date);

                  return _buildDateCard(date, isSelected);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildDateCard(DateTime date, bool isSelected) {
    const selectedGradientColor1 = Color(0xFF656CEE);
    const selectedGradientColor2 = Color(0xFF4147D5);
    const unselectedBgColor = Color(0xFFF5F7FA);
    const borderColor = Color(0xFF656CEE);
    const selectedTextColor = Colors.white;
    const unselectedTextColor = Color(0xFF49454F);
    const unselectedNumberColor = Color(0xFF1B1B1F);

    final dayName = DateFormat('EEE', 'id_ID').format(date);
    final dayNumber = DateFormat('d').format(date);
    final monthName = DateFormat('MMM', 'id_ID').format(date);

    return GestureDetector(
      onTap: () => controller.changeDate(date),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 75,
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [selectedGradientColor1, selectedGradientColor2],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : unselectedBgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : borderColor.withOpacity(0.2),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: borderColor.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              dayName.toUpperCase(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? selectedTextColor.withOpacity(0.9)
                    : unselectedTextColor.withOpacity(0.7),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              dayNumber,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: isSelected ? selectedTextColor : unselectedNumberColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              monthName.toUpperCase(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? selectedTextColor.withOpacity(0.9)
                    : unselectedTextColor.withOpacity(0.7),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrainList(NumberFormat currencyFormatter) {
    const emptyIconColor = Colors.grey;
    const emptyTextColor = Colors.grey;

    return Expanded(
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.trainList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.train_outlined, size: 80, color: emptyIconColor),
                const SizedBox(height: 16),
                const Text(
                  "Tidak Ada Jadwal",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  "Coba cari rute atau tanggal lain, atau ubah filter Anda.",
                  style: TextStyle(color: emptyTextColor),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(
            left: 20,
            right: 20,
            top: 10,
            bottom: 100,
          ),
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
    Map<String, dynamic> train,
    NumberFormat currencyFormatter,
  ) {
    const cardBgColor = Colors.white;
    const trainIconGradient1 = Color(0xFF656CEE);
    const trainIconGradient2 = Color(0xFF4147D5);
    const trainIconColor = Colors.white;
    const trainNameColor = Color(0xFF1B1B1F);
    const durationTextColor = Colors.grey;
    const priceTextColor = Colors.grey;
    const priceAmountColor = Color(0xFF656CEE);
    const buttonBorderColor = Color(0xFF656CEE);
    const buttonTextColor = Color(0xFF656CEE);

    String kelas = train["kelas"] ?? "Ekonomi";
    Color tagColor = Colors.pink;
    if (kelas.toLowerCase().contains("eksekutif")) {
      tagColor = const Color(0xFF656CEE);
      kelas = "Executive";
    } else if (kelas.toLowerCase().contains("campuran")) {
      tagColor = const Color(0xFFFF6B35);
      kelas = "Campuran";
    } else {
      tagColor = Colors.pink;
      kelas = "Economy";
    }

    int sisaTiket = 0;
    if (train["sisaTiket"] is int) {
      sisaTiket = train["sisaTiket"] as int;
    } else if (train["sisaTiket"] is String) {
      sisaTiket = int.tryParse(train["sisaTiket"]) ?? 0;
    }

    bool isDeparted = false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDay = DateTime(
      controller.selectedDate.value.year,
      controller.selectedDate.value.month,
      controller.selectedDate.value.day,
    );

    if (selectedDay.isAtSameMomentAs(today)) {
      try {
        String? jadwalBerangkat = train['jadwalBerangkat'];
        if (jadwalBerangkat != null && jadwalBerangkat.isNotEmpty) {
          final timeParts = jadwalBerangkat.split(':');
          if (timeParts.length >= 2) {
            final hour = int.parse(timeParts[0]);
            final minute = int.parse(timeParts[1]);
            final departureTime = DateTime(
              now.year,
              now.month,
              now.day,
              hour,
              minute,
            );

            final cutoffTime = now.add(const Duration(minutes: 30));
            isDeparted =
                departureTime.isBefore(cutoffTime) ||
                departureTime.isAtSameMomentAs(cutoffTime);

          }
        }
      } catch (e) {
      }
    }

    bool isSoldOut = sisaTiket <= 0;
    bool isDisabled = isSoldOut || isDeparted;

    String statusText = "Available";
    Color statusColor = Colors.green;

    if (isDeparted) {
      statusText = "Sudah Berangkat";
      statusColor = Colors.red;
    } else if (isSoldOut) {
      statusText = "Habis";
      statusColor = Colors.grey;
    } else if (sisaTiket <= 20) {
      statusText = "$sisaTiket Seat${sisaTiket == 1 ? '' : 's'} Remaining";
      statusColor = Colors.orange;
    }

    return Opacity(
      opacity: isDisabled ? 0.6 : 1.0,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: cardBgColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isDisabled ? null : () => controller.selectTrain(train),
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
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
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [trainIconGradient1, trainIconGradient2],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.train_rounded,
                          color: trainIconColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          train["namaKereta"],
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: trainNameColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
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
                                color: durationTextColor,
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
                            style: TextStyle(color: priceTextColor, fontSize: 12),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "${currencyFormatter.format(train["harga"])} / Pax",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: priceAmountColor,
                            ),
                          ),
                        ],
                      ),
                      OutlinedButton(
                        onPressed: isDisabled ? null : () {},
                        style: OutlinedButton.styleFrom(
                          foregroundColor: buttonTextColor,
                          side: const BorderSide(color: buttonBorderColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text("Train Details"),
                      ),
                    ],
                  ),
                ],
              ),
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
    final buttonBgColor = Colors.orange.shade700;
    const buttonIconColor = Colors.white;
    const buttonTextColor = Colors.white;

    return Positioned(
      bottom: 30,
      left: 0,
      right: 0,
      child: Center(
        child: ElevatedButton.icon(
          onPressed: () => controller.showFilterBottomSheet(),
          icon: const Icon(Icons.filter_list, color: buttonIconColor),
          label: const Text(
            "FILTER",
            style: TextStyle(color: buttonTextColor, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonBgColor,
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
    const timeTextColor = Color(0xFF333E63);
    const codeTextColor = Colors.grey;

    return Column(
      crossAxisAlignment: align,
      children: [
        Text(
          time,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: timeTextColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(code, style: const TextStyle(fontSize: 14, color: codeTextColor)),
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

  static const defaultLineColor = Colors.grey;

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
