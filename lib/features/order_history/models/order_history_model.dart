class OrderHistoryModel {
  final String id;
  final String status;
  final double totalAmount;
  final DateTime? createdAt;

  const OrderHistoryModel({
    required this.id,
    required this.status,
    required this.totalAmount,
    required this.createdAt,
  });

  factory OrderHistoryModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return OrderHistoryModel(
      id: json['id']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      totalAmount: (json['totalAmount'] ?? 0)
          .toDouble(),
      createdAt: DateTime.tryParse(
        json['createdAt']?.toString() ?? '',
      ),
    );
  }

  String get shortId =>
      id.length > 8
          ? id.substring(0, 8).toUpperCase()
          : id;
}