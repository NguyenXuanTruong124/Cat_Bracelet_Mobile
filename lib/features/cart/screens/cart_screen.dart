import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../../../core/config/api_config.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/api_helpers.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  static const Color _wine = AppColors.wine;

  Map<String, dynamic>? _cart;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCart();
  }

  Future<void> _fetchCart() async {
    setState(() => _isLoading = true);
    try {
      final baseUrl = ApiConfig.getBaseUrl(context);
      final response = await http.get(
        Uri.parse('$baseUrl/cart'),
        headers: apiHeaders(),
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          _cart = decoded;
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _updateQuantity(String id, int quantity) async {
    if (quantity < 1) {
      return;
    }
    final baseUrl = ApiConfig.getBaseUrl(context);
    await http.patch(
      Uri.parse('$baseUrl/cart/item/$id'),
      headers: apiHeaders(json: true),
      body: jsonEncode({'quantity': quantity}),
    );
    _fetchCart();
  }

  Future<void> _removeItem(String id) async {
    final baseUrl = ApiConfig.getBaseUrl(context);
    await http.delete(
      Uri.parse('$baseUrl/cart/item/$id'),
      headers: apiHeaders(),
    );
    _fetchCart();
  }

  String _price(dynamic value) {
    return NumberFormat.currency(
      locale: 'vi_VN',
      symbol: 'd',
    ).format(toDouble(value));
  }

  @override
  Widget build(BuildContext context) {
    final items = decodeListPayload(_cart?['items']);
    final baseUrl = ApiConfig.getBaseUrl(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gio hang'),
        backgroundColor: _wine,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _wine))
          : items.isEmpty
          ? const Center(child: Text('Gio hang dang trong'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = items[index] as Map<String, dynamic>;
                final product = readProductPayload(item);
                final variant = asStringMap(
                  item['variantDetails'] ?? item['variant'],
                );
                final quantity = toInt(item['quantity']);
                final id = (item['cartItemId'] ?? item['id']).toString();
                final imageUrl = buildImageUrl(
                  baseUrl,
                  readThumbnailPath(product) ?? readThumbnailPath(item),
                );

                
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: SizedBox(
                            width: 72,
                            height: 72,
                            child: imageUrl.isEmpty
                                ? const ColoredBox(
                                    color: Color(0xFFFFF8F7),
                                    child: Icon(Icons.image_not_supported),
                                  )
                                : Image.network(imageUrl, fit: BoxFit.cover),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                (readStringField(product, const [
                                          'productName',
                                          'product_name',
                                          'name',
                                        ]) ??
                                        'San pham')
                                    .toString(),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${variant?['color'] ?? ''} ${variant?['size'] ?? ''}'
                                    .trim(),
                              ),
                              const SizedBox(height: 4),
                              Text(_price(item['subTotal'])),
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () =>
                                        _updateQuantity(id, quantity - 1),
                                    icon: const Icon(
                                      Icons.remove_circle_outline,
                                    ),
                                  ),
                                  Text('$quantity'),
                                  IconButton(
                                    onPressed: () =>
                                        _updateQuantity(id, quantity + 1),
                                    icon: const Icon(Icons.add_circle_outline),
                                  ),
                                  const Spacer(),
                                  IconButton(
                                    onPressed: () => _removeItem(id),
                                    icon: const Icon(Icons.delete_outline),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
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
                  'Tong: ${_price(_cart?['totalPrice'])}',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _wine,
                  foregroundColor: Colors.white,
                ),
                onPressed: items.isEmpty
                    ? null
                    : () {
                  final cartItemIds = items
                      .map<String>(
                        (e) => ((e as Map<String, dynamic>)['cartItemId'] ??
                        e['id'])
                        .toString(),
                  )
                      .toList();

                  Navigator.pushNamed(
                    context,
                    '/checkout',
                    arguments: cartItemIds,
                  );
                },
                icon: const Icon(Icons.payments),
                label: const Text('Dat hang'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
