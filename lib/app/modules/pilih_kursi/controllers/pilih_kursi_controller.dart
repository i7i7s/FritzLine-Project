import 'package:get/get.dart';
import 'package:flutter/material.dart';

class PilihKursiController extends GetxController {
  var indexGerbong = 0.obs;

  void reset() {
    gerbong.forEach((element) {
      element.forEach((element) {
        if (element["status"] != "filled") {
          element.update("status", (value) => "available");
        }
      });
    });
  }

  void gantiGerbong(int indexGerbongTerpilih) {
    indexGerbong.value = indexGerbongTerpilih;
    gerbong.refresh();
  }

  void selectKursi(int indexKursiTerpilih) {
    print(gerbong[indexGerbong.value][indexKursiTerpilih]);
    if (gerbong[indexGerbong.value][indexKursiTerpilih]["status"] ==
        "available") {
      reset();
      gerbong[indexGerbong.value][indexKursiTerpilih]
          .update("status", (value) => "selected");
      Get.snackbar(
        "Seat Selected",
        "Kursi ${gerbong[indexGerbong.value][indexKursiTerpilih]["id"]} berhasil dipilih!",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.deepPurpleAccent.withOpacity(0.9),
        colorText: Colors.white,
        margin: const EdgeInsets.all(10),
        borderRadius: 10,
        duration: const Duration(seconds: 2),
      );
    }
    gerbong.refresh();
  }

  var gerbong = List.generate(5, (indexG) {
    return List<Map<String, dynamic>>.generate(50, (indexK) {
      if (indexG == 0) {
        if (indexK >= 24 && indexK <= 29) {
          return {
            "id": "ID-${indexG + 1}-${indexK + 1}",
            "status": "filled",
          };
        } else {
          return {
            "id": "ID-${indexG + 1}-${indexK + 1}",
            "status": "available",
          };
        }
      } else if (indexG == 1) {
        if (indexK >= 6 && indexK <= 7) {
          return {
            "id": "ID-${indexG + 1}-${indexK + 1}",
            "status": "filled",
          };
        } else {
          return {
            "id": "ID-${indexG + 1}-${indexK + 1}",
            "status": "available",
          };
        }
      } else {
        return {
          "id": "ID-${indexG + 1}-${indexK + 1}",
          "status": "available",
        };
      }
    });
  }).obs;
}
