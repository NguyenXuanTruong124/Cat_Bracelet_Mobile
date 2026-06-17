import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';

import '../../../core/config/api_config.dart';
import '../../../core/services/api_helpers.dart';

class PayOsWebViewScreen extends StatefulWidget {
  final String checkoutUrl;
  final int orderCode;

  const PayOsWebViewScreen({
    super.key,
    required this.checkoutUrl,
    required this.orderCode,
  });

  @override
  State<PayOsWebViewScreen> createState() =>
      _PayOsWebViewScreenState();
}

class _PayOsWebViewScreenState
    extends State<PayOsWebViewScreen> {
  late final WebViewController _controller;
  Timer? _paymentTimer;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(
        JavaScriptMode.unrestricted,
      )
      ..loadRequest(
        Uri.parse(widget.checkoutUrl),
      );

    _startCheckingPayment();
  }

  void _startCheckingPayment() {
    _paymentTimer = Timer.periodic(
      const Duration(seconds: 3),
          (_) => _checkPaymentStatus(),
    );
  }

  Future<void> _checkPaymentStatus() async {
    try {
      final baseUrl = ApiConfig.getBaseUrl(context);

      final response = await http.get(
        Uri.parse(
          '$baseUrl/api/payment/status/${widget.orderCode}',
        ),
        headers: apiHeaders(),
      );

      if (response.statusCode != 200) return;

      final data = jsonDecode(response.body);

      debugPrint(
        'PAYMENT STATUS: ${data['paymentStatus']}',
      );

      if (data['paymentStatus']
          ?.toString()
          .toUpperCase() ==
          'PAID') {
        _paymentTimer?.cancel();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thanh toán thành công'),
          ),
        );

        Navigator.pushNamedAndRemoveUntil(
          context,
          '/home',
              (route) => false,
        );
      }
    } catch (e) {
      debugPrint(
        'CHECK PAYMENT ERROR: $e',
      );
    }
  }

  @override
  void dispose() {
    _paymentTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thanh toán PayOS'),
      ),
      body: WebViewWidget(
        controller: _controller,
      ),
    );
  }
}