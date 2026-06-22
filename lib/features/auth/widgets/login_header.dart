import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';
import 'gem_divider.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Cat Bracelet',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.wine,
            fontFamily: 'serif',
            fontSize: 36.sp,
            fontWeight: FontWeight.w800,
            height: 1.05,
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'Năng lượng tinh khiết\n phong cách tinh tế',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: const Color(0xFFA08E8C),
            fontSize: 21.sp,
            fontWeight: FontWeight.w600,
            height: 1.42,
          ),
        ),
        const SizedBox(height: 34),
        const GemDivider(),
      ],
    );
  }
}
