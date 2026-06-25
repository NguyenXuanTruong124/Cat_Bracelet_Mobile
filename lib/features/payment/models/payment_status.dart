import '../../../core/services/api_helpers.dart';

class PaymentStatusModel {
  final String paymentStatus;
  final int orderCode;

  const PaymentStatusModel({
    required this.paymentStatus,
    required this.orderCode,
  });

  factory PaymentStatusModel.fromJson(
      Map<String, dynamic> json,
      ) {
    final data =
        json['data'] as Map<String, dynamic>? ?? {};

    return PaymentStatusModel(
      paymentStatus:
      data['status']?.toString() ?? '',
      orderCode:
      toInt(data['orderCode']),
    );
  }

  bool get isPaid =>
      paymentStatus.toUpperCase() == 'PAID';
}