import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class CheckoutBottomBar extends StatelessWidget {
  final VoidCallback onCheckout;
  final bool isLoading;

  const CheckoutBottomBar({
    super.key,
    required this.onCheckout,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.wine,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(50),
      ),
      onPressed: isLoading ? null : onCheckout,
      icon: isLoading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.check_circle),
      label: Text(isLoading ? 'Đang đặt hàng...' : 'Xác nhận đặt hàng'),
    );
  }
}
