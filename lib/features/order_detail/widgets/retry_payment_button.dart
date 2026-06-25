import 'package:flutter/material.dart';

import '../../payment/screens/payOS_webview_screen.dart';
import '../../payment/services/payment_service.dart';

class RetryPaymentButton extends StatelessWidget {
  final String orderId;
  final int? fallbackOrderCode;
  final VoidCallback onSuccess;
  final Function(String) onError;

  const RetryPaymentButton({
    super.key,
    required this.orderId,
    this.fallbackOrderCode,
    required this.onSuccess,
    required this.onError,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.payment),
        label: const Text('THANH TOÁN LẠI'),
        onPressed: () async {
          try {
            final payment = await PaymentService().retryPayment(
              context,
              orderId,
            );

            if (payment.checkoutUrl.isEmpty) {
              throw Exception('Không có link thanh toán');
            }

            if (!context.mounted) {
              return;
            }

            final orderCode = payment.orderCode == 0
                ? fallbackOrderCode ?? 0
                : payment.orderCode;

            if (orderCode == 0) {
              throw Exception('Không lấy được mã thanh toán');
            }

            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PayOsWebViewScreen(
                  checkoutUrl: payment.checkoutUrl,
                  orderCode: orderCode,
                ),
              ),
            );

            onSuccess();
          } catch (e) {
            onError(e.toString());
          }
        },
      ),
    );
  }
}
