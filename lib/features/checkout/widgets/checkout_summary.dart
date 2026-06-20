import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CheckoutSummary extends StatelessWidget {
  final double subtotal;
  final double shippingFee;
  final double discount;
  final bool isLoadingShipping;

  const CheckoutSummary({
    super.key,
    required this.subtotal,
    required this.shippingFee,
    required this.discount,
    required this.isLoadingShipping,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _row(
              'Tiền hàng',
              subtotal,
            ),

            _shippingRow(),

            _row(
              'Giảm giá',
              -discount,
            ),

            const Divider(),

            _totalRow(),
          ],
        ),
      ),
    );
  }

  Widget _shippingRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 4,
      ),
      child: Row(
        mainAxisAlignment:
        MainAxisAlignment.spaceBetween,
        children: [
          const Text('Phí ship'),
          isLoadingShipping
              ? const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
            ),
          )
              : Text(
            NumberFormat.currency(
              locale: 'vi_VN',
              symbol: 'đ',
            ).format(shippingFee),
          ),
        ],
      ),
    );
  }

  Widget _totalRow() {
    final total =
        subtotal + shippingFee - discount;

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 4,
      ),
      child: Row(
        mainAxisAlignment:
        MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Tổng thanh toán',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          isLoadingShipping
              ? const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
            ),
          )
              : Text(
            NumberFormat.currency(
              locale: 'vi_VN',
              symbol: 'đ',
            ).format(total),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(
      String title,
      double amount, {
        bool isBold = false,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 4,
      ),
      child: Row(
        mainAxisAlignment:
        MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: isBold
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
          Text(
            NumberFormat.currency(
              locale: 'vi_VN',
              symbol: 'đ',
            ).format(amount),
            style: TextStyle(
              fontWeight: isBold
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}