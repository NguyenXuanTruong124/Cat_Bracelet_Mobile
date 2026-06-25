import 'package:flutter/material.dart';

class StatusHelper {
  // PAYMENT STATUS

  static Color paymentStatusColor(String? status) {
    switch ((status ?? '').toUpperCase()) {
      case 'PAID':
        return Colors.green;

      case 'PENDING':
        return Colors.orange;

      case 'FAILED':
      case 'CANCELLED':
        return Colors.red;

      case 'UNPAID':
        return Colors.grey;


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

        case 'UNPAID':
          return 'Chưa thanh toán';

      default:
        return status ?? '';
    }
  }

  // ORDER STATUS

  static Color orderStatusColor(String? status) {
    switch ((status ?? '').toUpperCase()) {
      case 'PENDING':
        return Colors.orange;

      case 'PROCESSING':
        return Colors.blue;

      case 'SHIPPING':
      case 'DELIVERING':
        return Colors.purple;

      case 'COMPLETED':
      case 'DELIVERED':
        return Colors.green;

      case 'CANCELLED':
        return Colors.red;

      default:
        return Colors.grey;
    }
  }

  static String orderStatusLabel(String? status) {
    switch ((status ?? '').toUpperCase()) {
      case 'PENDING':
        return 'Chờ xác nhận';

      case 'PROCESSING':
        return 'Đang xử lý';

      case 'SHIPPING':
      case 'DELIVERING':
        return 'Đang giao hàng';

      case 'COMPLETED':
      case 'DELIVERED':
        return 'Hoàn thành';

      case 'CANCELLED':
        return 'Đã hủy';

      default:
        return status ?? '';
    }
  }
}