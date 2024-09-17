import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MaterialApp(debugShowCheckedModeBanner: false, home: MyApp()));
}

enum BleState { initial, scanning, connecting, connected, disconnected }

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // bool isScanning = false;
  // bool isConnected = false;
  BleState bleState = BleState.initial;
  // UUIDs
  final String serviceUUID = "4fafc201-1fb5-459e-8fcc-c5c9c331914b";
  final String characteristicUUIDRx = "beb5483e-36e1-4688-b7f5-ea07361b26a8";
  final String characteristicUUIDTx = "beb5483e-36e1-4688-b7f5-ea07361b26a9";

  BluetoothDevice? connectedDevice;
  List<BluetoothService> services = [];

  @override
  void initState() {
    super.initState();
    requestPermissions();
  }

  startScan() async {
    FlutterBluePlus.startScan(timeout: const Duration(seconds: 4));
    FlutterBluePlus.scanResults.listen((results) {
      for (ScanResult result in results) {
        print('${result.device.advName} found! rssi: ${result.rssi}');
      }
    });
    FlutterBluePlus.scanResults.listen((List<ScanResult> results) {
      for (ScanResult result in results) {
        if (result.device.advName == 'ble_test') {
          stopScan();
          connectToDevice(result.device);
          break;
        }
      }
    });
  }

  stopScan() {
    FlutterBluePlus.stopScan();
    setState(() {
      bleState = BleState.connecting;
    });
  }

  connectToDevice(BluetoothDevice device) async {
    setState(() {
      bleState = BleState.connecting;
    });
    await device.disconnect();
    await device.connect();
    setState(() {
      bleState = BleState.connected;
    });
    print("Device connected");
    discoverServices(device);
  }

  Product? productData;

  discoverServices(BluetoothDevice device) async {
    List<BluetoothService> services = await device.discoverServices();
    for (BluetoothService service in services) {
      if (service.uuid.toString() == serviceUUID) {
        for (BluetoothCharacteristic characteristic
            in service.characteristics) {
          if (characteristic.uuid.toString() == characteristicUUIDTx) {
            characteristic.setNotifyValue(true);
            characteristic.lastValueStream.listen((value) {
              // Handle the received data
              // Decode JSON and update UI
              String jsonString = String.fromCharCodes(value);
              setState(() {
                productData = Product.fromJson(jsonDecode(jsonString));
              });
              print("Received: $jsonString");
            }).onError((handleError) {
              setState(() {
                bleState = BleState.initial;
              });
              print("handleError: ${handleError}");
            });
          }
        }
      }
    }
  }

  Future<void> requestPermissions() async {
    try {
      print("run 2");
      await Permission.bluetooth.request();
      await Permission.location.request();
      print("run 3");
      startScan();
    } on Exception catch (e) {
      setState(() {
        bleState = BleState.initial;
      });
      print("requestPermissions: ${e.toString()}");
      print("error $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    String state = bleState == BleState.connected
        ? "Weight Scale Connected"
        : bleState == BleState.connecting
            ? "Weight Scale Connecting..."
            : bleState == BleState.scanning
                ? "Weight Scale Scanning..."
                : "Tap on scan button";
    return Scaffold(
      backgroundColor: const Color(0xFFE1C8C8),
      //  resizeToAvoidBottomInset: false,
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
                      child: Container(
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
                      ),
                    ),
                    const SizedBox(
                        width: 16), // Spacing between text and button
                    ElevatedButton(
                      onPressed: bleState == BleState.scanning
                          ? null
                          : requestPermissions,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(
                            255, 242, 233, 233), // Soft red button color
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
              // Expanded(
              //   child: ProductScreen(
              //     potatoWeight: productData?.potato ?? "",
              //     onionWeight: productData?.onion ?? "",
              //     riceWeight: productData?.rice ?? "",
              //     oatsWeight: productData?.oats ?? "",
              //     isBLEConnected: productData != null,
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}

class Product {
  final String potato;
  final String onion;
  final String rice;
  final String oats;

  Product(
      {required this.potato,
      required this.onion,
      required this.rice,
      required this.oats});

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      potato: json['potato'].toString(),
      onion: json['onion'].toString(),
      rice: json['rice'].toString(),
      oats: json['oats'].toString(),
    );
  }
}
