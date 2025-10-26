import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/pilih_kursi_controller.dart';

class PilihKursiView extends GetView<PilihKursiController> {
  const PilihKursiView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        Container(
          width: Get.width,
          height: Get.height,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/bg.png'),
              fit: BoxFit.cover, 
            ),
          ),
        ),
        Column(
          children: [
            SizedBox(height: context.mediaQueryPadding.top),
            Container(
              height: 100,
              padding: EdgeInsets.symmetric(horizontal: 25),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("Select Your\nSeat", style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Color(
                      0xFF333E63
                    ),
                    )
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Argo Dwipangga (10)"
                      ),
                      Obx(() => Text(
                        "Eksekutif ${controller.indexGerbong.value + 1}",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF656CEE),
                        ),
                      )),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 25),
              height: 50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  itemstatus(
                    status: "Available", 
                    color: Colors.white
                  ),
                  itemstatus(
                    status: "Filled", 
                    color: Colors.orangeAccent
                  ),
                  itemstatus(
                    status: "Selected", 
                    color: Colors.deepPurpleAccent
                  ),
                ], 
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    SizedBox(height: 30),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                            Text(
                              "Wagon",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 15),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Text(
                                  "A",
                                  style: TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                                Text(
                                  "B",
                                  style: TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                                Text(
                                  "C",
                                  style: TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                                Text(
                                  "D",
                                  style: TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25),
                        child: Row(
                          children: [
                            Container(
                            width: 60,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: Obx(() => Column(
                                children: List.generate(
                                  controller.gerbong.length,
                                  (index) => GestureDetector(
                                    onTap: () => controller.gantiGerbong(index),
                                    child: Container(
                                      margin: EdgeInsets.all(10),
                                      height: 150,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.black38,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                        color: controller.indexGerbong.value == index
                                            ? Colors.deepPurpleAccent
                                            : Colors.white,
                                      ),
                                      child: Center(
                                        child: Text(
                                          "${index + 1}",
                                          style: TextStyle(
                                            color: controller.indexGerbong.value == index
                                                ? Colors.white
                                                : Colors.black,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              )),
                            ),
                          ),
                            SizedBox(width: 17),
                            Expanded(
                              child: Container(
                                child: Obx(() => 
                                GridView.builder(
                                  padding: EdgeInsets.all(10),
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    mainAxisSpacing: 10,
                                  crossAxisSpacing: 10,
                                  crossAxisCount: 4,
                                  ),
                                  itemCount: controller.gerbong[controller.indexGerbong.value].length,
                                  itemBuilder: (context, index) => GestureDetector(
                                  onTap: () => controller.selectKursi(index),
                                  child: Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.black38,
                                        ),
                                        color: controller.gerbong[controller.indexGerbong.value][index]["status"] == "available"
                                            ? Colors.white
                                            : controller.gerbong[controller.indexGerbong.value][index]["status"] == "filled"
                                                ? Colors.orangeAccent
                                                : Colors.deepPurpleAccent,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                ),
                                  ),
                              ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 100,
              child: Center(
                child: ElevatedButton(
                  onPressed: () {
                    Get.toNamed('/detail-booking-tiket');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF656CEE),
                    fixedSize: Size(Get.width * 0.8, 50),
                  ),
                  child: Text("Select Your Seat", style: TextStyle(
                    color: Colors.white,
                  ),),
                ),
              ),
            ),
          ],
        ),
      ],
      ),
    );
  }
}

class itemstatus extends StatelessWidget {
  const itemstatus({
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
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        SizedBox(width: 7),
        Text( 
          status, 
          style: TextStyle(
          fontSize: 18,
        ),
        ),
      ],
    );
  }
}