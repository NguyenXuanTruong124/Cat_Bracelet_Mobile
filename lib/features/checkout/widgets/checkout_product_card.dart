import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/services/api_helpers.dart';

class CheckoutProductCard extends StatelessWidget {
  final Map<String, dynamic> item;

  const CheckoutProductCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final product = readProductPayload(item);
    final variant = asStringMap(item['variantDetails'] ?? item['variant']);
    final quantity = toInt(item['quantity']);
    final unitPrice = toDouble(item['unitPrice'] ?? item['unit_price']);
    final subTotal = toDouble(item['subTotal'] ?? item['sub_total']);

    return Card(
      child: ListTile(
        title: Text(
          (product?['productName'] ?? product?['product_name'] ?? 'Sản phẩm')
              .toString(),
        ),
        subtitle: Text(
          '${variant?['color'] ?? ''} - ${variant?['size'] ?? ''}\n'
          '$quantity x ${_money(unitPrice)}',
        ),
        trailing: Text(_money(subTotal)),
      ),
    );
  }

  String _money(double value) {
    return NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(value);
  }
}
