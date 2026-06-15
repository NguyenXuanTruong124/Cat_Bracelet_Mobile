class PaymentStatusModel {
  final String status;
  final int orderCode;

  const PaymentStatusModel({
    required this.status,
    required this.orderCode,
  });

  factory PaymentStatusModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return PaymentStatusModel(
      status: json['status'] ?? '',
      orderCode: json['orderCode'] ?? 0,
    );
  }

}