import 'product_image.dart';

class Product {
  final String id;
  final String? categoryId;
  final String? categoryName;
  final List<String> materialNames;
  final List<String> materialTypes;
  final List<String> materialColors;
  final String productName;
  final int basePrice;
  final String? thumbnail;
  final String? description;
  final String status;

  Product({
    required this.id,
    this.categoryId,
    this.categoryName,
    this.productImages = const [],
    this.materialNames = const [],
    this.materialTypes = const [],
    this.materialColors = const [],
    required this.productName,
    required this.basePrice,
    this.thumbnail,
    this.description,
    required this.status,

  });

  String? get firstImage {
    try {
      return productImages
          .firstWhere((e) => e.isActive)
          .imageUrl;
    } catch (_) {
      return thumbnail;
    }
  }
  final List<ProductImage> productImages;
  factory Product.fromJson(Map<String, dynamic> json) {
    final category = json['category'];
    final materials = _readMaterials(json['product_materials']);

    return Product(
      id: (json['id'] ?? json['productId'] ?? json['product_id'] ?? '')
          .toString(),
      categoryId: (json['categoryId'] ?? json['category_id'])?.toString(),
      categoryName: category is Map<String, dynamic>
          ? (category['categoryName'] ?? category['category_name'])?.toString()
          : null,
      productImages:
      (json['productImages'] as List?)
          ?.whereType<Map<String, dynamic>>()
          .map(ProductImage.fromJson)
          .toList() ??
          [],
      materialNames: materials.names,
      materialTypes: materials.types,
      materialColors: materials.colors,
      productName:
          (json['productName'] ?? json['product_name'] ?? 'San pham khong ten')
              .toString(),
      basePrice: _toInt(json['basePrice'] ?? json['base_price']),
      thumbnail: json['thumbnail']?.toString(),
      description: json['description']?.toString(),
      status: (json['status'] ?? 'INACTIVE').toString(),

    );
  }

  static int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return (double.tryParse(value?.toString() ?? '') ?? 0).toInt();
  }

  static _ProductMaterialData _readMaterials(dynamic rawMaterials) {
    final names = <String>[];
    final types = <String>[];
    final colors = <String>[];

    if (rawMaterials is! List) {
      return _ProductMaterialData(names, types, colors);
    }

    for (final item in rawMaterials) {
      if (item is! Map<String, dynamic>) {
        continue;
      }
      final material = item['material'];
      if (material is! Map<String, dynamic>) {
        continue;
      }

      final name = material['materialName'] ?? material['material_name'];
      final type = material['materialType'] ?? material['material_type'];
      final color = material['color'];

      if (name != null && name.toString().trim().isNotEmpty) {
        names.add(name.toString().trim());
      }
      if (type != null && type.toString().trim().isNotEmpty) {
        types.add(type.toString().trim());
      }
      if (color != null && color.toString().trim().isNotEmpty) {
        colors.add(color.toString().trim());
      }
    }

    return _ProductMaterialData(names, types, colors);
  }
}

class _ProductMaterialData {
  final List<String> names;
  final List<String> types;
  final List<String> colors;

  const _ProductMaterialData(this.names, this.types, this.colors);
}
