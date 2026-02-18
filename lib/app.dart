import 'package:esp32_controller/screens/light_controller_page.dart';
import 'package:esp32_controller/screens/scan_page.dart';
import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const ScanPage(),
    );
  }
}