import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'control_page.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  @override
  void initState() {
    super.initState();
    FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("BLE Devices")),
      body: StreamBuilder<List<ScanResult>>(
        stream: FlutterBluePlus.scanResults,
        builder: (context, snapshot) {
          final devices = snapshot.data ?? [];
          return ListView.builder(
            itemCount: devices.length,
            itemBuilder: (context, index) {
              final d = devices[index].device;
              return ListTile(
                title: Text(d.platformName.isEmpty ? "Unknown" : d.platformName),
                onTap: () {
                  FlutterBluePlus.stopScan();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ControlPage(device: d),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}