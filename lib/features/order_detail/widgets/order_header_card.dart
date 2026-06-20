import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../utils/order_status_helper.dart';

class OrderHeaderCard extends StatelessWidget {
  final String orderId;
  final String totalPrice;
  final String? paymentStatus;

  const OrderHeaderCard({
    super.key,
    required this.orderId,
    required this.totalPrice,
    required this.paymentStatus,
  });

  String get shortOrderId {
    return orderId.length >= 8
        ? orderId.substring(0, 8).toUpperCase()
        : orderId.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final statusColor =
    OrderStatusHelper.paymentStatusColor(
      paymentStatus,
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(
            alpha: 0.2,
          ),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: AppColors.secondaryContainer
                  .withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(
                999,
              ),
              border: Border.all(
                color: AppColors.secondaryContainer,
              ),
            ),
            child: Text(
              'Mã đơn hàng: #CB-$shortOrderId',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
                color: AppColors.secondary,
              ),
            ),
          ),

          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: statusColor.withValues(
                alpha: 0.12,
              ),
              borderRadius:
              BorderRadius.circular(20),
            ),
            child: Text(
              OrderStatusHelper.paymentStatusLabel(
                paymentStatus,
              ),
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: statusColor,
              ),
            ),
          ),

          const SizedBox(height: 12),

          Text(
            'Tổng thanh toán: $totalPrice',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}