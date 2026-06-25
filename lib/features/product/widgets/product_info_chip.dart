import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Một chip nhỏ hiển thị thông tin phụ của sản phẩm, ví dụ danh mục hoặc
/// chất liệu.
class ProductInfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const ProductInfoChip({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 16, color: AppColors.wine),
      label: Text(label),
      backgroundColor: AppColors.softRose,
      side: BorderSide(color: AppColors.gold.withValues(alpha: 0.35)),
    );
  }
}

/// Danh sách chip hiển thị danh mục và các chất liệu của sản phẩm.
class ProductInfoChips extends StatelessWidget {
  final String? categoryName;
  final List<String> materialNames;

  const ProductInfoChips({
    super.key,
    required this.categoryName,
    required this.materialNames,
  });

  @override
  Widget build(BuildContext context) {
    if (categoryName == null && materialNames.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (categoryName != null)
          ProductInfoChip(icon: Icons.category, label: categoryName!),
        ...materialNames.map(
              (material) => ProductInfoChip(icon: Icons.diamond, label: material),
        ),
      ],
    );
  }
}
