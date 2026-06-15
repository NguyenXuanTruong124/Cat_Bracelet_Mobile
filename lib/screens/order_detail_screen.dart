import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../config/api_config.dart';
import '../services/api_helpers.dart';

class OrderDetailScreen extends StatefulWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  static const Color _wine = Color(0xFF902021);

  Map<String, dynamic>? _order;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchOrder();
  }

  Future<void> _fetchOrder() async {
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
    final baseUrl = ApiConfig.getBaseUrl(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiet don hang'),
        backgroundColor: _wine,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _wine))
          : order == null
          ? const Center(child: Text('Khong tai duoc don hang'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Don #${order['id']}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text('Trang thai: ${order['status'] ?? ''}'),
                Text('Tong tien: ${_price(order['totalAmount'])}'),
                if (address != null) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Dia chi giao hang',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${address['receiverName'] ?? ''} - ${address['phone'] ?? ''}\n${address['detailAddress'] ?? ''}, ${address['ward'] ?? ''}, ${address['district'] ?? ''}, ${address['province'] ?? ''}',
                  ),
                ],
                const SizedBox(height: 16),
                const Text(
                  'San pham',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...items.map((rawItem) {
                  final item = rawItem as Map<String, dynamic>;
                  final variant = asStringMap(item['variant']);
                  final product = readProductPayload(item);
                  final thumbnail = buildImageUrl(
                    baseUrl,
                    readThumbnailPath(product) ?? readThumbnailPath(item),
                  );
                  return Card(
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          width: 56,
                          height: 56,
                          child: thumbnail.isEmpty
                              ? const ColoredBox(
                                  color: Color(0xFFFFF8F7),
                                  child: Icon(Icons.image_not_supported),
                                )
                              : Image.network(
                                  thumbnail,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      const ColoredBox(
                                        color: Color(0xFFFFF8F7),
                                        child: Icon(Icons.image_not_supported),
                                      ),
                                ),
                        ),
                      ),
                      title: Text(
                        '${variant?['color'] ?? ''} ${variant?['size'] ?? ''}'
                                .trim()
                                .isEmpty
                            ? 'Bien the san pham'
                            : '${variant?['color'] ?? ''} ${variant?['size'] ?? ''}'
                                  .trim(),
                      ),
                      subtitle: Text('So luong: ${item['quantity'] ?? 0}'),
                      trailing: Text(_price(item['totalPrice'])),
                    ),
                  );
                }),
              ],
            ),
    );
  }
}
