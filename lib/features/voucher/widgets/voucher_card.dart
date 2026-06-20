import 'package:flutter/material.dart';
import '../../../core/utils/number_formatter.dart';
import '../../../core/theme/app_colors.dart';
import '../models/voucher_model.dart';

class VoucherCard extends StatelessWidget {
  final VoucherModel voucher;
  final VoidCallback onTap;

  const VoucherCard({
    super.key,
    required this.voucher,
    required this.onTap,
  });

  static const Color _wine = AppColors.wine;
  static const Color _gold = AppColors.gold;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: _gold.withValues(alpha: 0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: _wine,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.local_activity,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    voucher.code,
                    style: const TextStyle(
                      color: _wine,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    voucher.discountType == 'PERCENT'
                        ? 'Giảm ${NumberFormatter.clean(voucher.discountValue)}%'
                        : 'Giảm ${NumberFormatter.clean(voucher.discountValue)}đ',
                  ),

                  Text(
                    'Hạn sử dụng: ${voucher.endDate}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.arrow_forward,
              color: _wine,
            ),
          ],
        ),
      ),
    );
  }
}