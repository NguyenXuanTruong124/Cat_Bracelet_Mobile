class Product {
  final String id;
  final String productName;
  final int basePrice;
  final String? thumbnail;
  final String? description;
  final String status;

  Product({
    required this.id,
    required this.productName,
    required this.basePrice,
    this.thumbnail,
    this.description,
    required this.status,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? '',
      productName: json['productName'] ?? 'Sản phẩm không tên',
      basePrice: (double.tryParse(json['basePrice'].toString()) ?? 0).toInt(),
      thumbnail: json['thumbnail'],
      description: json['description'],
      status: json['status'] ?? 'INACTIVE',
    );
  }
}
