import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../models/product_variants.dart';

/// Khu vực cho phép người dùng chọn biến thể sản phẩm (màu, kích thước...).
///
/// Hiển thị thông báo "không có biến thể" nếu [variants] rỗng.
class ProductVariantSelector extends StatelessWidget {
  final List<ProductVariants> variants;
  final ProductVariants? selectedVariant;
  final ValueChanged<ProductVariants> onVariantSelected;

  const ProductVariantSelector({
    super.key,
    required this.variants,
    required this.selectedVariant,
    required this.onVariantSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (variants.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.gold.withValues(alpha: 0.35)),
        ),
        child: const Text('Sản phẩm không có biến thể'),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Chọn biến thể:',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E2A28),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: variants
              .map(
                (variant) => _VariantChip(
              variant: variant,
              isSelected: variant.id == selectedVariant?.id,
              onSelected: () => onVariantSelected(variant),
            ),
          )
              .toList(),
        ),
        if (selectedVariant != null) ...[
          const SizedBox(height: 12),
          Text(
            'Tồn kho: ${selectedVariant!.stock}',
            style: const TextStyle(color: Color(0xFF6B5E56), fontSize: 13),
          ),
        ],
      ],
    );
  }
}

class _VariantChip extends StatelessWidget {
  final ProductVariants variant;
  final bool isSelected;
  final VoidCallback onSelected;

  const _VariantChip({
    required this.variant,
    required this.isSelected,
    required this.onSelected,
  });

  String get _label {
    final parts = [
      if ((variant.color ?? '').isNotEmpty) variant.color,
      if ((variant.size ?? '').isNotEmpty) variant.size,
    ];
    final joined = parts.join(' / ');
    return joined.isEmpty ? variant.sku : joined;
  }

  bool get _inStock => variant.stock > 0;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      selected: isSelected,
      label: Text(_label),
      avatar: _inStock ? null : const Icon(Icons.block, size: 16),
      selectedColor: AppColors.wine,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : const Color(0xFF2E2A28),
        fontWeight: FontWeight.w600,
      ),
      side: BorderSide(color: AppColors.gold.withValues(alpha: 0.5)),
      onSelected: _inStock ? (_) => onSelected() : null,
    );
  }
}
