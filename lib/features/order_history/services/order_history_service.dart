import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../config/api_config.dart';
import '../../../core/services/api_helpers.dart';
import '../models/order_history_model.dart';

class OrderHistoryService {
  Future<List<OrderHistoryModel>> getOrders(
    BuildContext context,
    String userId,
  ) async {
    final baseUrl = ApiConfig.getBaseUrl(context);

    final response = await apiGet(Uri.parse('$baseUrl/orders/user/$userId'));

    if (response.statusCode != 200) {
      throw Exception('Không thể tải đơn hàng');
    }

    final data = decodeListPayload(jsonDecode(response.body));

    final orders = data
        .map<OrderHistoryModel>((e) => OrderHistoryModel.fromJson(e))
        .toList();

    orders.sort(
      (a, b) => (b.createdAt ?? DateTime(1970)).compareTo(
        a.createdAt ?? DateTime(1970),
      ),
    );

    return orders;
  }
}
