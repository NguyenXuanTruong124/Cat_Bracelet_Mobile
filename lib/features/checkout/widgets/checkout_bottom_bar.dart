import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class CheckoutBottomBar
    extends StatelessWidget {
  final VoidCallback onCheckout;

  const CheckoutBottomBar({
    super.key,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.wine,
        foregroundColor: Colors.white,
        minimumSize:
        const Size.fromHeight(50),
      ),
      onPressed: onCheckout,
      icon: const Icon(
        Icons.check_circle,
      ),
      label: const Text(
        'Xác nhận đặt hàng',
      ),
    );
  }
}