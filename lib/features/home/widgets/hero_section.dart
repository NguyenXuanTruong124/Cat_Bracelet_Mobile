import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  static const Color wine = AppColors.wine;
  static const Color cream = AppColors.cream;
  static const Color softRose = AppColors.softRose;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: cream,
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 40,
      ),
      child: Column(
        children: [
          const Text(
            'Năng lượng tinh khiết',
            style: TextStyle(
              fontSize: 28,
              fontFamily: 'serif',
              fontWeight: FontWeight.w600,
              color: wine,
            ),
          ),

          const Text(
            'Phong cách tinh tế',
            style: TextStyle(
              fontSize: 32,
              fontFamily: 'serif',
              fontWeight: FontWeight.w800,
              color: wine,
            ),
          ),

          const SizedBox(height: 16),

          const Text(
            'Không chỉ là một chiếc vòng.\nĐó là năng lượng bạn chọn\nmang theo mỗi ngày.',
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 32),

          Image.asset(
            'assets/images/home_ne.png',
            height: 250,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }
}