import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AppInputDecoration {
  static const Color _wine = AppColors.wine;
  static const Color _gold = AppColors.gold;
  static const Color _softRose = AppColors.softRose;

  static InputDecoration build({required String label, IconData? icon}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: icon == null ? null : Icon(icon),
      isDense: true,
      filled: true,
      fillColor: _softRose,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: _gold.withValues(alpha: 0.35)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: _gold.withValues(alpha: 0.35)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: _wine, width: 1.4),
      ),
    );
  }
}