import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FooterSection extends StatelessWidget {
    const FooterSection({super.key});
  static const Color wine = AppColors.wine;
  static const Color gold = AppColors.gold;

  static Widget buildFooter() {
    return Container(
      width: double.infinity,
      color: wine,
      padding: EdgeInsets.all(32.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cát Bracelet',
            style: TextStyle(
              fontFamily: 'serif',
              fontSize: 28.sp,
              color: gold,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 8.h),

          Text(
            'Năng lượng tinh khiết\nPhong cách tinh tế',
            style: TextStyle(
              color: Colors.white,
              height: 1.5,
              fontSize: 14.sp,
            ),
          ),

          SizedBox(height: 24.h),

          Text(
            '© 2026 Cat Bracelet. All rights reserved.',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 12.sp,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return buildFooter();
  }
}