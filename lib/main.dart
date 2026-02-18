// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'app.dart';
// import 'firebase_options.dart';
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
//   runApp(const MyApp());
// }
//
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BLEHomePage(),
    );
  }
}

class BLEHomePage extends StatefulWidget {
  const BLEHomePage({super.key});

  @override
  State<BLEHomePage> createState() => _BLEHomePageState();
}

class _BLEHomePageState extends State<BLEHomePage> {
  BluetoothDevice? connectedDevice;
  BluetoothCharacteristic? writeChar;
  BluetoothCharacteristic? notifyChar;

  bool isConnected = false;
  String receivedData = "No data yet";

  @override
  void initState() {
    super.initState();
    initBLE();
  }

  Future<void> initBLE() async {
    FlutterBluePlus.adapterState.listen((state) async {
      if (state == BluetoothAdapterState.on) {
        await FlutterBluePlus.stopScan();
        await FlutterBluePlus.startScan(
          timeout: const Duration(seconds: 15),
          androidUsesFineLocation: true,
        );
        debugPrint("BLE scan started");
      }
    });
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    await FlutterBluePlus.stopScan();

    await device.connect(
      autoConnect: false,
      timeout: const Duration(seconds: 15),
    );

    connectedDevice = device;

    List<BluetoothService> services = await device.discoverServices();

    for (var service in services) {
      for (var char in service.characteristics) {
        if (char.properties.write) {
          writeChar = char;
        }
        if (char.properties.notify) {
          notifyChar = char;
        }
      }
    }

    if (notifyChar != null) {
      await notifyChar!.setNotifyValue(true);

      notifyChar!.onValueReceived.listen((value) {
        final msg = String.fromCharCodes(value);
        setState(() {
          receivedData = msg;
        });
      });
    }

    setState(() {
      isConnected = true;
    });
  }

  Future<void> sendToESP(String data) async {
    if (writeChar == null) return;
    await writeChar!.write(data.codeUnits);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("BLE Devices")),
      body: isConnected ? connectedUI() : scanUI(),
    );
  }

  Widget scanUI() {
    return StreamBuilder<List<ScanResult>>(
      stream: FlutterBluePlus.scanResults,
      builder: (context, snapshot) {
        final results = snapshot.data ?? [];

        if (results.isEmpty) {
          return const Center(child: Text("Scanning for BLE devices..."));
        }

        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            final r = results[index];
            final device = r.device;

            return ListTile(
              title: Text(device.name.isNotEmpty ? device.name : "Unnamed BLE Device"),
              subtitle: Text(device.id.id),
              trailing: ElevatedButton(
                child: const Text("Connect"),
                onPressed: () => connectToDevice(device),
              ),
            );
          },
        );
      },
    );
  }

  Widget connectedUI() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text("Connected to ESP32", style: TextStyle(fontSize: 18)),
          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => sendToESP("1"),
                child: const Text("LED ON"),
              ),
              ElevatedButton(
                onPressed: () => sendToESP("0"),
                child: const Text("LED OFF"),
              ),
            ],
          ),

          const SizedBox(height: 30),

          const Text("Data from ESP32:"),
          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.all(12),
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(receivedData),
          ),
        ],
      ),
    );
  }
}

