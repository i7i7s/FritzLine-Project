import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/ringkasan_pemesanan_controller.dart';

class RingkasanPemesananView extends GetView<RingkasanPemesananController> {
  const RingkasanPemesananView({super.key});

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
          Column(
            children: [
              _buildCustomAppBar(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTrainCard(currencyFormatter),
                      const SizedBox(height: 24),
                      _buildSavedPassengers(),
                      const SizedBox(height: 24),
                      _buildPassengerDetailsTitle(),
                      _buildPassengerFormsList(),
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ),
            ],
          ),
          _buildBottomButtons(context),
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
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF656CEE), Color(0xFF4147D5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF656CEE).withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Row(
            children: [
              Container(
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Get.back(),
                ),
              ),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Ringkasan Pemesanan",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      "Lengkapi data penumpang Anda",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                        fontWeight: FontWeight.w400,
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

  Widget _buildTrainCard(NumberFormat currencyFormatter) {
    final train = controller.trainData;
    if (train.isEmpty) {
      return const Center(child: Text("Memuat data kereta..."));
    }

    return Container(
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
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
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        train["namaKereta"] ?? 'Nama Kereta',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1B1B1F),
                        ),
                      ),
                      const SizedBox(height: 4),
                      _buildTag(train["kelas"]),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildTimeColumn(
                    train["stasiunBerangkat"],
                    train["jadwalBerangkat"],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      Text(
                        train["durasi"],
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF656CEE),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const DottedLine(),
                    ],
                  ),
                ),
                Expanded(
                  child: _buildTimeColumn(
                    train["stasiunTiba"],
                    train["jadwalTiba"],
                    align: CrossAxisAlignment.end,
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            // Price and passenger count
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6B35).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.people_alt,
                        color: Color(0xFFFF6B35),
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "${controller.passengerCount.value} Penumpang",
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF333E63),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      "Total Harga",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      currencyFormatter.format(train["harga"]),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF656CEE),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavedPassengers() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFFFF6B35).withOpacity(0.1),
                const Color(0xFFFF6B35).withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF6B35), Color(0xFFFF8C5A)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.favorite_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                "Penumpang Tersimpan",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF333E63),
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Obx(() {
          if (controller.savedPassengers.isEmpty) {
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.grey.shade400, size: 20),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      "Anda belum memiliki penumpang tersimpan",
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ),
                ],
              ),
            );
          }
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: controller.savedPassengers.map((passenger) {
                return Container(
                  width: 180,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 12,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                                Icons.person,
                                color: Color(0xFF656CEE),
                                size: 18,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF4CAF50).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                "Saved",
                                style: TextStyle(
                                  color: Color(0xFF4CAF50),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          passenger.nama,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: Color(0xFF1B1B1F),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "ID: ${passenger.idNumber}",
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () =>
                                controller.applySavedPassenger(passenger),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF6B35),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                            child: const Text(
                              "Tambahkan",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildPassengerDetailsTitle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF656CEE).withOpacity(0.1),
            const Color(0xFF656CEE).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF656CEE), Color(0xFF4147D5)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.people_alt_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            "Detail Penumpang",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF333E63),
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPassengerFormsList() {
    return Obx(
      () => ListView.builder(
        itemCount: controller.formList.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 10),
        itemBuilder: (context, index) {
          return _buildPassengerForm(index);
        },
      ),
    );
  }

  Widget _buildPassengerForm(int index) {
    final formControllers = controller.formList[index];
    return Obx(
      () => Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ExpansionTile(
          key: PageStorageKey('passenger_$index'),
          initiallyExpanded: formControllers.isExpanded.value,
          onExpansionChanged: (newState) =>
              controller.toggleExpansion(index, newState),
          backgroundColor: Colors.transparent,
          collapsedBackgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: EdgeInsets.zero,
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF6B35), Color(0xFFFF8C5A)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "Penumpang ${index + 1}",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1B1B1F),
                ),
              ),
            ],
          ),
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(flex: 2, child: _buildDropdownField(index)),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 3,
                        child: _buildTextField(
                          label: "Nomor identitas",
                          controller: formControllers.idNumberController,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: "Nama lengkap",
                    controller: formControllers.fullNameController,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF656CEE).withOpacity(0.05),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Obx(
                      () => CheckboxListTile(
                        value: formControllers.savePassenger.value,
                        onChanged: (val) =>
                            controller.toggleSavePassenger(index, val),
                        title: const Text(
                          "Simpan penumpang ini",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF333E63),
                          ),
                        ),
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                        activeColor: const Color(0xFF656CEE),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButtons(BuildContext context) {
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
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Obx(() {
          final bool hasSeats =
              controller.bookingService.selectedSeats.isNotEmpty;
          return Row(
            children: [
              Expanded(
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFF656CEE),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF656CEE).withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => controller.goToPilihKursi(),
                      borderRadius: BorderRadius.circular(14),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.event_seat_rounded,
                              color: Color(0xFF656CEE),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              hasSeats ? "UBAH KURSI" : "PILIH KURSI",
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF656CEE),
                                fontSize: 15,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: hasSeats
                        ? const LinearGradient(
                            colors: [Color(0xFFFF6B35), Color(0xFFFF8C5A)],
                          )
                        : null,
                    color: hasSeats ? null : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: hasSeats
                        ? [
                            BoxShadow(
                              color: const Color(0xFFFF6B35).withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: hasSeats ? () => controller.goToDetailBooking() : null,
                      borderRadius: BorderRadius.circular(14),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "LANJUTKAN",
                              style: TextStyle(
                                color: hasSeats ? Colors.white : Colors.grey.shade500,
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(
                              Icons.arrow_forward_rounded,
                              color: hasSeats ? Colors.white : Colors.grey.shade500,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF333E63),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            filled: true,
            fillColor: const Color(0xFFF5F7FA),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.grey.shade200,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF656CEE),
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Jenis Identitas",
          style: TextStyle(
            fontSize: 13,
            color: Color(0xFF333E63),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Obx(
          () => DropdownButtonFormField<String>(
            value: controller.formList[index].selectedIdType.value,
            items: controller.idTypes.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
            onChanged: (newValue) => controller.changeIdType(index, newValue),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
              filled: true,
              fillColor: const Color(0xFFF5F7FA),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Colors.grey.shade200,
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF656CEE),
                  width: 2,
                ),
              ),
            ),
            icon: const Icon(
              Icons.arrow_drop_down_rounded,
              color: Color(0xFF656CEE),
            ),
          ),
        ),
      ],
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
