import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../services/api_helpers.dart';

class VoucherScreen extends StatefulWidget {
  const VoucherScreen({super.key});

  @override
  State<VoucherScreen> createState() => _VoucherScreenState();
}

class _VoucherScreenState extends State<VoucherScreen> {
  static const Color _wine = Color(0xFF902021);
  static const Color _gold = Color(0xFFDAB47D);
  static const Color _cream = Color(0xFFFFFAEF);

  List<dynamic> _vouchers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchVouchers();
  }

  Future<void> _fetchVouchers() async {
    try {
      final baseUrl = ApiConfig.getBaseUrl(context);
      final response = await http.get(Uri.parse('$baseUrl/vouchers'));
      if (response.statusCode == 200) {
        _vouchers = decodeListPayload(jsonDecode(response.body))
            .whereType<Map<String, dynamic>>()
            .where(
              (voucher) =>
                  (voucher['status'] ?? '').toString().toLowerCase() ==
                  'active',
            )
            .toList();
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cream,
      appBar: AppBar(
        title: const Text('Voucher cua toi'),
        backgroundColor: _wine,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _wine))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _vouchers.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return VoucherCard(voucher: _vouchers[index]);
              },
            ),
    );
  }
}

class VoucherCard extends StatelessWidget {
  final Map<String, dynamic> voucher;

  const VoucherCard({super.key, required this.voucher});

  static const Color _wine = Color(0xFF902021);
  static const Color _gold = Color(0xFFDAB47D);

  @override
  Widget build(BuildContext context) {
    final code = (voucher['code'] ?? '').toString();
    final discount = voucher['discountValue'] ?? voucher['discount_value'];
    final type = (voucher['discountType'] ?? voucher['discount_type'] ?? '')
        .toString();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _gold.withValues(alpha: 0.5)),
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
            child: const Icon(Icons.local_activity, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  code,
                  style: const TextStyle(
                    color: _wine,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  type == 'PERCENT'
                      ? 'Giam $discount%'
                      : 'Giam ${discount ?? 0}d',
                ),
                Text(
                  'Han dung: ${voucher['endDate'] ?? ''}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.black54),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward, color: _wine),
        ],
      ),
    );
  }
}
