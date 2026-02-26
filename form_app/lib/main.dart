import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

void main() => runApp(const MaterialApp(home: ArduinoBlePage()));

class ArduinoBlePage extends StatefulWidget {
  const ArduinoBlePage({super.key});

  @override
  State<ArduinoBlePage> createState() => _ArduinoBlePageState();
}

class _ArduinoBleAppState extends State<ArduinoBlePage> {
  List<ScanResult> scanResults = [];
  BluetoothDevice? connectedDevice;
  bool isScanning = false;

  @override
  void initState() {
    super.initState();
    // Request permissions as soon as the app starts
    _requestPermissions();
  }

  void _requestPermissions() async {
    await [Permission.bluetoothScan, Permission.bluetoothConnect, Permission.location].request();
  }

  void startScan() async {
    setState(() {
      scanResults.clear();
      isScanning = true;
    });
    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));
    FlutterBluePlus.scanResults.listen((results) {
      if (mounted) setState(() => scanResults = results);
    });
    await Future.delayed(const Duration(seconds: 5));
    setState(() => isScanning = false);
  }

  void connect(BluetoothDevice device) async {
    await device.connect();
    await device.discoverServices();
    setState(() => connectedDevice = device);
  }

  void sendTestSignal() async {
    if (connectedDevice == null) return;
    var services = await connectedDevice!.discoverServices();
    for (var s in services) {
      for (var c in s.characteristics) {
        if (c.properties.write) {
          // Sending 'H' (0x48) to trigger the Arduino
          await c.write([0x48]); 
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Arduino Wireless Pro")),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: isScanning ? null : startScan,
            child: Text(isScanning ? "Scanning..." : "Find Arduino"),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: scanResults.length,
              itemBuilder: (c, i) => ListTile(
                title: Text(scanResults[i].device.platformName.isEmpty ? "Unknown" : scanResults[i].device.platformName),
                subtitle: Text(scanResults[i].device.remoteId.toString()),
                onTap: () => connect(scanResults[i].device),
              ),
            ),
          ),
          if (connectedDevice != null)
            Padding(
              padding: const EdgeInsets.all(20),
              child: ElevatedButton(
                onPressed: sendTestSignal,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text("SEND TEST SIGNAL ('H')"),
              ),
            ),
        ],
      ),
    );
  }
}
