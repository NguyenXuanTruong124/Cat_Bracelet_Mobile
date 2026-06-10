class Product {
  final String id;
  final String productName;
  final int basePrice;
  final String? thumbnail;
  final String? description;

  Product({
    required this.id,
    required this.productName,
    required this.basePrice,
    this.thumbnail,
    this.description,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // Handling basePrice which could be int or double from JSON
    int parsedPrice = 0;
    if (json['basePrice'] != null) {
      if (json['basePrice'] is int) {
        parsedPrice = json['basePrice'];
      } else if (json['basePrice'] is double) {
        parsedPrice = (json['basePrice'] as double).toInt();
      } else if (json['basePrice'] is String) {
        parsedPrice = int.tryParse(json['basePrice']) ?? 0;
      }
    }

    return Product(
      id: json['id'] ?? '',
      productName: json['productName'] ?? 'Sản phẩm không tên',
      basePrice: parsedPrice,
      thumbnail: json['thumbnail'],
      description: json['description'],
    );
  }
}
