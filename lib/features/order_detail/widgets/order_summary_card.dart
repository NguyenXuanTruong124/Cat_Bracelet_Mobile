import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class OrderSummaryCard extends StatelessWidget {
  final String subtotal;
  final String shippingFee;
  final String total;

  final String? voucherCode;
  final String? voucherDiscount;

  const OrderSummaryCard({
    super.key,
    required this.subtotal,
    required this.shippingFee,
    required this.total,
    this.voucherCode,
    this.voucherDiscount,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
              children: [
                const Text('Tạm tính'),
                Text(subtotal),
              ],
            ),

            const SizedBox(height: 8),

            if (voucherCode != null &&
                voucherCode!.isNotEmpty) ...[
              Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Voucher',
                  ),
                  Text(
                    voucherDiscount ?? '',
                    style: const TextStyle(
                      fontWeight:
                      FontWeight.w600,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),
            ],

            Row(
              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
              children: [
                const Text('Phí vận chuyển'),
                Text(shippingFee),
              ],
            ),

            const Divider(height: 24),

            Row(
              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tổng cộng',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  total,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}