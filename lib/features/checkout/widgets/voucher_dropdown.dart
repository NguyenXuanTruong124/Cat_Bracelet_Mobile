import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../voucher/models/voucher_model.dart';

class VoucherDropdown extends StatelessWidget {
  final List<VoucherModel> vouchers;
  final String? selectedCode;
  final ValueChanged<String?> onChanged;

  const VoucherDropdown({
    super.key,
    required this.vouchers,
    required this.selectedCode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: selectedCode,
      decoration: const InputDecoration(
        labelText: 'Chọn voucher',
        border: OutlineInputBorder(),
      ),
      items: [
        const DropdownMenuItem<String>(
          value: '',
          child: Text(
            'Không sử dụng voucher',
          ),
        ),

        ...vouchers.map(
              (voucher) {
            final discountValue =
                voucher.discountValue;

            if (voucher.discountType
                .toUpperCase() ==
                'PERCENT') {
              return DropdownMenuItem<String>(
                value: voucher.code,
                child: Text(
                  '${voucher.code} - Giảm ${_formatNumber(discountValue)}%',
                ),
              );
            }

            return DropdownMenuItem<String>(
              value: voucher.code,
              child: Text(
                '${voucher.code} - Giảm ${money(discountValue)}',
              ),
            );
          },
        ),
      ],
      onChanged: onChanged,
    );
  }

  String money(double value) {
    return NumberFormat.currency(
      locale: 'vi_VN',
      symbol: 'đ',
    ).format(value);
  }

  String _formatNumber(double value) {
    return value % 1 == 0
        ? value.toInt().toString()
        : value.toStringAsFixed(1);
  }
}