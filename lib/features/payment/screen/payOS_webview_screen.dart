import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PayOsWebViewScreen extends StatefulWidget {
  final String checkoutUrl;

  const PayOsWebViewScreen({
    super.key,
    required this.checkoutUrl,
  });

  @override
  State<PayOsWebViewScreen> createState() =>
      _PayOsWebViewScreenState();
}

class _PayOsWebViewScreenState
    extends State<PayOsWebViewScreen> {

  late final WebViewController _controller;

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