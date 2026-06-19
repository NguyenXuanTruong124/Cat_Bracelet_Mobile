import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class MemberCard extends StatelessWidget {
  const MemberCard({super.key});
  static const _wine = AppColors.wine;
  static const _gold = AppColors.gold;
  static const _softRose = AppColors.softRose;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;
    return Container(
      color: _wine,
      padding: EdgeInsets.fromLTRB(
        isMobile ? 16 : 32,
        0,
        isMobile ? 16 : 32,
        24,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFAEF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _gold.withValues(alpha: 0.6)),
            ),
            child: Row(
              children: [
                Container(
                  width: 62,
                  height: 62,
                  decoration: BoxDecoration(
                    color: _softRose,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.diamond, color: _wine),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Điểm thành viên hiện tại',
                        style: TextStyle(
                          color: _wine,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Kiểm tra VIP và ưu đãi riêng của bạn',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, '/profile'),
                  child: const Text('Xem'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}