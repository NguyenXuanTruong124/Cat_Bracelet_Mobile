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
              'assets/images/thanhtay.png',
              'Thanh tẩy',
              'Làm sạch năng lượng xấu, loại bỏ tạp khí.',
            ),
          ),
          SizedBox(
            width: 130.w,
            child: _buildFeatureItem(
              'assets/images/kichhoat.png',
              'KÍCH HOẠT',
              'Nạp năng lượng tích cực phù hợp với bạn.',
            ),
          ),
          SizedBox(
            width: 130.w,
            child: _buildFeatureItem(
              'assets/images/canbang.png',
              'CÂN BẰNG',
              'Hỗ trợ cân bằng cảm xúc, tinh thần & cơ thể.',
            ),
          ),
          SizedBox(
            width: 130.w,
            child: _buildFeatureItem(
              'assets/images/donghanh.png',
              'ĐỒNG HÀNH',
              'Thu hút may mắn, bảo vệ và nâng cao năng lượng.',
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildFeatureItem(
      String image,
      String title,
      String subtitle,
      ) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: Image.asset(
              image,
              width: 70.w,
              height: 70.w,
              fit: BoxFit.cover,
            ),
          ),

          SizedBox(height: 12.h),

          Text(title),
          Text(subtitle),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return buildFeaturesSection();
  }
}