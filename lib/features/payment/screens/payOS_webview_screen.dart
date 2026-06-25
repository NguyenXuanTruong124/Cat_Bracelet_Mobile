import 'dart:async';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../config/api_config.dart';
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
  static const Set<String> _legacyPaymentReturnHosts = {
    'home.kaelvercula.me',
    'truongnguyen.me',
  };

  late final WebViewController _controller;
  Timer? _paymentTimer;
  bool _handlingCompletionRedirect = false;
  bool _checkingPaymentStatus = false;
  bool _waitingForPaymentConfirmation = false;
  final PaymentService _paymentService = PaymentService();

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            if (_isPaymentCompletionUrl(request.url)) {
              _handlePaymentCompletionRedirect();
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
          onPageStarted: (url) {
            if (_isPaymentCompletionUrl(url)) {
              _handlePaymentCompletionRedirect();
            }
          },
          onPageFinished: (url) {
            if (_isPaymentCompletionUrl(url)) {
              _handlePaymentCompletionRedirect();
            }
          },
          onWebResourceError: (error) {
            final url = error.url;
            debugPrint(
              'PAYMENT WEBVIEW ERROR: ${error.errorCode} ${error.description} $url',
            );

            if (url != null && _isPaymentCompletionUrl(url)) {
              _handlePaymentCompletionRedirect();
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.checkoutUrl));

    _startCheckingPayment();
  }

  bool _isPaymentCompletionUrl(String url) {
    final uri = Uri.tryParse(url);

    return (uri != null && _legacyPaymentReturnHosts.contains(uri.host)) ||
        _matchesConfiguredUrl(url, ApiConfig.getPayOsReturnUrl(context)) ||
        _matchesConfiguredUrl(url, ApiConfig.getPayOsCancelUrl(context));
  }

  void _handlePaymentCompletionRedirect() {
    if (_handlingCompletionRedirect) {
      return;
    }

    _handlingCompletionRedirect = true;
    if (mounted) {
      setState(() {
        _waitingForPaymentConfirmation = true;
      });
    }
    _controller.loadHtmlString('<html><body></body></html>');
    _checkPaymentStatus();
  }

  bool _matchesConfiguredUrl(String url, String configuredUrl) {
    final uri = Uri.tryParse(url);
    final configured = Uri.tryParse(configuredUrl);

    if (uri == null || configured == null) {
      return false;
    }

    if (uri.scheme != configured.scheme || uri.host != configured.host) {
      return false;
    }

    final configuredPath = configured.path.isEmpty ? '/' : configured.path;
    if (configuredPath == '/') {
      return true;
    }

    return uri.path.startsWith(configuredPath);
  }

  void _startCheckingPayment() {
    if (_paymentTimer?.isActive == true) {
      return;
    }

    _paymentTimer = Timer.periodic(
      const Duration(seconds: 3),
      (_) => _checkPaymentStatus(),
    );
  }

  Future<void> _checkPaymentStatus() async {
    if (_checkingPaymentStatus) {
      return;
    }

    _checkingPaymentStatus = true;
    try {
      final paymentStatus = await _paymentService.getStatus(
        context,
        widget.orderCode,
      );
      debugPrint('PAYMENT STATUS = ${paymentStatus.paymentStatus}');
      if (!paymentStatus.isPaid) {
        _startCheckingPayment();
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
    } finally {
      _checkingPaymentStatus = false;
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
      body: _waitingForPaymentConfirmation
          ? const _PaymentConfirmationView()
          : WebViewWidget(controller: _controller),
    );
  }
}

class _PaymentConfirmationView extends StatelessWidget {
  const _PaymentConfirmationView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Đang xác nhận thanh toán...',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            Text('Vui lòng chờ trong giây lát.', textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
