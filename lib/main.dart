import 'package:flutter/material.dart';
import 'package:skillpp_kelas12/screens/login.dart';
// import 'package:skillpp_kelas12/screens/contoh.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(debugShowCheckedModeBanner: false, home: Login());
  }
}
