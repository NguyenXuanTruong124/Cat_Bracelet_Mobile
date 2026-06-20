import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

import '../../voucher/models/voucher_model.dart';
import '../../voucher/services/voucher_service.dart';
import '../../voucher/widgets/voucher_card.dart';
import '../../voucher/screens/voucher_detail_screen.dart';

class HomeVoucherSection extends StatefulWidget {
  const HomeVoucherSection({super.key});

  @override
  State<HomeVoucherSection> createState() =>
      _HomeVoucherSectionState();
}

class _HomeVoucherSectionState extends State<HomeVoucherSection> {
  static const Color _wine = AppColors.wine;

  final VoucherService _voucherService =
  VoucherService();

  List<VoucherModel> _vouchers = [];

  @override
  void initState() {
    super.initState();
    _fetchVouchers();
  }

  Future<void> _fetchVouchers() async {
    try {
      final vouchers =
      await _voucherService.getVouchers(context);

      if (!mounted) return;

      setState(() {
        _vouchers = vouchers.take(2).toList();
      });
    } catch (e) {
      debugPrint(
        'Lỗi tải voucher: $e',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_vouchers.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      color: const Color(0xFFFFFAEF),
      padding: const EdgeInsets.fromLTRB(16, 28, 16, 16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.local_activity, color: _wine),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Ưu đãi đang có',
                      style: TextStyle(
                        color: _wine,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/vouchers'),
                    child: const Text('Xem tất cả'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ..._vouchers.map(
                    (voucher) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: VoucherCard(
                    voucher: voucher,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => VoucherDetailScreen(
                            voucher: voucher,
                          ),
                        ),
                      );
                    },
                  )
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


}