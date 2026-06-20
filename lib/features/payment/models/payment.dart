import '../../../core/services/api_helpers.dart';

class Payment {
  final bool success;
  final String orderId;
  final int orderCode;
  final double amount;
  final String paymentAmountSource;
  final String checkoutUrl;
  final String paymentLinkId;

  const Payment({
    required this.success,
    required this.orderId,
    required this.orderCode,
    required this.amount,
    required this.paymentAmountSource,
    required this.checkoutUrl,
    required this.paymentLinkId,
  });

  factory Payment.fromJson(
      Map<String, dynamic> json,
      ) {
    return Payment(
      success: json['success'] ?? false,
      orderId: json['orderId'] ?? '',
      orderCode: toInt(json['orderCode']),
      amount: toDouble(json['amount']),
      paymentAmountSource:
      json['paymentAmountSource'] ?? '',
      checkoutUrl: json['checkoutUrl'] ?? '',
      paymentLinkId: json['paymentLinkId'] ?? '',
    );
  }
}