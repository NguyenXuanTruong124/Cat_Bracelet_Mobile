import '../../../core/services/api_helpers.dart';

class PaymentStatusModel {
  final String paymentStatus;
  final int orderCode;

  const PaymentStatusModel({
    required this.paymentStatus,
    required this.orderCode,
  });

  factory PaymentStatusModel.fromJson(Map<String, dynamic> json) {
    final data = _asMap(json['data']) ?? json;
    final payment = _asMap(data['payment']);
    final order = _asMap(data['order']);

    return PaymentStatusModel(
      paymentStatus:
          _readString(data, const ['status', 'paymentStatus', 'payment_status'])
              .ifEmpty(
                _readString(payment, const [
                  'status',
                  'paymentStatus',
                  'payment_status',
                ]),
              )
              .ifEmpty(
                _readString(order, const [
                  'status',
                  'paymentStatus',
                  'payment_status',
                ]),
              ),
      orderCode: toInt(
        data['orderCode'] ??
            data['paymentOrderCode'] ??
            data['order_code'] ??
            payment?['orderCode'] ??
            payment?['paymentOrderCode'] ??
            order?['orderCode'] ??
            order?['paymentOrderCode'],
      ),
    );
  }

  bool get isPaid {
    final normalized = paymentStatus.toUpperCase();
    return normalized == 'PAID' ||
        normalized == 'SUCCESS' ||
        normalized == 'SUCCEEDED' ||
        normalized == 'COMPLETED';
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

  static String _readString(Map<String, dynamic>? data, List<String> keys) {
    if (data == null) {
      return '';
    }

    for (final key in keys) {
      final value = data[key];
      if (value != null && value.toString().isNotEmpty) {
        return value.toString();
      }
    }
    return '';
  }
}

extension on String {
  String ifEmpty(String fallback) => isEmpty ? fallback : this;
}
