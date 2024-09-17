// views/system_screen.dart
import 'package:ble_test/ble_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SystemScreen extends StatelessWidget {
  final BleController bleController = Get.put(BleController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE1C8C8),
      appBar: AppBar(
        title: const Text("Control System"),
        backgroundColor: const Color(0xFFE1C8C8),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Show current BLE state
              Obx(() {
                String state =
                    bleController.bleState.value == BleState.connected
                        ? "Device Connected"
                        : bleController.bleState.value == BleState.connecting
                            ? "Connecting..."
                            : bleController.bleState.value == BleState.scanning
                                ? "Scanning..."
                                : "Not Connected";

                return Column(
                  children: [
                    Text(
                      state,
                      style: TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 20),

                    // Show "Connect" button if not connected
                    if (bleController.bleState.value != BleState.connected)
                      ElevatedButton(
                        onPressed: () {
                          bleController.startScan(); // Start scanning again
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          "Connect",
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                  ],
                );
              }),

              const SizedBox(height: 20),

              // Motion Control Button
              Obx(() {
                return ElevatedButton(
                  onPressed: () {
                    bleController.isMotionOn.value =
                        !bleController.isMotionOn.value;
                    bleController.sendControlData();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: bleController.isMotionOn.value
                        ? Colors.green
                        : Colors.grey,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    bleController.isMotionOn.value ? "Motion ON" : "Motion OFF",
                    style: const TextStyle(fontSize: 16),
                  ),
                );
              }),

              const SizedBox(height: 20),

              // Heat Control Button
              Obx(() {
                return ElevatedButton(
                  onPressed: () {
                    bleController.isHeatOn.value =
                        !bleController.isHeatOn.value;
                    bleController.sendControlData();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        bleController.isHeatOn.value ? Colors.red : Colors.grey,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    bleController.isHeatOn.value ? "Heat ON" : "Heat OFF",
                    style: const TextStyle(fontSize: 16),
                  ),
                );
              }),

              const SizedBox(height: 20),

              // Vibration Control Button
              Obx(() {
                return ElevatedButton(
                  onPressed: () {
                    bleController.isVibrationOn.value =
                        !bleController.isVibrationOn.value;
                    bleController.sendControlData();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: bleController.isVibrationOn.value
                        ? Colors.blue
                        : Colors.grey,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    bleController.isVibrationOn.value
                        ? "Vibration ON"
                        : "Vibration OFF",
                    style: const TextStyle(fontSize: 16),
                  ),
                );
              }),

              const SizedBox(height: 20),

              // Timer Field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: TextField(
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Timer (seconds)",
                  ),
                  onChanged: (value) {
                    bleController.timerValue.value = int.tryParse(value) ?? 0;
                  },
                ),
              ),

              const SizedBox(height: 20),

              // Send Button
              ElevatedButton(
                onPressed: () {
                  bleController.sendControlData();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Send Data",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
