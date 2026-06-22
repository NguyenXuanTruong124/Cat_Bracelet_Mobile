import 'dart:async';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../core/widgets/app_notification.dart';
import '../services/payment_service.dart';

class PayOsWebViewScreen extends StatefulWidget {
  final String checkoutUrl;
  final int orderCode;

  const PayOsWebViewScreen({
    super.key,
    required this.checkoutUrl,
    required this.orderCode,
  });

  @override
  State<PayOsWebViewScreen> createState() => _PayOsWebViewScreenState();
}

class _PayOsWebViewScreenState extends State<PayOsWebViewScreen> {
  late final WebViewController _controller;
  Timer? _paymentTimer;
  final PaymentService _paymentService = PaymentService();

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.checkoutUrl));

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
      final paymentStatus = await _paymentService.getStatus(
        context,
        widget.orderCode,
      );
      debugPrint('PAYMENT STATUS = ${paymentStatus.paymentStatus}');
      if (!paymentStatus.isPaid) {
        return;
      }

      _paymentTimer?.cancel();

      if (!mounted) {
        return;
      }

      AppNotification.showSuccess(
        context: context,
        message: 'Thanh toán thành công',
      );

      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    } catch (e) {
      debugPrint('CHECK PAYMENT ERROR: $e');
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
      appBar: AppBar(title: const Text('Thanh toán PayOS')),
      body: WebViewWidget(controller: _controller),
    );
  }
}
