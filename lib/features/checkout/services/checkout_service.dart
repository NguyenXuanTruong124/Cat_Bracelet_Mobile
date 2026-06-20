import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../config/api_config.dart';
import '../../../core/services/api_helpers.dart';
import '../../profile/models/user_session.dart';
import '../../voucher/models/voucher_model.dart';
import '../models/address_model.dart';

class CheckoutService {
  final BuildContext context;

  CheckoutService(this.context);

  Future<List<AddressModel>> fetchAddresses() async {
    final user = UserSession.currentUser;

    if (user == null) {
      return [];
    }

    final baseUrl = ApiConfig.getBaseUrl(context);

    final response = await http.get(
      Uri.parse('$baseUrl/user-address/${user.id}'),
      headers: apiHeaders(),
    );

    if (response.statusCode != 200) {
      return [];
    }

    final data = jsonDecode(response.body);

    return decodeListPayload(data)
        .whereType<Map<String, dynamic>>()
        .where(
          (e) =>
      (e['status'] ?? '')
          .toString()
          .toUpperCase() ==
          'ACTIVE',
    )
        .map(AddressModel.fromJson)
        .toList();
  }

  Future<List<VoucherModel>> fetchVouchers() async {
    final baseUrl = ApiConfig.getBaseUrl(context);

    final response = await http.get(
      Uri.parse('$baseUrl/vouchers'),
      headers: apiHeaders(),
    );

    if (response.statusCode != 200) {
      return [];
    }

    return decodeListPayload(
      jsonDecode(response.body),
    )
        .whereType<Map<String, dynamic>>()
        .where(
          (e) =>
      (e['status'] ?? '')
          .toString()
          .toUpperCase() ==
          'ACTIVE',
    )
        .map(VoucherModel.fromJson)
        .toList();
  }

  Future<double> calculateShippingFee(
      String addressId,
      ) async {
    final baseUrl = ApiConfig.getBaseUrl(context);

    final response = await http.post(
      Uri.parse(
        '$baseUrl/shipments/calculate-client',
      ),
      headers: apiHeaders(json: true),
      body: jsonEncode({
        'addressId': addressId,
      }),
    );

    if (response.statusCode != 200) {
      return 0;
    }

    final data = jsonDecode(response.body);

    return (data['total_shipping_fee'] as num?)
        ?.toDouble() ??
        0;
  }

  Future<String?> createAddress({
    required String receiver,
    required String phone,
    required String province,
    required String district,
    required String ward,
    required String detail,
    required bool isDefault,
  }) async {
    final user = UserSession.currentUser;

    if (user == null) {
      return null;
    }

    final baseUrl = ApiConfig.getBaseUrl(context);

    final response = await http.post(
      Uri.parse(
        '$baseUrl/user-address/${user.id}',
      ),
      headers: apiHeaders(json: true),
      body: jsonEncode({
        'receiverName': receiver,
        'phone': phone,
        'province': province,
        'district': district,
        'ward': ward,
        'detailAddress': detail,
        'isDefault': isDefault,
        'status': 'ACTIVE',
      }),
    );

    if (response.statusCode != 200 &&
        response.statusCode != 201) {
      return null;
    }

    final data =
    jsonDecode(response.body);

    return data['id']?.toString();
  }

  Future<Map<String, dynamic>?> checkout({
    required String userId,
    required String addressId,
    required String? voucherCode,
    required List<String> cartItemIds,
  }) async {
    final baseUrl = ApiConfig.getBaseUrl(context);

    final response = await http.post(
      Uri.parse(
        '$baseUrl/orders/checkout',
      ),
      headers: apiHeaders(json: true),
      body: jsonEncode({
        'userId': userId,
        'addressId': addressId,
        'voucherCode': voucherCode,
        'cartItemIds': cartItemIds,
      }),
    );

    if (response.statusCode != 200 &&
        response.statusCode != 201) {
      return null;
    }

    return jsonDecode(response.body)
    as Map<String, dynamic>;
  }
}