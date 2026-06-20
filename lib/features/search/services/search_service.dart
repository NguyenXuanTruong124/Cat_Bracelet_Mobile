import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../config/api_config.dart';
import '../../../core/services/api_helpers.dart';
import '../../product/models/product.dart';

class SearchService {
  Future<List<Product>> getSuggestions(
      BuildContext context,
      ) async {
    final baseUrl = ApiConfig.getBaseUrl(context);

    final response = await http.get(
      Uri.parse('$baseUrl/products'),
    );

    if (response.statusCode != 200) {
      throw Exception('Không thể tải dữ liệu');
    }

    return decodeListPayload(
      jsonDecode(response.body),
    )
        .whereType<Map<String, dynamic>>()
        .map(Product.fromJson)
        .where(
          (product) =>
      product.status.toLowerCase() == 'active',
    )
        .take(5)
        .toList();
  }
}