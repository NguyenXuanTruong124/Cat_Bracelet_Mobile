import 'package:cat_bracelet_mobile/config/api_config.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/api_helpers.dart';
import '../services/cart_service.dart';
import '../widgets/cart_item_card.dart';
import 'package:cat_bracelet_mobile/core/utils/price_formatter.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  static const Color _wine = AppColors.wine;
  Map<String, dynamic>? _cart;
  bool _isLoading = true;

  late CartService _cartService;

  @override
  void initState() {
    super.initState();
    _cartService = CartService(context);
    _fetchCart();
  }

  Future<void> _fetchCart() async {
    setState(() => _isLoading = true);
    final cart = await _cartService.fetchCart();
    if (mounted) {
      setState(() {
        _cart = cart;
        _isLoading = false;
      });
    }
  }

  Future<void> _updateQuantity(String id, int quantity) async {
    await _cartService.updateQuantity(id, quantity);
    _fetchCart();
  }

  Future<void> _removeItem(String id) async {
    await _cartService.removeItem(id);
    _fetchCart();
  }

  String _price(dynamic value) {
    return NumberFormat.currency(locale: 'vi_VN', symbol: 'đ')
        .format(toDouble(value));
  }

  @override
  Widget build(BuildContext context) {
    final items = decodeListPayload(_cart?['items']);
    final baseUrl = ApiConfig.getBaseUrl(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Giỏ hàng'),
        backgroundColor: _wine,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _wine))
          : items.isEmpty
          ? const Center(child: Text('Giỏ hàng đang trống'))
          : ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = items[index] as Map<String, dynamic>;
          return CartItemCard(
            item: item,
            baseUrl: baseUrl,
            onUpdateQuantity: _updateQuantity,
            onRemoveItem: _removeItem,
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Tổng: ${formatPrice(toInt(_cart?['totalPrice']))}', // 👈 dùng formatPrice
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                tooltip: 'Xóa hết giỏ hàng',
                onPressed: items.isEmpty
                    ? null
                    : () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Xác nhận'),
                      content: const Text('Bạn có thật sự muốn xóa hết giỏ hàng không?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(false),
                          child: const Text('Không'),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                          ),
                          onPressed: () => Navigator.of(ctx).pop(true),
                          child: const Text('Có'),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    await _cartService.clearCart();
                    _fetchCart();
                  }
                },
                icon: const Icon(Icons.delete_forever, color: Colors.redAccent),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _wine,
                  foregroundColor: Colors.white,
                ),
                onPressed: items.isEmpty
                    ? null
                    : () {
                  Navigator.pushNamed(
                    context,
                    '/checkout',
                    arguments: _cart,
                  );
                },
                icon: const Icon(Icons.payments),
                label: const Text('Đặt hàng'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
