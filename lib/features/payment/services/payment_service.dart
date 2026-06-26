import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../config/api_config.dart';
import '../../../core/services/api_helpers.dart';
import '../models/payment.dart';
import '../models/payment_status.dart';

class PaymentService {
  Future<Payment> createPayment(BuildContext context, String orderId) async {
    final baseUrl = ApiConfig.getBaseUrl(context);

    final response = await http.post(
      Uri.parse('$baseUrl/api/payment/create'),
      headers: apiHeaders(json: true),
      body: jsonEncode({
        'orderId': orderId,
        'returnUrl': ApiConfig.getPayOsReturnUrl(context),
        'cancelUrl': ApiConfig.getPayOsCancelUrl(context),
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return Payment.fromJson(data);
    }

    throw Exception(data['message'] ?? 'Tạo link thanh toán thất bại');
  }

  Future<Payment> retryPayment(BuildContext context, String orderId) async {
    final baseUrl = ApiConfig.getBaseUrl(context);

    final response = await http.post(
      Uri.parse('$baseUrl/api/payment/retry'),
      headers: apiHeaders(json: true),
      body: jsonEncode({'orderId': orderId}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return Payment.fromJson(data);
    }

    throw Exception(data['message'] ?? 'Tạo lại link thanh toán thất bại');
  }

  Future<PaymentStatusModel> getStatus(
    BuildContext context,
    int orderCode,
  ) async {
    final baseUrl = ApiConfig.getBaseUrl(context);

    final response = await http.get(
      Uri.parse('$baseUrl/api/payment/status/$orderCode'),
      headers: apiHeaders(),
    );

    debugPrint('PAYMENT STATUS CODE: ${response.statusCode}');

    debugPrint('PAYMENT STATUS BODY: ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return PaymentStatusModel.fromJson(jsonDecode(response.body));
    }

    throw Exception('Không lấy được trạng thái thanh toán');
  }

  Future<Map<String, dynamic>> getInfo(
    BuildContext context,
    int orderCode,
  ) async {
    final baseUrl = ApiConfig.getBaseUrl(context);

    final response = await http.get(
      Uri.parse('$baseUrl/api/payment/info/$orderCode'),
      headers: apiHeaders(),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    throw Exception('Không lấy được thông tin thanh toán');
  }
}
