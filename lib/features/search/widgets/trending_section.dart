import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class TrendingSection extends StatelessWidget {
  final List<String> trends;
  final ValueChanged<String> onTap;

  const TrendingSection({
    super.key,
    required this.trends,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(
              Icons.trending_up,
              color: AppColors.primary,
            ),
            SizedBox(width: 12),
            Text(
              'Xu hướng',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...trends.map(
              (trend) => ListTile(
            contentPadding:
            const EdgeInsets.only(left: 24),
            title: Text(
              trend,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 18,
              ),
            ),
            onTap: () => onTap(trend),
          ),
        ),
      ],
    );
  }
}