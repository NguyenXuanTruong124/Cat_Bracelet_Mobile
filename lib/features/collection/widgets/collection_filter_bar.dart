import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Hộp trang trí dùng chung cho các ô nhập liệu trong bộ lọc.
InputDecoration filterInputDecoration({required String label, IconData? icon}) {
  return InputDecoration(
    labelText: label,
    prefixIcon: icon == null ? null : Icon(icon),
    isDense: true,
    filled: true,
    fillColor: AppColors.softRose,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: AppColors.gold.withValues(alpha: 0.35)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: AppColors.gold.withValues(alpha: 0.35)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.wine, width: 1.4),
    ),
  );
}

/// Thanh lọc sản phẩm hiển thị ngang, dùng cho màn hình rộng (không phải
/// compact). Trên màn hình nhỏ, dùng `showCollectionFilterSheet` thay thế.
class CollectionFilterBar extends StatelessWidget {
  final TextEditingController searchController;
  final String? selectedCategory;
  final String? selectedMaterial;
  final List<String> categories;
  final List<String> materials;
  final ValueChanged<String?> onCategoryChanged;
  final ValueChanged<String?> onMaterialChanged;
  final VoidCallback onSearch;
  final VoidCallback onApplyFilter;
  final VoidCallback onClearFilter;

  const CollectionFilterBar({
    super.key,
    required this.searchController,
    required this.selectedCategory,
    required this.selectedMaterial,
    required this.categories,
    required this.materials,
    required this.onCategoryChanged,
    required this.onMaterialChanged,
    required this.onSearch,
    required this.onApplyFilter,
    required this.onClearFilter,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      color: Colors.white,
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizedBox(
            width: 220,
            child: TextField(
              controller: searchController,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => onSearch(),
              decoration: filterInputDecoration(
                label: 'Tìm kiếm',
                icon: Icons.search,
              ),
            ),
          ),
          IconButton.filled(
            style: IconButton.styleFrom(backgroundColor: AppColors.wine),
            tooltip: 'Tìm kiếm',
            onPressed: onSearch,
            icon: const Icon(Icons.search, color: Colors.white),
          ),
          _FilterDropdown(
            value: selectedCategory,
            label: 'Danh mục',
            items: categories,
            onChanged: onCategoryChanged,
          ),
          _FilterDropdown(
            value: selectedMaterial,
            label: 'Chất liệu',
            items: materials,
            onChanged: onMaterialChanged,
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.wine,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: onApplyFilter,
            icon: const Icon(Icons.filter_alt),
            label: const Text('Lọc'),
          ),
          TextButton.icon(
            onPressed: onClearFilter,
            icon: const Icon(Icons.close),
            label: const Text('Xóa lọc'),
          ),
        ],
      ),
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  final String? value;
  final String label;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _FilterDropdown({
    required this.value,
    required this.label,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: DropdownButtonFormField<String>(
        initialValue: value,
        isExpanded: true,
        decoration: filterInputDecoration(label: label),
        items: items
            .map(
              (item) => DropdownMenuItem<String>(
            value: item,
            child: Text(item, overflow: TextOverflow.ellipsis),
          ),
        )
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}
