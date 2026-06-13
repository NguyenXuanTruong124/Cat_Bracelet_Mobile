import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../config/api_config.dart';
import '../models/user_session.dart';
import '../services/api_helpers.dart';
import 'order_detail_screen.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  static const Color _wine = Color(0xFF902021);

  List<dynamic> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    final user = UserSession.currentUser;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final baseUrl = ApiConfig.getBaseUrl(context);
      final response = await http.get(
        Uri.parse('$baseUrl/orders/user/${user.id}'),
        headers: apiHeaders(),
      );
      if (response.statusCode == 200) {
        _orders = decodeListPayload(jsonDecode(response.body));
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lich su don hang'),
        backgroundColor: _wine,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _wine))
          : _orders.isEmpty
          ? const Center(child: Text('Chua co don hang'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _orders.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final order = _orders[index] as Map<String, dynamic>;
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.receipt_long),
                    title: Text('Don #${order['id']}'),
                    subtitle: Text(
                      'Trang thai: ${order['status'] ?? ''}\n${order['createdAt'] ?? ''}',
                    ),
                    trailing: Text(_price(order['totalAmount'])),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OrderDetailScreen(
                            orderId: order['id'].toString(),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
