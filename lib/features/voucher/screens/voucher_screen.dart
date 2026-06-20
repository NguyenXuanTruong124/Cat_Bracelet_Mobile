import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../models/voucher_model.dart';
import '../services/voucher_service.dart';
import '../widgets/voucher_card.dart';
import 'voucher_detail_screen.dart';

class VoucherScreen extends StatefulWidget {
  const VoucherScreen({super.key});

  @override
  State<VoucherScreen> createState() =>
      _VoucherScreenState();
}

class _VoucherScreenState
    extends State<VoucherScreen> {
  static const Color _wine = AppColors.wine;
  static const Color _cream = Color(0xFFFFFAEF);

  final VoucherService _service = VoucherService();

  List<VoucherModel> vouchers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadVouchers();
  }

  Future<void> loadVouchers() async {
    try {
      vouchers = await _service.getVouchers(context);
    } catch (e) {
      debugPrint(e.toString());
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cream,
      appBar: AppBar(
        title: const Text('Voucher của tôi'),
        backgroundColor: _wine,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(
          color: _wine,
        ),
      )
          : ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: vouchers.length,
        separatorBuilder: (_, __) =>
        const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final voucher = vouchers[index];

          return VoucherCard(
            voucher: voucher,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      VoucherDetailScreen(
                        voucher: voucher,
                      ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}