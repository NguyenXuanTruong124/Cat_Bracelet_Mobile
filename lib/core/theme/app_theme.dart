// app_theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF8F2022)),
    scaffoldBackgroundColor: const Color(0xFFFFF6F1),
    fontFamily: 'Roboto',
  );
}
