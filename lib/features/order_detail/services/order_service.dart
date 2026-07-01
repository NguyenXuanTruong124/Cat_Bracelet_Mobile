import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import '../../../config/api_config.dart';
import '../../../core/services/api_helpers.dart';
import '../models/order_detail_model.dart';

class OrderService {
  Future<OrderDetailModel> getOrderDetail(
    BuildContext context,
    String orderId,
  ) async {
    final baseUrl = ApiConfig.getBaseUrl(context);

    final response = await apiGet(Uri.parse('$baseUrl/orders/$orderId'));

    if (response.statusCode != 200) {
      throw Exception('Không thể tải đơn hàng');
    }

    final json = jsonDecode(response.body);
    final data = asStringMap(json['data']) ?? asStringMap(json) ?? {};

    return OrderDetailModel.fromJson(data);
  }
}
