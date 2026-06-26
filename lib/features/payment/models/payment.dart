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
    final payment = _asMap(data['payment']) ?? _asMap(json['payment']);
    final paymentData = _asMap(payment?['data']);
    final order = _asMap(data['order']) ?? _asMap(json['order']);

    return Payment(
      success: data['success'] ?? json['success'] ?? false,
      orderId: _readString(data, const ['orderId', 'order_id', 'id', '_id'])
          .ifEmpty(_readString(payment, const ['orderId', 'order_id']))
          .ifEmpty(_readString(order, const ['id', '_id', 'orderId'])),
      orderCode: toInt(
        data['orderCode'] ??
            data['paymentOrderCode'] ??
            data['order_code'] ??
            payment?['orderCode'] ??
            payment?['paymentOrderCode'] ??
            paymentData?['orderCode'] ??
            paymentData?['paymentOrderCode'] ??
            order?['orderCode'] ??
            order?['paymentOrderCode'],
      ),
      amount: toDouble(
        data['amount'] ?? payment?['amount'] ?? paymentData?['amount'],
      ),
      paymentAmountSource:
          _readString(data, const ['paymentAmountSource', 'amountSource'])
              .ifEmpty(
                _readString(payment, const [
                  'paymentAmountSource',
                  'amountSource',
                ]),
              )
              .ifEmpty(
                _readString(paymentData, const [
                  'paymentAmountSource',
                  'amountSource',
                ]),
              ),
      checkoutUrl:
          _readString(data, const ['checkoutUrl', 'checkout_url', 'paymentUrl'])
              .ifEmpty(
                _readString(payment, const [
                  'checkoutUrl',
                  'checkout_url',
                  'paymentUrl',
                ]),
              )
              .ifEmpty(
                _readString(paymentData, const [
                  'checkoutUrl',
                  'checkout_url',
                  'paymentUrl',
                ]),
              ),
      paymentLinkId:
          _readString(data, const ['paymentLinkId', 'payment_link_id'])
              .ifEmpty(
                _readString(payment, const [
                  'paymentLinkId',
                  'payment_link_id',
                ]),
              )
              .ifEmpty(
                _readString(paymentData, const [
                  'paymentLinkId',
                  'payment_link_id',
                ]),
              ),
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

  static String _readString(Map<String, dynamic>? data, List<String> keys) {
    if (data == null) {
      return '';
    }

    for (final key in keys) {
      final value = data[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }
    return '';
  }
}

extension on String {
  String ifEmpty(String fallback) => isEmpty ? fallback : this;
}
