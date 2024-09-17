// views/home_page.dart
import 'package:ble_test/ble_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomePage extends StatelessWidget {
  final BleController bleController = Get.put(BleController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE1C8C8),
      appBar: AppBar(
        title: const Text("Weight Scale"),
        backgroundColor: const Color(0xFFE1C8C8),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Obx(() {
                        String state =
                            bleController.bleState.value == BleState.connected
                                ? "Weight Scale Connected"
                                : bleController.bleState.value ==
                                        BleState.connecting
                                    ? "Weight Scale Connecting..."
                                    : bleController.bleState.value ==
                                            BleState.scanning
                                        ? "Weight Scale Scanning..."
                                        : "Tap on scan button";
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 18),
                          child: Text(
                            state,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[800],
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed:
                          bleController.bleState.value == BleState.scanning
                              ? null
                              : () {
                                  bleController.requestPermissions();
                                },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 242, 233, 233),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "Scan",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
              Obx(() {
                final data = bleController.bleData.value;
                if (data != null) {
                  return Expanded(
                    child: Column(
                      children: [
                        Text("data: $data"),
                      ],
                    ),
                  );
                } else {
                  return const Text("No product data available");
                }
              }),
            ],
          ),
        ),
      ),
    );
  }
}
