import 'package:flutter/material.dart';

import 'screens/home_screen.dart';

void main() {
  runApp(const CatBraceletApp());
}

class CatBraceletApp extends StatelessWidget {
  const CatBraceletApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cat Bracelet',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF8F2022)),
        scaffoldBackgroundColor: const Color(0xFFFFF6F1),
        fontFamily: 'Roboto',
      ),
      home: const HomeScreen(),
    );
  }
}
