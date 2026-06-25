import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class TestimonialsSection extends StatelessWidget {
  const TestimonialsSection({super.key});
  static const Color wine = AppColors.wine;
  static const Color gold = AppColors.gold;
  static const Color cream = AppColors.cream;
  static const Color softRose = AppColors.softRose;
  static const Color taupe = AppColors.taupe;

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

  @override
  Widget build(BuildContext context) {
    return buildTestimonialsSection();
  }
}