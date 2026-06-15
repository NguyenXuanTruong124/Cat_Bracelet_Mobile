class ProductImage {
  final String id;
  final String productId;
  final String imageUrl;
  final String status;

  const ProductImage({
    required this.id,
    required this.productId,
    required this.imageUrl,
    required this.status,
  });

  factory ProductImage.fromJson(Map<String, dynamic> json) {
    return ProductImage(
      id: (json['id'] ?? json['image_id'] ?? '').toString(),
      productId:
      (json['productId'] ?? json['product_id'] ?? '').toString(),
      imageUrl:
      (json['imageUrl'] ?? json['image_url'] ?? '').toString(),
      status: (json['status'] ?? 'ACTIVE').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'imageUrl': imageUrl,
      'status': status,
    };
  }

  bool get isActive => status.toUpperCase() == 'ACTIVE';
}