import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../../../config/api_config.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/api_helpers.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/services/payment_service.dart';

class OrderDetailScreen extends StatefulWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  static const Color _wine = AppColors.wine;

  Map<String, dynamic>? _order;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchOrder();
  }

  Future<void> _fetchOrder() async {
    if (mounted) {
      setState(() => _isLoading = true);
    }

    try {
      final baseUrl = ApiConfig.getBaseUrl(context);
      final response = await http.get(
        Uri.parse('$baseUrl/orders/${widget.orderId}'),
        headers: apiHeaders(),
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          _order = decoded;
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _price(dynamic value) {
    return NumberFormat.currency(
      locale: 'vi_VN',
      symbol: 'd',
    ).format(toDouble(value));
  }

  @override
  Widget build(BuildContext context) {
    final order = _order;
    final items = decodeListPayload(order?['items']);
    final address = order?['address'] as Map<String, dynamic>?;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết đơn hàng'),
        backgroundColor: _wine,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _wine))
          : order == null
          ? const Center(child: Text('Không tải được đơn hàng'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Đơn #${order['id']}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Chip(
                  label: Text(
                    order['paymentStatus'] ?? '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  backgroundColor: _paymentStatusColor(
                    order['paymentStatus'],
                  ),
                ),
                Text('Tổng tiền: ${_price(order['totalAmount'])}'),
                const SizedBox(height: 16),
                if (order['canRetryPayment'] == true)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () async {
                        try {
                          final payment =
                          await PaymentService().retryPayment(
                            context,
                            order['id'],
                          );

                          await launchUrl(
                            Uri.parse(payment.checkoutUrl),
                            mode: LaunchMode.externalApplication,
                          );

                        } catch (e) {
                          if (!mounted) return;

                          ScaffoldMessenger.of(context)
                              .showSnackBar(
                            SnackBar(
                              content: Text(e.toString()),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.payment),
                      label: const Text(
                        'THANH TOÁN LẠI',
                      ),
                    ),
                  ),
                if (address != null) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Địa chỉ nhận hàng',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${address['receiverName'] ?? ''} - ${address['phone'] ?? ''}\n${address['detailAddress'] ?? ''}, ${address['ward'] ?? ''}, ${address['district'] ?? ''}, ${address['province'] ?? ''}',
                  ),
                ],
                const SizedBox(height: 16),
                const Text(
                  'Sản phẩm',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...items.map((rawItem) {
                  final item = rawItem as Map<String, dynamic>;
                  final variant = item['variant'] as Map<String, dynamic>?;
                  final mappings =
                  variant?['productVariantMappings'] as List?;

                  final product =
                  mappings?.isNotEmpty == true
                      ? mappings!.first['product']
                      : null;

                  final productName =
                      product?['productName'] ??
                          'Sản phẩm';
                  return Card(
                    child: ListTile(
                      title: Text(productName),
                      subtitle: Text(
                        'Mau: ${variant?['color'] ?? ''}'
                            '\nSize: ${variant?['size'] ?? ''}'
                            '\nSố lượng: ${item['quantity'] ?? 0}',
                      ),
                      trailing: Text(_price(item['totalPrice'])),
                    ),
                  );
                }),
              ],
            ),
    );
  }
  Color _paymentStatusColor(String? status) {
    switch ((status ?? '').toUpperCase()) {
      case 'PAID':
        return Colors.green;

      case 'PENDING':
        return Colors.orange;

      case 'FAILED':
      case 'CANCELLED':
        return Colors.red;

      default:
        return Colors.grey;
    }
  }
}
