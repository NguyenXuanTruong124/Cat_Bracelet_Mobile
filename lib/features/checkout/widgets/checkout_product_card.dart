import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CheckoutProductCard extends StatelessWidget {
  final Map<String, dynamic> item;

  const CheckoutProductCard({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final product = item['product'];
    final variant = item['variantDetails'];

    return Card(
      child: ListTile(
        title: Text(
          product['productName'],
        ),
        subtitle: Text(
          '${variant['color']} - ${variant['size']}\n'
              '${item['quantity']} x '
              '${_money((item['unitPrice'] as num).toDouble())}',
        ),
        trailing: Text(
          _money(
            (item['subTotal'] as num).toDouble(),
          ),
        ),
      ),
    );
  }

  String _money(double value) {
    return NumberFormat.currency(
      locale: 'vi_VN',
      symbol: 'đ',
    ).format(value);
  }
}