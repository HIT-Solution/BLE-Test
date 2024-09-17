// controllers/ble_controller.dart
import 'dart:convert';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

enum BleState { initial, scanning, connecting, connected, disconnected }

class BleController extends GetxController {
  var bleState = BleState.initial.obs;
  BluetoothDevice? connectedDevice;
  Rx<String?> bleData = Rx<String?>(null);

  final String serviceUUID = "4fafc201-1fb5-459e-8fcc-c5c9c331914b";
  final String characteristicUUIDRx = "beb5483e-36e1-4688-b7f5-ea07361b26a8";
  final String characteristicUUIDTx = "beb5483e-36e1-4688-b7f5-ea07361b26a9";

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
    await device.disconnect();
    await device.connect();
    connectedDevice = device;
    bleState.value = BleState.connected;
    discoverServices(device);
  }

  void discoverServices(BluetoothDevice device) async {
    List<BluetoothService> services = await device.discoverServices();
    for (BluetoothService service in services) {
      if (service.uuid.toString() == serviceUUID) {
        for (BluetoothCharacteristic characteristic
            in service.characteristics) {
          if (characteristic.uuid.toString() == characteristicUUIDTx) {
            characteristic.setNotifyValue(true);
            characteristic.lastValueStream.listen((value) {
              String data = String.fromCharCodes(value);
              bleData.value = data;
              print("Received: $data");
            }).onError((handleError) {
              bleState.value = BleState.initial;
              print("Error: $handleError");
            });
          }
        }
      }
    }
  }
}
