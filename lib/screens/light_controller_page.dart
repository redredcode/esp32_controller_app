import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class LightControlPage extends StatefulWidget {
  const LightControlPage({super.key});

  @override
  State<LightControlPage> createState() => _LightControlPageState();
}

class _LightControlPageState extends State<LightControlPage> {
  final dbRef = FirebaseDatabase.instance.ref('light1');
  int lightState = 0;

  @override
  void initState() {
    super.initState();

    // Listen to realtime changes
    dbRef.onValue.listen((event) {
      final value = event.snapshot.value;
      if (value is int) {
        setState(() {
          lightState = value;
        });
      }
    });
  }

  void toggleLight(bool value) {
    dbRef.set(value ? 1 : 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ESP32 Light Control')),
      body: Center(
        child: Switch(
          value: lightState == 1,
          onChanged: toggleLight,
        ),
      ),
    );
  }
}