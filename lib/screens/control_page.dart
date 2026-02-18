import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class ControlPage extends StatefulWidget {
  final BluetoothDevice device;
  const ControlPage({super.key, required this.device});

  @override
  State<ControlPage> createState() => _ControlPageState();
}

class _ControlPageState extends State<ControlPage> {
  BluetoothCharacteristic? writeChar;
  BluetoothCharacteristic? notifyChar;

  int lightState = 0;

  @override
  void initState() {
    super.initState();
    connect();
  }

  void connect() async {
    await widget.device.connect();
    final services = await widget.device.discoverServices();

    for (var s in services) {
      for (var c in s.characteristics) {
        if (c.uuid.toString().startsWith("aaaaaaaa")) {
          writeChar = c;
        }
        if (c.uuid.toString().startsWith("ffffffff")) {
          notifyChar = c;
          await c.setNotifyValue(true);
          c.value.listen((value) {
            setState(() {
              lightState = value.first;
            });
          });
        }
      }
    }
  }

  void toggle(bool value) {
    writeChar?.write([value ? 1 : 0]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("ESP32 Control")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Switch(
            value: lightState == 1,
            onChanged: toggle,
          ),
          Text(
            "ESP32 says: $lightState",
            style: const TextStyle(fontSize: 24),
          ),
        ],
      ),
    );
  }
}