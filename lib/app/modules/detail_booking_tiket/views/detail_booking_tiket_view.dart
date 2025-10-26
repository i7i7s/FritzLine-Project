import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/detail_booking_tiket_controller.dart';

class DetailBookingTiketView extends GetView<DetailBookingTiketController> {
  const DetailBookingTiketView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DetailBookingTiketView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'DetailBookingTiketView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
