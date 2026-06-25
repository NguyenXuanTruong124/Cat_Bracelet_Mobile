import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Khung ảnh lớn hiển thị ở đầu màn hình chi tiết sản phẩm.
class ProductImageBanner extends StatelessWidget {
  final String imageUrl;

  const ProductImageBanner({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 340,
      decoration: BoxDecoration(
        color: AppColors.softRose,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.35)),
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl.isNotEmpty
          ? Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(
            Icons.image_not_supported,
            size: 54,
            color: Colors.grey,
          );
        },
      )
          : const Icon(Icons.image_not_supported, size: 54, color: Colors.grey),
    );
  }
}
