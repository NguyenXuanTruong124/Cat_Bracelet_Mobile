class OrderItemModel {
  final String productName;

  final String sku;
  final String color;
  final String size;

  final String? thumbnail;

  final int quantity;

  final double unitPrice;
  final double totalPrice;

  const OrderItemModel({
    required this.productName,
    required this.sku,
    required this.color,
    required this.size,
    required this.thumbnail,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });

  factory OrderItemModel.fromJson(
      Map<String, dynamic> json,
      ) {
    final variant =
    json['variant'] as Map<String, dynamic>?;

    final mappings =
    variant?['productVariantMappings'] as List?;

    final product =
    mappings != null && mappings.isNotEmpty
        ? mappings.first['product']
        : null;

    return OrderItemModel(
      productName:
      product?['productName'] ?? 'Sản phẩm',

      thumbnail:
      product?['thumbnail']?.toString(),

      sku: variant?['sku'] ?? '',

      color: variant?['color'] ?? '',

      size: variant?['size'] ?? '',

      quantity: json['quantity'] ?? 0,

      unitPrice: double.tryParse(
        json['unitPrice']?.toString() ?? '0',
      ) ??
          0,

      totalPrice: double.tryParse(
        json['totalPrice']?.toString() ?? '0',
      ) ??
          0,
    );
  }
}