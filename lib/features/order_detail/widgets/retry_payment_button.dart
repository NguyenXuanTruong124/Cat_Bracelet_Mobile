import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../payment/services/payment_service.dart';

class RetryPaymentButton extends StatelessWidget {
  final String orderId;
  final VoidCallback onSuccess;
  final Function(String) onError;

  const RetryPaymentButton({
    super.key,
    required this.orderId,
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
            final payment = await PaymentService()
                .retryPayment(context, orderId);

            await launchUrl(
              Uri.parse(payment.checkoutUrl),
              mode: LaunchMode.externalApplication,
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