import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../config/api_config.dart';
import '../../../core/services/api_helpers.dart';
import 'package:cat_bracelet_mobile/features/payment/model/payment.dart';
import 'package:cat_bracelet_mobile/features/payment/model/payment_status.dart';

class PaymentService {
  Future<Payment> createPayment(
      BuildContext context,
      String orderId,
      ) async {
    final baseUrl = ApiConfig.getBaseUrl(context);

    final response = await http.post(
      Uri.parse('$baseUrl/payment/create'),
      headers: apiHeaders(json: true),
      body: jsonEncode({
        'orderId': orderId,
      }),
    );

    final body = jsonDecode(response.body);

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return Payment.fromJson(body);
    }

    throw Exception(
      body['message'] ??
          'Tạo link thanh toán thất bại',
    );
  }

  Future<Payment> retryPayment(
      BuildContext context,
      String orderId,
      ) async {
    final baseUrl = ApiConfig.getBaseUrl(context);

    final response = await http.post(
      Uri.parse('$baseUrl/payment/retry'),
      headers: apiHeaders(json: true),
      body: jsonEncode({
        'orderId': orderId,
      }),
    );

    final body = jsonDecode(response.body);

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return Payment.fromJson(body);
    }

    throw Exception(
      body['message'] ??
          'Tạo lại link thanh toán thất bại',
    );
  }

  Future<PaymentStatusModel> getStatus(
      BuildContext context,
      int orderCode,
      ) async {
    final baseUrl = ApiConfig.getBaseUrl(context);

    final response = await http.get(
      Uri.parse(
        '$baseUrl/payment/status/$orderCode',
      ),
      headers: apiHeaders(),
    );

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return PaymentStatusModel.fromJson(
        jsonDecode(response.body),
      );
    }

    throw Exception(
      'Không lấy được trạng thái thanh toán',
    );
  }

  Future<Map<String, dynamic>> getInfo(
      BuildContext context,
      int orderCode,
      ) async {
    final baseUrl = ApiConfig.getBaseUrl(context);

    final response = await http.get(
      Uri.parse(
        '$baseUrl/payment/info/$orderCode',
      ),
      headers: apiHeaders(),
    );

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return jsonDecode(response.body)
      as Map<String, dynamic>;
    }

    throw Exception(
      'Không lấy được thông tin thanh toán',
    );
  }
}