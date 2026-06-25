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

  factory Payment.fromJson(Map<String, dynamic> json) {
    final data = _asMap(json['data']) ?? json;

    return Payment(
      success: data['success'] ?? json['success'] ?? false,
      orderId: data['orderId']?.toString() ?? '',
      orderCode: toInt(
        data['orderCode'] ?? data['paymentOrderCode'] ?? data['order_code'],
      ),
      amount: toDouble(data['amount']),
      paymentAmountSource: data['paymentAmountSource']?.toString() ?? '',
      checkoutUrl: data['checkoutUrl']?.toString() ?? '',
      paymentLinkId: data['paymentLinkId']?.toString() ?? '',
    );
  }

  static Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return value.map((key, value) => MapEntry(key.toString(), value));
    }
    return null;
  }
}
