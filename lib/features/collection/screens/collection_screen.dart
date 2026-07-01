import 'package:flutter/material.dart';

import '../../../config/api_config.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/api_helpers.dart';
import '../../../core/theme/app_colors.dart';
import '../../cart/widgets/cart_icon_badge.dart';
import '../../home/screens/home_screen.dart';
import '../models/filter_options.dart';
import 'package:cat_bracelet_mobile/features/product/models/product.dart';
import '../services/product_catalog_service.dart';
import '../widgets/collection_filter_bar.dart';
import '../widgets/collection_filter_sheet.dart';
import '../widgets/product_grid_card.dart';
import 'package:cat_bracelet_mobile/features/product/screens/product_details_screen.dart';

/// Màn hình hiển thị danh sách sản phẩm (bộ sưu tập) kèm tìm kiếm và lọc.
class CollectionScreen extends StatefulWidget {
  final String? initialSearch;

  const CollectionScreen({super.key, this.initialSearch});

  @override
  State<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends State<CollectionScreen> {
  static const ProductCatalogService _catalogService = ProductCatalogService();

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();

  FilterOptions _filterOptions = FilterOptions.empty();
  List<Product> _products = [];

  bool _isLoading = true;
  String _errorMessage = '';
  String? _selectedCategory;
  String? _selectedMaterial;

  @override
  void initState() {
    super.initState();
    if ((widget.initialSearch ?? '').trim().isNotEmpty) {
      _searchController.text = widget.initialSearch!.trim();
    }
    _loadFilterOptions();
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts({bool useFilter = false}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final baseUrl = ApiConfig.getBaseUrl(context);
      final products = await _catalogService.fetchProducts(
        baseUrl: baseUrl,
        searchName: _searchController.text.trim(),
        useFilter: useFilter,
        filterParams: _buildFilterParams(),
      );

      if (!mounted) return;

      setState(() {
        _products = _catalogService.applyClientFilters(
          products,
          categoryNamesById: _filterOptions.categoryNamesById,
          selectedCategory: _selectedCategory,
          selectedMaterial: _selectedMaterial,
        );
        _isLoading = false;
      });
    } on ProductCatalogException catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.message;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Không thể kết nối đến máy chủ.';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadFilterOptions() async {
    try {
      final baseUrl = ApiConfig.getBaseUrl(context);
      final options = await _catalogService.fetchFilterOptions(
        baseUrl: baseUrl,
      );

      if (!mounted) return;
      setState(() => _filterOptions = options);
    } catch (_) {
      // Tuỳ chọn lọc chỉ mang tính hỗ trợ, trang vẫn hoạt động nếu lỗi.
    }
  }

  /// Gom các tham số lọc đang có giá trị thành query params cho API.
  Map<String, String> _buildFilterParams() {
    final params = <String, String>{};
    final minPrice = _minPriceController.text.trim();
    final maxPrice = _maxPriceController.text.trim();

    if (minPrice.isNotEmpty) params['minPrice'] = minPrice;
    if (maxPrice.isNotEmpty) params['maxPrice'] = maxPrice;

    return params;
  }

  String _imageUrlOf(Product product) {
    return buildImageUrl(ApiConfig.getBaseUrl(context), product.firstImage);
  }

  void _clearFilters() {
    _searchController.clear();
    _minPriceController.clear();
    _maxPriceController.clear();
    setState(() {
      _selectedCategory = null;
      _selectedMaterial = null;
    });
    _loadProducts();
  }

  void _openDetails(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailsScreen(product: product),
      ),
    );
  }

  void _goHome() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
      (route) => false,
    );
  }

  void _openFilterSheet() {
    showCollectionFilterSheet(
      context: context,
      searchController: _searchController,
      minPriceController: _minPriceController,
      maxPriceController: _maxPriceController,
      initialState: CollectionFilterState(
        selectedCategory: _selectedCategory,
        selectedMaterial: _selectedMaterial,
      ),
      categories: _filterOptions.categories,
      materials: _filterOptions.materials,
      onSearch: () => _loadProducts(useFilter: true),
      onClearFilter: _clearFilters,
      onApplyFilter: (result) {
        setState(() {
          _selectedCategory = result.selectedCategory;
          _selectedMaterial = result.selectedMaterial;
        });
        _loadProducts(useFilter: true);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 700;

    return Scaffold(
      appBar: _buildAppBar(isCompact: isCompact),
      body: Column(
        children: [
          if (!isCompact) _buildFilterBar(),
          Expanded(child: _buildBody(screenWidth: screenWidth)),
        ],
      ),
    );
  }

  double _gridMaxCrossAxisExtent(double screenWidth) {
    if (screenWidth >= 1600) return 300;
    if (screenWidth >= 1200) return 260;
    if (screenWidth >= 1000) return 240;
    if (screenWidth >= 800) return 220;
    return 180;
  }

  double _childAspectRatioFor(double screenWidth) {
    if (screenWidth >= 1200) return 0.78;
    if (screenWidth >= 1000) return 0.74;
    if (screenWidth >= 800) return 0.7;
    return 0.62;
  }

  PreferredSizeWidget _buildAppBar({required bool isCompact}) {
    return AppBar(
      title: const Text(
        'Bộ sưu tập',
        style: TextStyle(fontFamily: 'serif', fontWeight: FontWeight.bold),
      ),
      backgroundColor: AppColors.wine,
      foregroundColor: Colors.white,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        tooltip: 'Quay lại',
        onPressed: _goHome,
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          tooltip: 'Tìm kiếm',
          onPressed: () => Navigator.pushNamed(context, AppRoutes.search),
        ),
        if (isCompact)
          IconButton(
            icon: const Icon(Icons.tune),
            tooltip: 'Lọc sản phẩm',
            onPressed: _openFilterSheet,
          ),
        const CartIconBadge(),
      ],
    );
  }

  Widget _buildFilterBar() {
    return CollectionFilterBar(
      searchController: _searchController,
      selectedCategory: _selectedCategory,
      selectedMaterial: _selectedMaterial,
      categories: _filterOptions.categories,
      materials: _filterOptions.materials,
      onCategoryChanged: (value) => setState(() => _selectedCategory = value),
      onMaterialChanged: (value) => setState(() => _selectedMaterial = value),
      onSearch: () => _loadProducts(useFilter: true),
      onApplyFilter: () => _loadProducts(useFilter: true),
      onClearFilter: _clearFilters,
    );
  }

  Widget _buildBody({required double screenWidth}) {
    final spacing = 16.0;
    final maxCrossAxisExtent = _gridMaxCrossAxisExtent(screenWidth);
    final childAspectRatio = _childAspectRatioFor(screenWidth);

    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.wine),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Text(_errorMessage, style: const TextStyle(color: Colors.red)),
      );
    }

    if (_products.isEmpty) {
      return const Center(child: Text('Không có sản phẩm phù hợp'));
    }

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: screenWidth >= 1400 ? 1400 : screenWidth,
        ),
        child: GridView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _products.length,
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: maxCrossAxisExtent,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            childAspectRatio: childAspectRatio,
          ),
          itemBuilder: (context, index) {
            final product = _products[index];
            return ProductGridCard(
              product: product,
              imageUrl: _imageUrlOf(product),
              onTap: () => _openDetails(product),
            );
          },
        ),
      ),
    );
  }
}
