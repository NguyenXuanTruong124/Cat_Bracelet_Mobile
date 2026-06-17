import 'package:cat_bracelet_mobile/features/product/models/product.dart';


class ProductVariantMapping {
  final String productId;
  final Product? product;

  ProductVariantMapping({
    required this.productId,
    this.product,
  });

  factory ProductVariantMapping.fromJson(
      Map<String, dynamic> json,
      ) {
    return ProductVariantMapping(
      productId: json['productId'].toString(),
      product: json['product'] != null
          ? Product.fromJson(json['product'])
          : null,
    );
  }
}