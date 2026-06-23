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
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Header Voucher
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: _wine,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: _wine.withOpacity(0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.local_offer_rounded,
                    color: Colors.white,
                    size: 50,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    voucher.code,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      voucher.discountType == 'PERCENT'
                          ? 'Giảm ${NumberFormatter.clean(voucher.discountValue)}%'
                          : 'Giảm ${NumberFormatter.clean(voucher.discountValue)}đ',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildInfoTile(
                      Icons.discount_outlined,
                      'Loại giảm giá',
                      voucher.discountType,
                    ),
                    _buildDivider(),

                    _buildInfoTile(
                      Icons.payments_outlined,
                      'Giá trị',
                      voucher.discountType == 'PERCENT'
                          ? '${NumberFormatter.clean(voucher.discountValue)}%'
                          : '${NumberFormatter.clean(voucher.discountValue)}đ',
                    ),
                    _buildDivider(),

                    _buildInfoTile(
                      Icons.inventory_2_outlined,
                      'Số lượng còn lại',
                      voucher.quantity.toString(),
                    ),
                    _buildDivider(),

                    _buildInfoTile(
                      Icons.calendar_today_outlined,
                      'Ngày bắt đầu',
                      DateFormatter.ddMMyyyy(
                        voucher.startDate,
                      ),
                    ),
                    _buildDivider(),

                    _buildInfoTile(
                      Icons.event_available_outlined,
                      'Ngày kết thúc',
                      DateFormatter.ddMMyyyy(
                        voucher.endDate,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Divider(height: 1),
    );
  }

  Widget _buildInfoTile(
      IconData icon,
      String title,
      String value,
      ) {
    return Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: const Color(0xFFF8E8E8),
          child: Icon(
            icon,
            color: _wine,
            size: 18,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ),
      ],
    );
  }
}