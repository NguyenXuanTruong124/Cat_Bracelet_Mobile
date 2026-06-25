import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../config/api_config.dart';
import '../../../core/services/api_helpers.dart';
import 'package:flutter/material.dart';

class CartService {
  final BuildContext context;
  CartService(this.context);

  Future<Map<String, dynamic>?> fetchCart() async {
    final baseUrl = ApiConfig.getBaseUrl(context);
    final response = await http.get(
      Uri.parse('$baseUrl/cart'),
      headers: apiHeaders(),
    );
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) return decoded;
    }
    return null;
  }

  Future<void> updateQuantity(String id, int quantity) async {
    final baseUrl = ApiConfig.getBaseUrl(context);

    if (quantity <= 0) {
      await http.delete(
        Uri.parse('$baseUrl/cart/item/$id'),
        headers: apiHeaders(),
      );
      return;
    }

    await http.patch(
      Uri.parse('$baseUrl/cart/item/$id'),
      headers: apiHeaders(json: true),
      body: jsonEncode({'quantity': quantity}),
    );
  }

  Future<void> removeItem(String id) async {
    final baseUrl = ApiConfig.getBaseUrl(context);
    await http.delete(
      Uri.parse('$baseUrl/cart/item/$id'),
      headers: apiHeaders(),
    );
  }

  Future<void> clearCart() async {
    final baseUrl = ApiConfig.getBaseUrl(context);
    await http.delete(
      Uri.parse('$baseUrl/cart/clear'),
      headers: apiHeaders(),
    );
  }

}
