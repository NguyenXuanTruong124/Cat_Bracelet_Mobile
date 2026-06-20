import 'order_item_model.dart';
import 'shipping_address_model.dart';

class OrderDetailModel {
  final String id;
  final String paymentStatus;
  final double totalAmount;
  final bool canRetryPayment;

  final ShippingAddressModel? address;

  final List<OrderItemModel> items;

  const OrderDetailModel({
    required this.id,
    required this.paymentStatus,
    required this.totalAmount,
    required this.canRetryPayment,
    required this.address,
    required this.items,
  });

  factory OrderDetailModel.fromJson(
      Map<String, dynamic> json,
      ) {
    final rawItems =
        (json['items'] as List?) ?? [];

    return OrderDetailModel(
      id: json['id']?.toString() ?? '',

      paymentStatus:
      json['paymentStatus'] ?? '',

      totalAmount:
      (json['totalAmount'] ?? 0)
          .toDouble(),

      canRetryPayment:
      json['canRetryPayment'] == true,

      address: json['address'] != null
          ? ShippingAddressModel.fromJson(
        json['address'],
      )
          : null,

      items: rawItems
          .map(
            (e) => OrderItemModel.fromJson(
          e,
        ),
      )
          .toList(),
    );
  }
}