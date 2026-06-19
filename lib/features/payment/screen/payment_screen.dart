import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/services/api_helpers.dart';
import '../../../core/theme/app_colors.dart';

class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key});

  static const Color _wine = AppColors.wine;

  @override
  Widget build(BuildContext context) {
    final rawOrder = ModalRoute.of(context)?.settings.arguments;
    final order = rawOrder is Map<String, dynamic> ? rawOrder : null;
    final total = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: 'd',
    ).format(toDouble(order?['totalAmount']));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thanh toán'),
        backgroundColor: _wine,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 72),
            const SizedBox(height: 16),
            Text(
              'Đơn hàng đã được tạo',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Mã đơn: ${order?['id'] ?? 'N/A'}',
              textAlign: TextAlign.center,
            ),
            Text('Tổng thanh toán: $total', textAlign: TextAlign.center),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () =>
                  Navigator.pushReplacementNamed(context, '/orders'),
              icon: const Icon(Icons.receipt_long),
              label: const Text('Xem lịch sử đơn hàng'),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: _wine,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pushNamedAndRemoveUntil(
                context,
                '/home',
                (route) => false,
              ),
              icon: const Icon(Icons.home),
              label: const Text('Về trang chủ'),
            ),
          ],
        ),
      ),
    );
  }
}
