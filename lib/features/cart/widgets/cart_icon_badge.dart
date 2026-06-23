import 'package:flutter/material.dart';

import '../../cart/services/cart_service.dart';

class CartIconBadge extends StatefulWidget {
  const CartIconBadge({
    super.key,
    this.iconColor = Colors.white,
  });

  final Color iconColor;

  @override
  State<CartIconBadge> createState() => _CartIconBadgeState();
}

class _CartIconBadgeState extends State<CartIconBadge> {
  late CartService _cartService;

  int _cartItemCount = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _cartService = CartService(context);
    _loadCartCount();
  }

  Future<void> _loadCartCount() async {
    try {
      final cart = await _cartService.fetchCart();

      if (!mounted || cart == null) return;

      setState(() {
        _cartItemCount =
            (cart['totalItems'] as num?)?.toInt() ?? 0;
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          tooltip: 'Giỏ hàng',
          onPressed: () async {
            await Navigator.pushNamed(
              context,
              '/cart',
            );

            _loadCartCount();
          },
          icon: Icon(
            Icons.shopping_cart_outlined,
            color: widget.iconColor,
          ),
        ),

        if (_cartItemCount > 0)
          Positioned(
            right: 6,
            top: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 5,
                vertical: 1,
              ),
              constraints: const BoxConstraints(
                minWidth: 18,
                minHeight: 18,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.red,
                ),
              ),
              child: Text(
                _cartItemCount > 99
                    ? '99+'
                    : _cartItemCount.toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}