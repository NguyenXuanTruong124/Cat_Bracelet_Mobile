import 'package:flutter/material.dart';

class OrderStatusHelper {
  static Color paymentStatusColor(String? status) {
    switch ((status ?? '').toUpperCase()) {
      case 'PAID':
        return Colors.green;

      case 'PENDING':
        return Colors.orange;

      case 'FAILED':
      case 'CANCELLED':
        return Colors.red;

      default:
        return Colors.grey;
    }
  }

  static String paymentStatusLabel(String? status) {
    switch ((status ?? '').toUpperCase()) {
      case 'PAID':
        return 'Đã thanh toán';

      case 'PENDING':
        return 'Chờ thanh toán';

      case 'FAILED':
        return 'Thanh toán thất bại';

      case 'CANCELLED':
        return 'Đã hủy';

      default:
        return status ?? '';
    }
  }
}