class VoucherModel {
  final String id;
  final String code;
  final double discountValue;
  final String discountType;
  final int quantity;
  final String startDate;
  final String endDate;
  final String status;

  VoucherModel({
    required this.id,
    required this.code,
    required this.discountValue,
    required this.discountType,
    required this.quantity,
    required this.startDate,
    required this.endDate,
    required this.status,
  });

  factory VoucherModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return VoucherModel(
      id: json['id']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      discountValue:
      double.tryParse(
        json['discountValue']?.toString() ?? '0',
      ) ??
          0,
      discountType:
      json['discountType']?.toString() ?? '',
      quantity: json['quantity'] ?? 0,
      startDate:
      json['startDate']?.toString() ?? '',
      endDate:
      json['endDate']?.toString() ?? '',
      status:
      json['status']?.toString() ?? '',
    );
  }
}