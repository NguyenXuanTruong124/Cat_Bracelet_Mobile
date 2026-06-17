import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../../../core/config/api_config.dart';
import '../../../core/theme/app_colors.dart';
import '../models/product.dart';
import '../models/product_variants.dart';
import '../../../core/services/api_helpers.dart';
import '../../home/screens/home_screen.dart';
import 'product_details_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CollectionScreen extends StatefulWidget {
  final String? initialSearch;

  const CollectionScreen({super.key, this.initialSearch});

  @override
  State<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends State<CollectionScreen> {
  static const Color _wine = AppColors.wine;
  static const Color _gold = AppColors.gold;
  static const Color _softRose = AppColors.softRose;

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();
  final TextEditingController _stoneColorController = TextEditingController();
  final TextEditingController _stoneTypeController = TextEditingController();
  final Map<String, String> _categoryNamesById = {};

  List<Product> _products = [];
  List<String> _colors = [];
  List<String> _sizes = [];
  List<String> _stoneColors = [];
  List<String> _stoneTypes = [];
  List<String> _categories = [];
  List<String> _materials = [];

  bool _isLoading = true;
  String _errorMessage = '';
  String? _selectedSize;
  String? _selectedCategory;
  String? _selectedMaterial;

  @override
  void initState() {
    super.initState();
    if ((widget.initialSearch ?? '').trim().isNotEmpty) {
      _searchController.text = widget.initialSearch!.trim();
    }
    _fetchFilterOptions();
    _fetchProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    _colorController.dispose();
    _stoneColorController.dispose();
    _stoneTypeController.dispose();
    super.dispose();
  }

  Future<void> _fetchProducts({bool useFilter = false}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final baseUrl = ApiConfig.getBaseUrl(context);
      final searchName = _searchController.text.trim();
      final hasSearch = searchName.isNotEmpty;
      final hasFilter =
          _selectedSize != null ||
          _colorController.text.trim().isNotEmpty ||
          _stoneColorController.text.trim().isNotEmpty ||
          _stoneTypeController.text.trim().isNotEmpty ||
          _selectedCategory != null ||
          _selectedMaterial != null ||
          _minPriceController.text.trim().isNotEmpty ||
          _maxPriceController.text.trim().isNotEmpty;

      late final Uri url;
      if (hasSearch) {
        url = Uri.parse(
          '$baseUrl/products/by-name/${Uri.encodeComponent(searchName)}',
        );
      } else if (useFilter && hasFilter) {
        url = Uri.parse(
          '$baseUrl/products/filter',
        ).replace(queryParameters: _filterQueryParameters());
      } else {
        url = Uri.parse('$baseUrl/products');
      }

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final products = _decodeList(response.body)
            .whereType<Map<String, dynamic>>()
            .map(Product.fromJson)
            .where((product) => product.status.toLowerCase() == 'active')
            .toList();

        if (!mounted) {
          return;
        }

        setState(() {
          _products = _applyClientFilters(products);
          _isLoading = false;
        });
      } else {
        if (!mounted) {
          return;
        }

        setState(() {
          _errorMessage = 'Lỗi tải dữ liệu: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage = 'Không thể kết nối đến máy chủ.';
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchFilterOptions() async {
    try {
      final baseUrl = ApiConfig.getBaseUrl(context);
      final responses = await Future.wait([
        http.get(Uri.parse('$baseUrl/product-variants')),
        http.get(Uri.parse('$baseUrl/categories')),
        http.get(Uri.parse('$baseUrl/materials')),
      ]);

      final variants = responses[0].statusCode == 200
          ? _decodeList(responses[0].body)
                .whereType<Map<String, dynamic>>()
                .map(ProductVariants.fromJson)
                .where((variant) => variant.status.toLowerCase() == 'active')
                .toList()
          : <ProductVariants>[];

      final colors =
          variants
              .map((variant) => variant.color?.trim())
              .whereType<String>()
              .where((value) => value.isNotEmpty)
              .toSet()
              .toList()
            ..sort();
      final sizes =
          variants
              .map((variant) => variant.size?.trim())
              .whereType<String>()
              .where((value) => value.isNotEmpty)
              .toSet()
              .toList()
            ..sort();
      final categoryItems = responses[1].statusCode == 200
          ? _decodeList(responses[1].body)
                .whereType<Map<String, dynamic>>()
                .where(
                  (item) =>
                      (item['status'] ?? '').toString().toLowerCase() ==
                      'active',
                )
                .toList()
          : <Map<String, dynamic>>[];

      for (final item in categoryItems) {
        final id = item['id']?.toString();
        final name = (item['categoryName'] ?? item['category_name'])
            ?.toString()
            .trim();

        if (id != null && name != null && name.isNotEmpty) {
          _categoryNamesById[id] = name;
        }
      }

      final categories = categoryItems
          .map((item) => item['categoryName'] ?? item['category_name'])
          .whereType<Object>()
          .map((item) => item.toString().trim())
          .where((value) => value.isNotEmpty)
          .toSet()
          .toList();
      final materials = responses[2].statusCode == 200
          ? _decodeList(responses[2].body)
                .whereType<Map<String, dynamic>>()
                .where(
                  (item) =>
                      (item['status'] ?? '').toString().toLowerCase() ==
                      'active',
                )
                .map((item) => item['materialName'] ?? item['material_name'])
                .whereType<Object>()
                .map((item) => item.toString().trim())
                .where((value) => value.isNotEmpty)
                .toSet()
                .toList()
          : <String>[];
      final stoneColors = responses[2].statusCode == 200
          ? _decodeList(responses[2].body)
                .whereType<Map<String, dynamic>>()
                .map((item) => item['color'])
                .whereType<Object>()
                .map((item) => item.toString().trim())
                .where((value) => value.isNotEmpty)
                .toSet()
                .toList()
          : <String>[];
      final stoneTypes = responses[2].statusCode == 200
          ? _decodeList(responses[2].body)
                .whereType<Map<String, dynamic>>()
                .map((item) => item['materialType'] ?? item['material_type'])
                .whereType<Object>()
                .map((item) => item.toString().trim())
                .where((value) => value.isNotEmpty)
                .toSet()
                .toList()
          : <String>[];

      categories.sort();
      materials.sort();
      stoneColors.sort();
      stoneTypes.sort();

      if (!mounted) {
        return;
      }

      setState(() {
        _colors = colors;
        _sizes = sizes;
        _categories = categories;
        _materials = materials;
        _stoneColors = stoneColors;
        _stoneTypes = stoneTypes;
      });
    } catch (_) {
      // Filter options are helpful, but the page can still work without them.
    }
  }

  List<dynamic> _decodeList(String body) {
    return decodeListPayload(jsonDecode(body));
  }

  Map<String, String> _filterQueryParameters() {
    final parameters = <String, String>{};
    final minPrice = _minPriceController.text.trim();
    final maxPrice = _maxPriceController.text.trim();

    final color = _colorController.text.trim();
    final stoneColor = _stoneColorController.text.trim();
    final stoneType = _stoneTypeController.text.trim();

    if (color.isNotEmpty) {
      parameters['color'] = color;
    }
    if (_selectedSize != null) {
      parameters['size'] = _selectedSize!;
    }
    if (stoneColor.isNotEmpty) {
      parameters['stoneColor'] = stoneColor;
    }
    if (stoneType.isNotEmpty) {
      parameters['stoneType'] = stoneType;
    }
    if (minPrice.isNotEmpty) {
      parameters['minPrice'] = minPrice;
    }
    if (maxPrice.isNotEmpty) {
      parameters['maxPrice'] = maxPrice;
    }

    return parameters;
  }

  List<Product> _applyClientFilters(List<Product> products) {
    return products.where((product) {
      final categoryMatched =
          _selectedCategory == null ||
              _categoryNamesById[product.categoryId] ==
                  _selectedCategory;

      final materialMatched =
          _selectedMaterial == null ||
              product.materialNames.any(
                    (name) =>
                name.toLowerCase() ==
                    _selectedMaterial!.toLowerCase(),
              );

      return categoryMatched && materialMatched;
    }).toList();
  }

  String _formatPrice(int price) {
    final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: 'd');
    return formatCurrency.format(price);
  }

  String _getImageUrl(String? thumbnail) {
    return buildImageUrl(ApiConfig.getBaseUrl(context), thumbnail);
  }

  void _clearFilters() {
    _searchController.clear();
    _minPriceController.clear();
    _maxPriceController.clear();
    _colorController.clear();
    _stoneColorController.clear();
    _stoneTypeController.clear();
    setState(() {
      _selectedSize = null;
      _selectedCategory = null;
      _selectedMaterial = null;
    });
    _fetchProducts();
  }

  void _openDetails(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailsScreen(product: product),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 700;

    int crossAxisCount = 2;
    if (screenWidth >= 1200) {
      crossAxisCount = 5;
    } else if (screenWidth >= 900) {
      crossAxisCount = 4;
    } else if (screenWidth >= 600) {
      crossAxisCount = 3;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Bộ sưu tập',
          style: TextStyle(fontFamily: 'serif', fontWeight: FontWeight.bold),
        ),
        backgroundColor: _wine,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Quay lại',
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
              (route) => false,
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Tìm kiếm',
            onPressed: () => Navigator.pushNamed(context, '/search'),
          ),
          if (isCompact)
            IconButton(
              icon: const Icon(Icons.tune),
              tooltip: 'Lọc sản phẩm',
              onPressed: _showFilterSheet,
            ),
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            tooltip: 'Giỏ hàng',
            onPressed: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Đi về giỏ hàng')));
              Navigator.pushNamed(context, '/cart');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (!isCompact) _buildFilterBar(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: _wine))
                : _errorMessage.isNotEmpty
                ? Center(
                    child: Text(
                      _errorMessage,
                      style: const TextStyle(color: Colors.red),
                    ),
                  )
                : _products.isEmpty
                ? const Center(child: Text('Không có sản phẩm phù hợp'))
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _products.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: screenWidth < 600 ? 0.55 : 0.75,
                    ),
                    itemBuilder: (context, index) {
                      return _buildProductCard(_products[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
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
              controller: _searchController,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _fetchProducts(useFilter: true),
              decoration: _inputDecoration(
                label: 'Tìm kiếm',
                icon: Icons.search,
              ),
            ),
          ),
          IconButton.filled(
            style: IconButton.styleFrom(backgroundColor: _wine),
            tooltip: 'Tim kiem',
            onPressed: () => _fetchProducts(useFilter: true),
            icon: const Icon(Icons.search, color: Colors.white),
          ),
          // _buildFilterTextField(
          //   controller: _colorController,
          //   label: 'Mau',
          //   suggestions: _colors,
          // ),
          // _buildFilterTextField(
          //   controller: _stoneColorController,
          //   label: 'Mau da',
          //   suggestions: _stoneColors,
          // ),
          // _buildFilterTextField(
          //   controller: _stoneTypeController,
          //   label: 'Loai da',
          //   suggestions: _stoneTypes,
          // ),
          // _buildDropdown(
          //   value: _selectedSize,
          //   label: 'Size',
          //   items: _sizes,
          //   onChanged: (value) {
          //     setState(() {
          //       _selectedSize = value;
          //     });
          //   },
          // ),
          _buildDropdown(
            value: _selectedCategory,
            label: 'Danh mục',
            items: _categories,
            onChanged: (value) {
              setState(() {
                _selectedCategory = value;
              });
            },
          ),
          _buildDropdown(
            value: _selectedMaterial,
            label: 'Chất liệu',
            items: _materials,
            onChanged: (value) {
              setState(() {
                _selectedMaterial = value;
              });
            },
          ),
          // SizedBox(
          //   width: 140,
          //   child: TextField(
          //     controller: _minPriceController,
          //     keyboardType: TextInputType.number,
          //     decoration: _inputDecoration(label: 'Gia tu'),
          //   ),
          // ),
          // SizedBox(
          //   width: 140,
          //   child: TextField(
          //     controller: _maxPriceController,
          //     keyboardType: TextInputType.number,
          //     decoration: _inputDecoration(label: 'Gia den'),
          //   ),
          // ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: _wine,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => _fetchProducts(useFilter: true),
            icon: const Icon(Icons.filter_alt),
            label: const Text('Lọc'),
          ),
          TextButton.icon(
            onPressed: _clearFilters,
            icon: const Icon(Icons.close),
            label: const Text('Xóa lọc'),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({required String label, IconData? icon}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: icon == null ? null : Icon(icon),
      isDense: true,
      filled: true,
      fillColor: _softRose,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: _gold.withValues(alpha: 0.35)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: _gold.withValues(alpha: 0.35)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: _wine, width: 1.4),
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required String label,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return SizedBox(
      width: 150,
      child: DropdownButtonFormField<String>(
        initialValue: value,
        isExpanded: true,
        decoration: _inputDecoration(label: label),
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

  Widget _buildFilterTextField({
    required TextEditingController controller,
    required String label,
    required List<String> suggestions,
  }) {
    return SizedBox(
      width: 160,
      child: TextField(
        controller: controller,
        decoration: _inputDecoration(label: label).copyWith(
          suffixIcon: PopupMenuButton<String>(
            tooltip: 'Chọn $label',
            icon: const Icon(Icons.arrow_drop_down),
            onSelected: (value) {
              setState(() {
                controller.text = value == '__none__' ? '' : value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: '__none__', child: Text('No filter')),
              ...suggestions.map(
                (item) => PopupMenuItem(value: item, child: Text(item)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
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
                      color: _gold,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _searchController,
                    decoration: _inputDecoration(
                      label: '',
                      icon: Icons.search,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _fetchProducts(useFilter: true);
                      },
                      icon: const Icon(Icons.search),
                      label: const Text('Tìm kiếm'),
                    ),
                  ),
                  // const SizedBox(height: 12),
                  // _buildSheetFilterTextField(
                  //   controller: _colorController,
                  //   label: 'Màu',
                  //   suggestions: _colors,
                  //   setModalState: setModalState,
                  // ),
                  // const SizedBox(height: 12),
                  // _buildSheetFilterTextField(
                  //   controller: _stoneColorController,
                  //   label: 'Màu đá',
                  //   suggestions: _stoneColors,
                  //   setModalState: setModalState,
                  // ),
                  // const SizedBox(height: 12),
                  // _buildSheetFilterTextField(
                  //   controller: _stoneTypeController,
                  //   label: 'Loại đá',
                  //   suggestions: _stoneTypes,
                  //   setModalState: setModalState,
                  // ),
                  // const SizedBox(height: 12),
                  // _buildSheetDropdown(
                  //   value: _selectedSize,
                  //   label: 'Size',
                  //   items: _sizes,
                  //   onChanged: (value) {
                  //     setModalState(() => _selectedSize = value);
                  //     setState(() => _selectedSize = value);
                  //   },
                  // ),
                  const SizedBox(height: 12),
                  _buildSheetDropdown(
                    value: _selectedCategory,
                    label: 'Danh mục',
                    items: _categories,
                    onChanged: (value) {
                      setModalState(() => _selectedCategory = value);
                      setState(() => _selectedCategory = value);
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildSheetDropdown(
                    value: _selectedMaterial,
                    label: 'Chất liệu',
                    items: _materials,
                    onChanged: (value) {
                      setModalState(() => _selectedMaterial = value);
                      setState(() => _selectedMaterial = value);
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _minPriceController,
                          keyboardType: TextInputType.number,
                          decoration: _inputDecoration(label: 'Giá từ'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _maxPriceController,
                          keyboardType: TextInputType.number,
                          decoration: _inputDecoration(label: 'Đến'),
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
                            _clearFilters();
                          },
                          icon: const Icon(Icons.close),
                          label: const Text('Xóa lọc'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _wine,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            _fetchProducts(useFilter: true);
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

  Widget _buildSheetDropdown({
    required String? value,
    required String label,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      decoration: _inputDecoration(label: label),
      items: items
          .map(
            (item) => DropdownMenuItem<String>(value: item, child: Text(item)),
          )
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildSheetFilterTextField({
    required TextEditingController controller,
    required String label,
    required List<String> suggestions,
    required StateSetter setModalState,
  }) {
    return TextField(
      controller: controller,
      decoration: _inputDecoration(label: label).copyWith(
        suffixIcon: PopupMenuButton<String>(
          tooltip: 'Chọn $label',
          icon: const Icon(Icons.arrow_drop_down),
          onSelected: (value) {
            setModalState(() {
              controller.text = value == '__none__' ? '' : value;
            });
            setState(() {});
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: '__none__', child: Text('No filter')),
            ...suggestions.map(
              (item) => PopupMenuItem(value: item, child: Text(item)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    final imageUrl = _getImageUrl(product.thumbnail);

    return InkWell(
      borderRadius: BorderRadius.circular(12.r),
      onTap: () => _openDetails(product),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: _gold.withValues(alpha: 0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10.r,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 7,
              child: Container(
                color: _softRose,
                child: imageUrl.isNotEmpty
                    ? Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  loadingBuilder:
                      (context, child, loadingProgress) {
                    if (loadingProgress == null) {
                      return child;
                    }

                    return const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    );
                  },
                  errorBuilder:
                      (context, error, stackTrace) {
                    return Icon(
                      Icons.image_not_supported,
                      color: Colors.grey,
                      size: 40.sp,
                    );
                  },
                )
                    : Icon(
                  Icons.image_not_supported,
                  color: Colors.grey,
                  size: 40.sp,
                ),
              ),
            ),

            Expanded(
              flex: 4,
              child: Padding(
                padding: EdgeInsets.all(10.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.productName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF333333),
                        height: 1.3,
                      ),
                    ),

                    SizedBox(height: 4.h),

                    Text(
                      _formatPrice(product.basePrice),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w800,
                        color: _wine,
                      ),
                    ),

                    const Spacer(),

                    SizedBox(
                      width: double.infinity,
                      height: 34.h,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _wine,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: 4.w,
                            vertical: 4.h,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(8.r),
                          ),
                        ),
                        onPressed: () => _openDetails(product),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.visibility,
                                size: 14.sp,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                'Chi tiết',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
