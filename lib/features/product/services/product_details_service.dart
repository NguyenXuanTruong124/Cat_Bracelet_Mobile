import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/services/api_helpers.dart';
import '../models/product.dart';
import '../models/product_variants.dart';

/// Kết quả trả về khi tải chi tiết sản phẩm: thông tin sản phẩm kèm danh
/// sách biến thể đang active của sản phẩm đó.
class ProductDetailsResult {
  final Product product;
  final List<ProductVariants> variants;

  const ProductDetailsResult({required this.product, required this.variants});
}

/// Chịu trách nhiệm gọi API liên quan đến chi tiết một sản phẩm: lấy thông
/// tin sản phẩm, lấy biến thể và thêm sản phẩm vào giỏ hàng.
class ProductDetailsService {
  const ProductDetailsService();

  Future<ProductDetailsResult> fetchDetails({
    required String baseUrl,
    required Product fallbackProduct,
  }) async {
    final productUrl = Uri.parse('$baseUrl/products/${fallbackProduct.id}');
    final variantsUrl = Uri.parse(
      '$baseUrl/product-variants/by-name/${Uri.encodeComponent(fallbackProduct.productName)}',
    );

    final responses = await Future.wait([
      http.get(productUrl),
      http.get(variantsUrl),
    ]);

    final product = _parseProduct(responses[0].body, responses[0].statusCode) ??
        fallbackProduct;
    final variants = _parseVariants(
      responses[1].body,
      responses[1].statusCode,
      productId: fallbackProduct.id,
    );

    return ProductDetailsResult(product: product, variants: variants);
  }

  /// Thêm biến thể đã chọn vào giỏ hàng. Trả về `true` nếu thành công.
  Future<bool> addToCart({
    required String baseUrl,
    required String variantId,
    int quantity = 1,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/cart/add'),
      headers: apiHeaders(json: true),
      body: jsonEncode({'variantId': variantId, 'quantity': quantity}),
    );

    return response.statusCode == 200 || response.statusCode == 201;
  }

  Product? _parseProduct(String body, int statusCode) {
    if (statusCode != 200) return null;

    final decoded = _decodeObject(body);
    return decoded == null ? null : Product.fromJson(decoded);
  }

  List<ProductVariants> _parseVariants(
      String body,
      int statusCode, {
        required String productId,
      }) {
    if (statusCode != 200) return [];

    return _decodeList(body)
        .whereType<Map<String, dynamic>>()
        .map(ProductVariants.fromJson)
        .where((variant) => _isVariantOfActiveProduct(variant, productId))
        .toList();
  }

  bool _isVariantOfActiveProduct(ProductVariants variant, String productId) {
    if (variant.status.toUpperCase() != 'ACTIVE') {
      return false;
    }

    return variant.mappings.any(
          (mapping) =>
      mapping.productId == productId && mapping.product?.status == 'ACTIVE',
    );
  }

  List<dynamic> _decodeList(String body) {
    final decoded = jsonDecode(body);
    if (decoded is List) {
      return decoded;
    }
    if (decoded is Map<String, dynamic>) {
      final data = decoded['data'] ?? decoded['items'] ?? decoded['content'];
      if (data is List) {
        return data;
      }
      return [decoded];
    }
    return [];
  }

  Map<String, dynamic>? _decodeObject(String body) {
    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) {
      final data = decoded['data'];
      if (data is Map<String, dynamic>) {
        return data;
      }
      return decoded;
    }
    return null;
  }
}
