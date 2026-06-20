import 'package:flutter/material.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/theme/app_colors.dart';
import '../models/voucher_model.dart';
import '../../../core/utils/number_formatter.dart';

class VoucherDetailScreen extends StatelessWidget {
  final VoucherModel voucher;

  const VoucherDetailScreen({
    super.key,
    required this.voucher,
  });

  static const Color _wine = AppColors.wine;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFAEF),
      appBar: AppBar(
        title: const Text('Chi tiết voucher'),
        backgroundColor: _wine,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  voucher.code,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: _wine,
                  ),
                ),

                const SizedBox(height: 20),

                _buildInfoRow(
                  'Loại giảm giá',
                  voucher.discountType,
                ),

                _buildInfoRow(
                  'Giá trị',
                    voucher.discountType == 'PERCENT'
                        ? '${NumberFormatter.clean(voucher.discountValue)}%'
                        : '${NumberFormatter.clean(voucher.discountValue)}đ'
                ),

                _buildInfoRow(
                  'Số lượng còn lại',
                  voucher.quantity.toString(),
                ),

                _buildInfoRow(
                  'Ngày bắt đầu',
                  DateFormatter.ddMMyyyy(
                    voucher.startDate,
                  ),
                ),
                _buildInfoRow(
                  'Ngày kết thúc',
                  DateFormatter.ddMMyyyy(
                    voucher.endDate,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
      String title,
      String value,
      ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}