import 'package:flutter/material.dart';

/// Hiển thị dialog thông báo "Đã thêm vào giỏ hàng" và tự đóng sau
/// [autoCloseAfter].
void showAddedToCartDialog(
    BuildContext context, {
      Duration autoCloseAfter = const Duration(milliseconds: 1500),
    }) {
  showDialog(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.2),
    barrierDismissible: false,
    builder: (_) => const _AddedToCartContent(),
  );

  Future.delayed(autoCloseAfter, () {
    if (context.mounted && Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  });
}

class _AddedToCartContent extends StatelessWidget {
  const _AddedToCartContent();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 180,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.greenAccent, size: 52),
            SizedBox(height: 11),
            Text(
              'Đã thêm vào giỏ hàng',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
