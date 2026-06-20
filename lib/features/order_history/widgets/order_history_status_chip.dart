import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class OrderHistoryStatusChip
    extends StatelessWidget {
  final String status;

  const OrderHistoryStatusChip({
    super.key,
    required this.status,
  });

  String get label {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return 'Chờ xác nhận';

      case 'CONFIRMED':
        return 'Đã xác nhận';

      case 'SHIPPING':
      case 'SHIPPED':
        return 'Đang vận chuyển';

      case 'DELIVERED':
      case 'COMPLETED':
        return 'Đã giao';

      case 'CANCELLED':
        return 'Đã huỷ';

      default:
        return status;
    }
  }

  Color get color {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return AppColors.secondary;

      case 'CONFIRMED':
        return AppColors.primaryContainer;

      case 'CANCELLED':
        return const Color(0xFFBA1A1A);

      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(
          alpha: 0.12,
        ),
        borderRadius:
        BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}