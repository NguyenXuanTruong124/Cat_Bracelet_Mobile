import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../config/api_config.dart';
import '../../profile/models/user_session.dart';
import '../../../core/services/api_helpers.dart';
import '../../../core/theme/app_colors.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  List<dynamic> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    final user = UserSession.currentUser;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final baseUrl = ApiConfig.getBaseUrl(context);
      final response = await http.get(
        Uri.parse('$baseUrl/orders/user/${user.id}'),
        headers: apiHeaders(),
      );
      if (response.statusCode == 200) {
        _orders = decodeListPayload(jsonDecode(response.body));

        _orders.sort((a, b) {
          final dateA = DateTime.tryParse(
            a['createdAt']?.toString() ?? '',
          ) ??
              DateTime(1970);

          final dateB = DateTime.tryParse(
            b['createdAt']?.toString() ?? '',
          ) ??
              DateTime(1970);

          return dateB.compareTo(dateA);
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _price(dynamic value) {
    return NumberFormat.currency(locale: 'vi_VN', symbol: 'đ')
        .format(toDouble(value));
  }

  String _statusLabel(String? status) {
    switch ((status ?? '').toUpperCase()) {
      case 'PENDING':
        return 'Chờ xác nhận';
      case 'CONFIRMED':
        return 'Đã xác nhận';
      case 'SHIPPING':
      case 'SHIPPED':
        return 'Đang vận chuyển';
      case 'DELIVERED':
      case 'COMPLETED':
        return 'Đã giao';
      case 'CANCELLED':
        return 'Đã hủy';
      default:
        return status ?? '';
    }
  }

  Color _statusColor(String? status) {
    switch ((status ?? '').toUpperCase()) {
      case 'PENDING':
        return AppColors.secondary;
      case 'CONFIRMED':
        return AppColors.primaryContainer;
      case 'CANCELLED':
        return const Color(0xFFBA1A1A);
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'ĐƠN HÀNG',
          style: TextStyle(
            fontFamily: 'serif',
            letterSpacing: 2,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : _orders.isEmpty
          ? const Center(child: Text('Chưa có đơn hàng'))
          : RefreshIndicator(
              color: AppColors.primary,
              onRefresh: _fetchOrders,
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _orders.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final order = _orders[index] as Map<String, dynamic>;
                  final orderId = order['id']?.toString() ?? '';
                  final shortId = orderId.length > 8
                      ? orderId.substring(0, 8).toUpperCase()
                      : orderId;
                  final status = order['status']?.toString();

                  return Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => Navigator.pushNamed(
                        context,
                        '/order-tracking',
                        arguments: orderId,

                      ),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.outlineVariant.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainer,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.receipt_long,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Đơn $shortId',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    DateFormatter.ddMMyyyy(

                                        order['createdAt']?.toString() ?? '',

                                    ),
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _statusColor(status)
                                          .withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      _statusLabel(status),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: _statusColor(status),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                  Text(
                                    _price(order['totalAmount']),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Theo dõi',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.secondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
