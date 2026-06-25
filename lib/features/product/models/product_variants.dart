import 'package:cat_bracelet_mobile/features/product/models/product_variant_mapping.dart';

class ProductVariants {
  final String id;
  final String sku;
  final String? size;
  final String? color;
  final int stock;
  final double extraPrice;
  final String status;

  ProductVariants({
    required this.id,
    required this.sku,
    this.size,
    this.color,
    required this.stock,
    required this.extraPrice,
    required this.status,
    this.mappings = const [],
  });
  factory ProductVariants.fromJson(Map<String, dynamic> json) {
    return ProductVariants(
      id: (json['id'] ?? json['variantId'] ?? json['variant_id'] ?? '')
          .toString(),
      sku: (json['sku'] ?? '').toString(),
      size: json['size']?.toString(),
      color: json['color']?.toString(),
      stock: _toInt(json['stockQuantity'] ?? json['stock_quantity']),
      extraPrice: _toDouble(json['extraPrice'] ?? json['extra_price']),
      status: (json['status'] ?? 'ACTIVE').toString(),
      mappings:
      (json['productVariantMappings'] as List?)
          ?.map(
            (e) => ProductVariantMapping.fromJson(
          e as Map<String, dynamic>,
        ),
      )
          .toList() ??
          [],
    );
  }
  final List<ProductVariantMapping> mappings;


  static int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

}
