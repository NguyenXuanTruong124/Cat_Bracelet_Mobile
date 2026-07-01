import 'dart:convert';
import '../../../config/api_config.dart';
import '../../../core/services/api_helpers.dart';
import 'package:flutter/material.dart';

class CartService {
  final BuildContext context;
  CartService(this.context);

  Future<Map<String, dynamic>?> fetchCart() async {
    final baseUrl = ApiConfig.getBaseUrl(context);
    final response = await apiGet(Uri.parse('$baseUrl/cart'));
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) return decoded;
    }
    return null;
  }

  Future<void> updateQuantity(String id, int quantity) async {
    final baseUrl = ApiConfig.getBaseUrl(context);

    if (quantity <= 0) {
      await apiDelete(Uri.parse('$baseUrl/cart/item/$id'));
      return;
    }

    await apiPatch(
      Uri.parse('$baseUrl/cart/item/$id'),
      json: true,
      body: jsonEncode({'quantity': quantity}),
    );
  }

  Future<void> removeItem(String id) async {
    final baseUrl = ApiConfig.getBaseUrl(context);
    await apiDelete(Uri.parse('$baseUrl/cart/item/$id'));
  }

  Future<void> clearCart() async {
    final baseUrl = ApiConfig.getBaseUrl(context);
    await apiDelete(Uri.parse('$baseUrl/cart/clear'));
  }
}
