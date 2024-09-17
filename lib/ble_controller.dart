// controllers/ble_controller.dart
import 'dart:convert';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

enum BleState { initial, scanning, connecting, connected, disconnected }

class BleController extends GetxController {
  var bleState = BleState.initial.obs;
  BluetoothDevice? connectedDevice;

  final String serviceUUID = "4fafc201-1fb5-459e-8fcc-c5c9c331914b";
  final String characteristicUUIDTx = "beb5483e-36e1-4688-b7f5-ea07361b26a8";

  BluetoothCharacteristic? controlCharacteristic;

  // States for buttons and timer
  var isMotionOn = false.obs;
  var isHeatOn = false.obs;
  var isVibrationOn = false.obs;
  var timerValue = 0.obs;

  @override
  void onInit() {
    super.onInit();
    requestPermissions();
  }

  Future<void> requestPermissions() async {
    try {
      await Permission.bluetooth.request();
      await Permission.location.request();
      startScan();
    } on Exception catch (e) {
      bleState.value = BleState.initial;
      print("Error requesting permissions: $e");
    }
  }

  void startScan() async {
    await connectedDevice?.disconnect();
    FlutterBluePlus.startScan(timeout: const Duration(seconds: 4));
    bleState.value = BleState.scanning;
    FlutterBluePlus.scanResults.listen((results) {
      for (ScanResult result in results) {
        if (result.device.advName == 'ble_test') {
          stopScan();
          connectToDevice(result.device);
          break;
        }
      }
    });
  }

  void stopScan() {
    FlutterBluePlus.stopScan();
    bleState.value = BleState.connecting;
  }

  void connectToDevice(BluetoothDevice device) async {
    bleState.value = BleState.connecting;
    try {
      await device.disconnect(); // Ensures a fresh connection
      await device.connect();
      connectedDevice = device;
      bleState.value = BleState.connected;
      discoverServices(device);
    } catch (e) {
      print("Error connecting to device: $e");
      bleState.value = BleState.disconnected;
    }
  }

  void discoverServices(BluetoothDevice device) async {
    try {
      List<BluetoothService> services = await device.discoverServices();
      for (BluetoothService service in services) {
        if (service.uuid.toString() == serviceUUID) {
          for (BluetoothCharacteristic characteristic
              in service.characteristics) {
            if (characteristic.uuid.toString() == characteristicUUIDTx) {
              controlCharacteristic = characteristic;
            }
          }
        }
      }
    } catch (e) {
      print("Error discovering services: $e");
      bleState.value = BleState.disconnected;
    }
  }

  void sendControlData() async {
    if (controlCharacteristic != null) {
      Map<String, dynamic> controlData = {
        "motion": isMotionOn.value ? "on" : "off",
        "heat": isHeatOn.value ? "on" : "off",
        "vibration": isVibrationOn.value ? "on" : "off",
        "timer": timerValue.value
      };
      String jsonString = jsonEncode(controlData);
      try {
        await controlCharacteristic!.write(utf8.encode(jsonString));
        print("Sent data: $jsonString");
      } catch (e) {
        print("Error sending data: $e");
        bleState.value =
            BleState.disconnected; // Set state to disconnected on error
      }
    } else {
      print("Control characteristic not found");
      bleState.value = BleState.disconnected;
    }
  }
}
