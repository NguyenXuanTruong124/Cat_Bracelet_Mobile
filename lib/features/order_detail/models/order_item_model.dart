class OrderItemModel {
  final String productName;
  final String color;
  final String size;
  final int quantity;
  final double totalPrice;

  const OrderItemModel({
    required this.productName,
    required this.color,
    required this.size,
    required this.quantity,
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
    mappings?.isNotEmpty == true
        ? mappings!.first['product']
        : null;

    return OrderItemModel(
      productName:
      product?['productName'] ?? 'Sản phẩm',
      color: variant?['color'] ?? '',
      size: variant?['size'] ?? '',
      quantity: json['quantity'] ?? 0,
      totalPrice: double.tryParse(
        json['totalPrice']?.toString() ?? '0',
      ) ??
          0,
    );
  }
}