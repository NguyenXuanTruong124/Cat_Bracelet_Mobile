import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/services/api_helpers.dart';
import '../../../core/theme/app_colors.dart';

import '../../../core/widgets/app_notification.dart';
import '../models/order_detail_model.dart';
import '../services/order_service.dart';

import '../widgets/order_header_card.dart';
import '../widgets/order_product_card.dart';
import '../widgets/retry_payment_button.dart';
import '../widgets/shipping_address_card.dart';

class OrderDetailScreen extends StatefulWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final OrderService _orderService = OrderService();

  OrderDetailModel? _order;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    print('ORDER ID = ${widget.orderId}');
    _loadOrder();
  }

  Future<void> _loadOrder() async {
    try {
      final order = await _orderService.getOrderDetail(context, widget.orderId);

      if (!mounted) return;

      setState(() {
        _order = order;
      });
    } catch (e) {
      debugPrint('ERROR: $e');

      if (!mounted) return;

      AppNotification.showError(
        context: context,
        message: 'Không thể tải thông tin đơn hàng',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _price(dynamic value) {
    return NumberFormat.currency(
      locale: 'vi_VN',
      symbol: 'đ',
    ).format(toDouble(value));
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    final order = _order;

    if (order == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('CHI TIẾT ĐƠN HÀNG'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: Text('Không tải được đơn hàng')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'CHI TIẾT ĐƠN HÀNG',
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
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _loadOrder,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            OrderHeaderCard(
              orderId: order.id,
              paymentStatus: order.paymentStatus,
              totalPrice: _price(order.totalAmount),
            ),

            if (order.canRetryPayment) ...[
              const SizedBox(height: 16),

              RetryPaymentButton(
                orderId: order.id,

                onSuccess: () {},

                onError: (message) {
                  AppNotification.showError(context: context, message: message);
                },
              ),
            ],

            if (order.address != null) ...[
              const SizedBox(height: 20),

              const Text(
                'ĐỊA CHỈ NHẬN HÀNG',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),

              const SizedBox(height: 8),

              ShippingAddressCard(address: order.address!),
            ],

            const SizedBox(height: 20),

            const Text(
              'SẢN PHẨM',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),

            const SizedBox(height: 8),

            ...order.items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: OrderProductCard(
                  productName: item.productName,
                  color: item.color,
                  size: item.size,
                  quantity: item.quantity,
                  totalPrice: _price(item.totalPrice),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
