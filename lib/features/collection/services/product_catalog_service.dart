import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:cat_bracelet_mobile/core/services/api_helpers.dart';
import 'package:cat_bracelet_mobile/features/collection/models/filter_options.dart';
import 'package:cat_bracelet_mobile/features/product/models/product.dart';
import 'package:cat_bracelet_mobile/features/product/models/product_variants.dart';

/// Chịu trách nhiệm gọi API liên quan tới sản phẩm và các tuỳ chọn lọc.
///
/// Toàn bộ logic gọi mạng, decode JSON và lọc dữ liệu cơ bản được đặt ở đây
/// thay vì nằm trực tiếp trong widget, giúp `CollectionScreen` chỉ còn
/// nhiệm vụ hiển thị.
class ProductCatalogService {
  const ProductCatalogService();

  /// Lấy danh sách sản phẩm đang active theo từ khoá tìm kiếm hoặc bộ lọc.
  Future<List<Product>> fetchProducts({
    required String baseUrl,
    String searchName = '',
    bool useFilter = false,
    Map<String, String> filterParams = const {},
  }) async {
    final hasSearch = searchName.trim().isNotEmpty;
    final hasFilter = filterParams.isNotEmpty;

    late final Uri url;
    if (hasSearch) {
      url = Uri.parse(
        '$baseUrl/products/by-name/${Uri.encodeComponent(searchName.trim())}',
      );
    } else if (useFilter && hasFilter) {
      url = Uri.parse('$baseUrl/products/filter').replace(
        queryParameters: filterParams,
      );
    } else {
      url = Uri.parse('$baseUrl/products');
    }

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw ProductCatalogException(
        'Lỗi tải dữ liệu: ${response.statusCode}',
      );
    }

    return _decodeList(response.body)
        .whereType<Map<String, dynamic>>()
        .map(Product.fromJson)
        .where((product) => product.status.toLowerCase() == 'active')
        .toList();
  }

  /// Lấy toàn bộ dữ liệu cần thiết cho các bộ lọc: màu, size, danh mục,
  /// chất liệu, màu đá, loại đá.
  Future<FilterOptions> fetchFilterOptions({required String baseUrl}) async {
    final responses = await Future.wait([
      http.get(Uri.parse('$baseUrl/product-variants')),
      http.get(Uri.parse('$baseUrl/categories')),
      http.get(Uri.parse('$baseUrl/materials')),
    ]);

    final variantsResponse = responses[0];
    final categoriesResponse = responses[1];
    final materialsResponse = responses[2];

    final variants = variantsResponse.statusCode == 200
        ? _decodeList(variantsResponse.body)
        .whereType<Map<String, dynamic>>()
        .map(ProductVariants.fromJson)
        .where((variant) => variant.status.toLowerCase() == 'active')
        .toList()
        : <ProductVariants>[];

    final colors = _uniqueSorted(
      variants.map((variant) => variant.color),
    );
    final sizes = _uniqueSorted(
      variants.map((variant) => variant.size),
    );

    final categoryItems = categoriesResponse.statusCode == 200
        ? _decodeList(categoriesResponse.body)
        .whereType<Map<String, dynamic>>()
        .where((item) => _isActive(item))
        .toList()
        : <Map<String, dynamic>>[];

    final categoryNamesById = <String, String>{};
    for (final item in categoryItems) {
      final id = item['id']?.toString();
      final name = (item['categoryName'] ?? item['category_name'])
          ?.toString()
          .trim();

      if (id != null && name != null && name.isNotEmpty) {
        categoryNamesById[id] = name;
      }
    }

    final categories = _uniqueSorted(
      categoryItems.map(
            (item) => (item['categoryName'] ?? item['category_name'])
            ?.toString(),
      ),
    );

    final materialItems = materialsResponse.statusCode == 200
        ? _decodeList(materialsResponse.body).whereType<Map<String, dynamic>>()
        : const Iterable<Map<String, dynamic>>.empty();

    final materials = _uniqueSorted(
      materialItems
          .where((item) => _isActive(item))
          .map((item) => (item['materialName'] ?? item['material_name'])?.toString()),
    );
    final stoneColors = _uniqueSorted(
      materialItems.map((item) => item['color']?.toString()),
    );
    final stoneTypes = _uniqueSorted(
      materialItems.map(
            (item) => (item['materialType'] ?? item['material_type'])?.toString(),
      ),
    );

    return FilterOptions(
      colors: colors,
      sizes: sizes,
      stoneColors: stoneColors,
      stoneTypes: stoneTypes,
      categories: categories,
      materials: materials,
      categoryNamesById: categoryNamesById,
    );
  }

  /// Lọc thêm ở phía client theo danh mục/chất liệu đã chọn, áp dụng sau khi
  /// đã có kết quả từ API.
  List<Product> applyClientFilters(
      List<Product> products, {
        required Map<String, String> categoryNamesById,
        String? selectedCategory,
        String? selectedMaterial,
      }) {
    return products.where((product) {
      final categoryMatched = selectedCategory == null ||
          categoryNamesById[product.categoryId] == selectedCategory;

      final materialMatched = selectedMaterial == null ||
          product.materialNames.any(
                (name) => name.toLowerCase() == selectedMaterial.toLowerCase(),
          );

      return categoryMatched && materialMatched;
    }).toList();
  }

  bool _isActive(Map<String, dynamic> item) {
    return (item['status'] ?? '').toString().toLowerCase() == 'active';
  }

  List<String> _uniqueSorted(Iterable<String?> values) {
    final result = values
        .whereType<String>()
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toSet()
        .toList();
    result.sort();
    return result;
  }

  List<dynamic> _decodeList(String body) {
    return decodeListPayload(jsonDecode(body));
  }
}

/// Lỗi xảy ra khi gọi API danh sách sản phẩm thất bại.
class ProductCatalogException implements Exception {
  final String message;

  const ProductCatalogException(this.message);

  @override
  String toString() => message;
}
