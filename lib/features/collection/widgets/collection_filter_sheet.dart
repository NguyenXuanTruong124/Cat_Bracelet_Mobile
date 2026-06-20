import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import 'collection_filter_bar.dart' show filterInputDecoration;

/// Dữ liệu hiện tại của bộ lọc, dùng để khởi tạo bottom sheet.
class CollectionFilterState {
  final String? selectedCategory;
  final String? selectedMaterial;

  const CollectionFilterState({this.selectedCategory, this.selectedMaterial});
}

/// Kết quả người dùng chọn sau khi đóng bottom sheet lọc.
class CollectionFilterResult {
  final String? selectedCategory;
  final String? selectedMaterial;
  final String minPrice;
  final String maxPrice;

  const CollectionFilterResult({
    required this.selectedCategory,
    required this.selectedMaterial,
    required this.minPrice,
    required this.maxPrice,
  });
}

/// Hiển thị bottom sheet lọc sản phẩm cho màn hình nhỏ.
///
/// Trả về [CollectionFilterResult] khi người dùng bấm "Lọc", hoặc `null`
/// khi người dùng bấm "Xóa lọc" hoặc đóng sheet mà không chọn gì.
Future<void> showCollectionFilterSheet({
  required BuildContext context,
  required TextEditingController searchController,
  required TextEditingController minPriceController,
  required TextEditingController maxPriceController,
  required CollectionFilterState initialState,
  required List<String> categories,
  required List<String> materials,
  required VoidCallback onSearch,
  required void Function(CollectionFilterResult result) onApplyFilter,
  required VoidCallback onClearFilter,
}) {
  String? selectedCategory = initialState.selectedCategory;
  String? selectedMaterial = initialState.selectedMaterial;

  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              16,
              16,
              MediaQuery.of(context).viewInsets.bottom + 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.gold,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: searchController,
                  decoration: filterInputDecoration(label: '', icon: Icons.search),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      onSearch();
                    },
                    icon: const Icon(Icons.search),
                    label: const Text('Tìm kiếm'),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedCategory,
                  isExpanded: true,
                  decoration: filterInputDecoration(label: 'Danh mục'),
                  items: categories
                      .map(
                        (item) => DropdownMenuItem<String>(
                      value: item,
                      child: Text(item),
                    ),
                  )
                      .toList(),
                  onChanged: (value) {
                    setModalState(() => selectedCategory = value);
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedMaterial,
                  isExpanded: true,
                  decoration: filterInputDecoration(label: 'Chất liệu'),
                  items: materials
                      .map(
                        (item) => DropdownMenuItem<String>(
                      value: item,
                      child: Text(item),
                    ),
                  )
                      .toList(),
                  onChanged: (value) {
                    setModalState(() => selectedMaterial = value);
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: minPriceController,
                        keyboardType: TextInputType.number,
                        decoration: filterInputDecoration(label: 'Giá từ'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: maxPriceController,
                        keyboardType: TextInputType.number,
                        decoration: filterInputDecoration(label: 'Đến'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          onClearFilter();
                        },
                        icon: const Icon(Icons.close),
                        label: const Text('Xóa lọc'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.wine,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          onApplyFilter(
                            CollectionFilterResult(
                              selectedCategory: selectedCategory,
                              selectedMaterial: selectedMaterial,
                              minPrice: minPriceController.text.trim(),
                              maxPrice: maxPriceController.text.trim(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.filter_alt),
                        label: const Text('Lọc'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
