import 'order_item_model.dart';
import 'shipping_address_model.dart';

class OrderDetailModel {
  final String id;

  final String status;
  final String paymentStatus;

  final double totalAmount;
  final double shippingFee;

  final bool canRetryPayment;

  final DateTime createdAt;
  final DateTime? paidAt;

  final String? paymentOrderCode;

  final String? voucherCode;
  final double voucherValue;
  final String? voucherType;

  final ShippingAddressModel? address;

  final List<OrderItemModel> items;

  const OrderDetailModel({
    required this.id,
    required this.status,
    required this.paymentStatus,
    required this.totalAmount,
    required this.shippingFee,
    required this.canRetryPayment,
    required this.createdAt,
    this.paidAt,
    this.paymentOrderCode,
    required this.address,
    required this.items,
    this.voucherCode,
    required this.voucherValue,
    this.voucherType,
  });

  factory OrderDetailModel.fromJson(Map<String, dynamic> json) {
    final rawItems = (json['items'] as List?) ?? [];

    return OrderDetailModel(
      id:
          (json['id'] ?? json['_id'] ?? json['orderId'] ?? json['order_id'])
              ?.toString() ??
          '',

      status: json['status'] ?? '',

      paymentStatus: json['paymentStatus'] ?? '',

      totalAmount: (json['totalAmount'] ?? 0).toDouble(),

      shippingFee: (json['shippingFee'] ?? 0).toDouble(),

      canRetryPayment: json['canRetryPayment'] == true,

      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),

      paidAt: json['paidAt'] != null ? DateTime.tryParse(json['paidAt']) : null,

      paymentOrderCode:
          (json['paymentOrderCode'] ?? json['orderCode'] ?? json['order_code'])
              ?.toString(),

      address: json['address'] != null
          ? ShippingAddressModel.fromJson(json['address'])
          : null,

      items: rawItems.map((e) => OrderItemModel.fromJson(e)).toList(),

      voucherCode: json['voucher']?['code']?.toString(),

      voucherValue:
          double.tryParse(
            json['voucher']?['discountValue']?.toString() ?? '0',
          ) ??
          0,

      voucherType: json['voucher']?['discountType']?.toString(),
    );
  }
}
