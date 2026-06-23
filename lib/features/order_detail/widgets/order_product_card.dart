import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class OrderProductCard extends StatelessWidget {
  final String productName;
  final String sku;
  final String color;
  final String size;
  final String thumbnail;
  final String unitPrice;
  final int quantity;
  final String totalPrice;

  const OrderProductCard({
    super.key,
    required this.productName,
    required this.sku,
    required this.color,
    required this.size,
    required this.thumbnail,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              color: AppColors.primary,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  productName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  'Màu: $color',
                  style: const TextStyle(
                    fontSize: 13,
                    color:
                    AppColors.onSurfaceVariant,
                  ),
                ),

                Text(
                  'Size: $size',
                  style: const TextStyle(
                    fontSize: 13,
                    color:
                    AppColors.onSurfaceVariant,
                  ),
                ),

                Text(
                  'Số lượng: $quantity',
                  style: const TextStyle(
                    fontSize: 13,
                    color:
                    AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          Text(
            totalPrice,
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}