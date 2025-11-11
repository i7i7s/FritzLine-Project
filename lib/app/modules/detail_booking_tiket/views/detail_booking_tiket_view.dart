import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/detail_booking_tiket_controller.dart';
import '../../../services/settings_service.dart';

class DetailBookingTiketView extends GetView<DetailBookingTiketController> {
  const DetailBookingTiketView({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsService = Get.find<SettingsService>();

    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(),
          Column(
            children: [
              _buildCustomAppBar(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTrainCard(),
                      const SizedBox(height: 20),
                      _buildPassengerCard(),
                      const SizedBox(height: 20),
                      _buildSeatCard(),
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ),
            ],
          ),
          _buildBottomButton(context, settingsService),
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

  Widget _buildCustomAppBar() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF656CEE), Color(0xFF4147D5)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Get.back(),
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Detail Booking Tiket",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Konfirmasi pemesanan Anda",
                      style: TextStyle(fontSize: 13, color: Colors.white70),
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

  Widget _buildTrainCard() {
    return Obx(() {
      if (controller.trainData.isEmpty) return const SizedBox();
      final train = controller.trainData;
      return Container(
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
        child: Material(
          color: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF656CEE), Color(0xFF4147D5)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.train_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            train["namaKereta"],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF333E63),
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            controller.currencyFormatter.format(train["harga"]),
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF656CEE),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.grey.shade200,
                        Colors.grey.shade300,
                        Colors.grey.shade200,
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    _buildTimeColumn(
                      train["stasiunBerangkat"],
                      train["jadwalBerangkat"],
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: DottedLine(
                        color: Color(0xFF656CEE),
                        dashWidth: 5.0,
                        height: 2,
                      ),
                    ),
                    const SizedBox(width: 10),
                    _buildTimeColumn(
                      train["stasiunTiba"],
                      train["jadwalTiba"],
                      align: CrossAxisAlignment.end,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildTag(train["kelas"]),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F7FA),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Text(
                                train["durasi"],
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF333E63),
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () =>
                                    controller.showTimezoneBottomSheet(),
                                child: const Icon(
                                  Icons.access_time_rounded,
                                  size: 18,
                                  color: Color(0xFF656CEE),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildPassengerCard() {
    return Container(
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
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF656CEE), Color(0xFF4147D5)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.people_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "Detail Penumpang",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333E63),
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.grey.shade200,
                      Colors.grey.shade300,
                      Colors.grey.shade200,
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Obx(
                () => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: controller.passengerData.asMap().entries.map((
                    entry,
                  ) {
                    int idx = entry.key + 1;
                    Map<String, String> passenger = entry.value;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12.0),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F7FA),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey.shade200,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFF6B35), Color(0xFFFF8C5A)],
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                "$idx",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  passenger['nama'] ?? '',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF333E63),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  passenger['id_number'] ?? '',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSeatCard() {
    return Container(
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
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF6B35), Color(0xFFFF8C5A)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.event_seat_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "Detail Kursi",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333E63),
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.grey.shade200,
                      Colors.grey.shade300,
                      Colors.grey.shade200,
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Obx(
                () => Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: controller.selectedSeats.map((seat) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF656CEE), Color(0xFF4147D5)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF656CEE).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.chair_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            seat,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomButton(
    BuildContext context,
    SettingsService settingsService,
  ) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.fromLTRB(
          20,
          24,
          20,
          MediaQuery.of(context).padding.bottom + 20,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Obx(
                    () => Text(
                      "Total Harga (${settingsService.preferredCurrency.value})",
                      style: const TextStyle(
                        color: Color(0xFF999999),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Flexible(
                        child: Obx(
                          () => Text(
                            settingsService.formatPrice(
                              controller.totalHarga.value,
                            ),
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF656CEE),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F7FA),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: GestureDetector(
                          onTap: () => controller.showCurrencyBottomSheet(),
                          child: const Icon(
                            Icons.calculate_outlined,
                            size: 20,
                            color: Color(0xFF656CEE),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF6B35), Color(0xFFFF8C5A)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF6B35).withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => controller.konfirmasiPembayaran(),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 32,
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.payment_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        SizedBox(width: 10),
                        Text(
                          "BAYAR",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
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
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF333E63),
          letterSpacing: 0.5,
        ),
      ),
      const SizedBox(height: 6),
      Text(
        time,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey.shade600,
          fontWeight: FontWeight.w500,
        ),
      ),
    ],
  );
}

Widget _buildTag(String text) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          const Color(0xFFFF6B35).withOpacity(0.15),
          const Color(0xFFFF8C5A).withOpacity(0.15),
        ],
      ),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(
        color: const Color(0xFFFF6B35).withOpacity(0.3),
        width: 1.5,
      ),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.class_rounded, size: 16, color: Color(0xFFFF6B35)),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            color: Color(0xFFFF6B35),
            fontWeight: FontWeight.bold,
            fontSize: 13,
            letterSpacing: 0.3,
          ),
        ),
      ],
    ),
  );
}
