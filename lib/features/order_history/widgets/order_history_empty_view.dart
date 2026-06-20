import 'package:flutter/material.dart';

class OrderHistoryEmptyView
    extends StatelessWidget {
  const OrderHistoryEmptyView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment:
        MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 72,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 12),
          const Text(
            'Chưa có đơn hàng',
            style: TextStyle(
              fontSize: 16,
              fontWeight:
              FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}