import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeSections {
  static const Color wine = AppColors.wine;
  static const Color gold = AppColors.gold;
  static const Color cream = AppColors.cream;
  static const Color softRose = AppColors.softRose;
  static const Color taupe = AppColors.taupe;

  static Widget buildHeroSection() {
    return Container(
      width: double.infinity,
      color: cream,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
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
            style: TextStyle(
              fontSize: 16,
              color: taupe,
              height: 1.5,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 32),
          Image.asset(
            'assets/images/home_ne.png',
            height: 250,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => Container(
              height: 250,
              color: softRose,
              child: const Center(
                child: Icon(Icons.image, size: 50, color: wine),
              ),
            ),
          ),
          const SizedBox(height: 32),

        ],
      ),
    );
  }

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

  static Widget buildProblemSection() {
    return Container(
      color: cream,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Text(
            'Bạn có đang gặp những điều này?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontFamily: 'serif',
              fontWeight: FontWeight.bold,
              color: wine,
            ),
          ),
          const SizedBox(height: 24),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              'assets/images/about_2.png',
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  Container(height: 200, width: double.infinity, color: taupe),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Cát Bracelet được tạo ra để đồng hành cùng bạn, giúp cân bằng năng lượng, xua tan những điều tích tụ mệt mỏi.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: taupe, height: 1.5),
          ),
        ],
      ),
    );
  }

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
              color: wine,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  static Widget buildHowItWorksSection() {
    return Container(
      color: cream,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Text(
            'Vòng Cát hoạt động như thế nào?',
            style: TextStyle(
              fontSize: 24,
              fontFamily: 'serif',
              fontWeight: FontWeight.bold,
              color: wine,
            ),
          ),
          const SizedBox(height: 32),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildStepItem('01', 'THANH TẨY', 'assets/images/thanhtay.png'),
                _buildStepItem('02', 'KÍCH HOẠT', 'assets/images/hop.png'),
                _buildStepItem('03', 'CÂN BẰNG', 'assets/images/canbang.png'),
                _buildStepItem('04', 'ĐỒNG HÀNH', 'assets/images/vongtay.png'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildStepItem(String step, String title, String imgPath) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        children: [
          ClipOval(
            child: Image.asset(
              imgPath,
              height: 80,
              width: 80,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  Container(height: 80, width: 80, color: softRose),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            step,
            style: const TextStyle(
              color: gold,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              color: wine,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  static Widget buildSloganBanner() {
    return Container(
      width: double.infinity,
      color: wine,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      child: Column(
        children: [
          const Text(
            'be you, be energy',
            style: TextStyle(
              fontFamily: 'serif',
              fontSize: 32,
              fontStyle: FontStyle.italic,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'SỐNG ĐÚNG VỚI BẢN THÂN - LÀM CHỦ NĂNG LƯỢNG TÍCH CỰC',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: gold,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  static Widget buildTestimonialsSection() {
    return Container(
      color: cream,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Text(
            'Khách hàng nói gì về Cát',
            style: TextStyle(
              fontSize: 24,
              fontFamily: 'serif',
              fontWeight: FontWeight.bold,
              color: wine,
            ),
          ),
          const SizedBox(height: 24),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildTestimonialCard(
                  'Ngọc Anh',
                  '"Mình đeo vòng Cát An Nhiên và cảm thấy tĩnh tâm hẳn."',
                ),
                _buildTestimonialCard(
                  'Thu Trang',
                  '"Từ khi mang vòng, cảm giác năng lượng trong mình dồi dào hơn."',
                ),
                _buildTestimonialCard(
                  'Đình Khang',
                  '"Kiểu dáng rất đẹp và nam tính, không hề yểu điệu."',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildTestimonialCard(String name, String quote) {
    return Container(
      width: 250,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: gold,
                child: Text(
                  name[0],
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: wine,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            quote,
            style: const TextStyle(
              fontStyle: FontStyle.italic,
              color: taupe,
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              Icon(Icons.star, color: gold, size: 16),
              Icon(Icons.star, color: gold, size: 16),
              Icon(Icons.star, color: gold, size: 16),
              Icon(Icons.star, color: gold, size: 16),
              Icon(Icons.star, color: gold, size: 16),
            ],
          ),
        ],
      ),
    );
  }

  static Widget buildConsultationForm() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: cream,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: gold.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            const Text(
              'Tư vấn miễn phí',
              style: TextStyle(
                fontSize: 22,
                fontFamily: 'serif',
                fontWeight: FontWeight.bold,
                color: wine,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Chọn vòng hợp mệnh',
              style: TextStyle(fontSize: 16, color: taupe),
            ),
            const SizedBox(height: 24),
            TextField(
              decoration: InputDecoration(
                hintText: 'Họ và tên',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                hintText: 'Số điện thoại',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: wine,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text(
                'GỬI THÔNG TIN',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
}
