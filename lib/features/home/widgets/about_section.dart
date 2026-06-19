import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AboutSection extends StatelessWidget{
  const AboutSection({super.key});
  static const Color wine =  AppColors.wine;
  static const Color gold =  AppColors.gold;
  static const Color cream =  AppColors.cream;
  static const Color softRose =  AppColors.softRose;
  static const Color taupe =  AppColors.taupe;

  static Widget buildAboutSection() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(24.w),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 700;

          if (isMobile) {
            return Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(100.r),
                  child: Image.asset(
                    'assets/images/vongtay.png',
                    height: 220.h,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Container(color: softRose, height: 220.h),
                  ),
                ),
                SizedBox(height: 24.h),

                const Text(
                  'Cát là gì?',
                  style: TextStyle(
                    fontSize: 26,
                    fontFamily: 'serif',
                    fontWeight: FontWeight.bold,
                    color: wine,
                  ),
                ),

                SizedBox(height: 16.h),

                const Text(
                  'Cát Bracelet là thương hiệu vòng tay phong thuỷ hiện đại kết hợp tính ứng dụng cao và ý nghĩa tinh thần sâu sắc.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: taupe,
                    height: 1.5,
                  ),
                ),

                SizedBox(height: 20.h),

                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 18.w,
                  runSpacing: 12.h,
                  children: [
                    _buildSmallIcon(Icons.spa, 'TỰ NHIÊN'),
                    _buildSmallIcon(Icons.favorite_border, 'CHÂN THẬT'),
                    _buildSmallIcon(Icons.sync, 'CÂN BẰNG'),
                  ],
                ),
              ],
            );
          }

          return Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cát là gì?',
                      style: TextStyle(
                        fontSize: 26.sp,
                        fontFamily: 'serif',
                        fontWeight: FontWeight.bold,
                        color: wine,
                      ),
                    ),

                    SizedBox(height: 16.h),

                    Text(
                      'Cát Bracelet là thương hiệu vòng tay phong thuỷ hiện đại kết hợp tính ứng dụng cao và ý nghĩa tinh thần sâu sắc.',
                      style: TextStyle(
                        fontSize: 15.sp,
                        color: taupe,
                        height: 1.5,
                      ),
                    ),

                    SizedBox(height: 20.h),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildSmallIcon(Icons.spa, 'TỰ NHIÊN'),
                        _buildSmallIcon(Icons.favorite_border, 'CHÂN THẬT'),
                        _buildSmallIcon(Icons.sync, 'CÂN BẰNG'),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(width: 24.w),

              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100.r),
                  child: Image.asset(
                    'assets/images/vongtay.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Container(color: softRose, height: 200.h),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  static Widget _buildSmallIcon(
      IconData icon,
      String text,
      ) {
    return SizedBox(
      width: 90.w,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: gold,
            size: 24.sp,
          ),

          SizedBox(height: 4.h),

          Text(
            text,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10.sp,
              color:  wine,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return buildAboutSection();
  }
}