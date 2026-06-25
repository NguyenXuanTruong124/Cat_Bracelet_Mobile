import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24.r),
              topRight: Radius.circular(24.r),
            ),
            child: Image.asset(
              'assets/images/home_ne_3.jpg',
              width: double.infinity,
              height: 220.h,
              fit: BoxFit.cover,
            ),
          ),

          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 24.w,
              vertical: 28.h,
            ),
            child: Column(
              children: [
                Text(
                  'Năng lượng tinh khiết',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontFamily: 'serif',
                    fontWeight: FontWeight.w700,
                    color: wine,
                  ),
                ),

                SizedBox(height: 8.h),

                Text(
                  'Phong cách tinh tế',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32.sp,
                    fontFamily: 'serif',
                    fontWeight: FontWeight.w800,
                    color: wine,
                    height: 1.15,
                  ),
                ),

                SizedBox(height: 18.h),

                Text(
                  'Không chỉ là một chiếc vòng.\nĐó là năng lượng bạn chọn mang theo mỗi ngày.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.black87,
                    height: 1.6,
                  ),
                ),

                SizedBox(height: 24.h),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/collection',
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: wine,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(
                        vertical: 14.h,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                    ),
                    child: Text(
                      'Khám phá bộ sưu tập',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}