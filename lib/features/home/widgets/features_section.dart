import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FeaturesSection extends StatelessWidget{
  const FeaturesSection({super.key});
  static const Color wine = AppColors.wine;
  static const Color gold = AppColors.gold;
  static const Color taupe = AppColors.taupe;

  static Widget buildFeaturesSection() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(
        vertical: 40.h,
        horizontal: 16.w,
      ),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 16.w,
        runSpacing: 20.h,
        children: [
          SizedBox(
            width: 130.w,
            child: _buildFeatureItem(
              Icons.diamond_outlined,
              'ĐÁ TỰ NHIÊN',
              '100% tự nhiên',
            ),
          ),
          SizedBox(
            width: 130.w,
            child: _buildFeatureItem(
              Icons.design_services_outlined,
              'THIẾT KẾ',
              'Độc bản',
            ),
          ),
          SizedBox(
            width: 130.w,
            child: _buildFeatureItem(
              Icons.handshake_outlined,
              'TƯƠNG THÍCH',
              'Hợp cung mệnh',
            ),
          ),
          SizedBox(
            width: 130.w,
            child: _buildFeatureItem(
              Icons.wb_sunny_outlined,
              'NĂNG LƯỢNG',
              'Tích cực',
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildFeatureItem(
      IconData icon,
      String title,
      String subtitle,
      ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: gold,
          size: 40.sp,
        ),

        SizedBox(height: 12.h),

        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12.sp,
            color: wine,
          ),
        ),

        SizedBox(height: 4.h),

        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11.sp,
            color: taupe,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return buildFeaturesSection();
  }
}