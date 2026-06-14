import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/api_config.dart';
import '../services/api_helpers.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  static const Color _wine = Color(0xFF902021);

  Map<String, dynamic>? _order;
  String? _checkoutUrl;
  String? _result;
  bool _isRefreshing = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final raw = ModalRoute.of(context)?.settings.arguments;
    if (raw is Map<String, dynamic>) {
      final order = raw['order'];
      _order = order is Map<String, dynamic> ? order : raw;
      _checkoutUrl = raw['checkoutUrl']?.toString();
      _result = raw['result']?.toString();
    }
    _refreshOrder();
  }

  Future<void> _refreshOrder() async {
    final orderId = _orderId;
    if (orderId == null || orderId.isEmpty || _isRefreshing) {
      return;
    }

    setState(() => _isRefreshing = true);
    try {
      final baseUrl = ApiConfig.getBaseUrl(context);
      final response = await http.get(
        Uri.parse('$baseUrl/orders/$orderId'),
        headers: apiHeaders(),
      );
      if (response.statusCode == 200 && mounted) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          setState(() => _order = decoded);
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isRefreshing = false);
      }
    }
  }

  Future<void> _openPaymentLink() async {
    final checkoutUrl = _checkoutUrl;
    final uri = checkoutUrl == null ? null : Uri.tryParse(checkoutUrl);
    if (uri == null) {
      return;
    }

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  String? get _orderId =>
      (_order?['id'] ?? _order?['orderId'] ?? _order?['orderCode'])
          ?.toString();

  bool get _isPaid {
    final status = (_order?['status'] ?? _order?['paymentStatus'] ?? '')
        .toString()
        .toUpperCase();
    return ['PAID', 'COMPLETED', 'SUCCESS', 'SUCCEEDED'].contains(status);
  }

  bool get _isCanceled {
    final status = (_order?['status'] ?? _order?['paymentStatus'] ?? '')
        .toString()
        .toUpperCase();
    return _result == 'cancel' || ['CANCELLED', 'CANCELED'].contains(status);
  }

  IconData get _statusIcon {
    if (_isPaid) {
      return Icons.check_circle;
    }
    if (_isCanceled) {
      return Icons.cancel;
    }
    return Icons.hourglass_top;
  }

  Color get _statusColor {
    if (_isPaid) {
      return Colors.green;
    }
    if (_isCanceled) {
      return Colors.red;
    }
    return _wine;
  }

  String get _title {
    if (_isPaid) {
      return 'Thanh toan thanh cong';
    }
    if (_isCanceled) {
      return 'Thanh toan da huy';
    }
    return 'Dang cho thanh toan';
  }

  @override
  Widget build(BuildContext context) {
    final total = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: 'd',
    ).format(toDouble(_order?['totalAmount']));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thanh toan'),
        backgroundColor: _wine,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(_statusIcon, color: _statusColor, size: 72),
            const SizedBox(height: 16),
            Text(
              _title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Ma don: ${_orderId ?? 'N/A'}',
              textAlign: TextAlign.center,
            ),
            Text('Tong thanh toan: $total', textAlign: TextAlign.center),
            const SizedBox(height: 24),
            if (_checkoutUrl != null && !_isPaid) ...[
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _wine,
                  foregroundColor: Colors.white,
                ),
                onPressed: _openPaymentLink,
                icon: const Icon(Icons.open_in_new),
                label: const Text('Mo cong thanh toan PayOS'),
              ),
              const SizedBox(height: 12),
            ],
            OutlinedButton.icon(
              onPressed: _isRefreshing ? null : _refreshOrder,
              icon: _isRefreshing
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh),
              label: const Text('Kiem tra trang thai'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () =>
                  Navigator.pushReplacementNamed(context, '/orders'),
              icon: const Icon(Icons.receipt_long),
              label: const Text('Xem lich su don hang'),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: _wine,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pushNamedAndRemoveUntil(
                context,
                '/home',
                (route) => false,
              ),
              icon: const Icon(Icons.home),
              label: const Text('Ve trang chu'),
            ),
          ],
        ),
      ),
    );
  }
}
