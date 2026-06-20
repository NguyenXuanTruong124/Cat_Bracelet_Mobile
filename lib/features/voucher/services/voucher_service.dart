import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../config/api_config.dart';
import '../../../core/services/api_helpers.dart';
import '../models/voucher_model.dart';

class VoucherService {
  Future<List<VoucherModel>> getVouchers(BuildContext context) async {
    final baseUrl = ApiConfig.getBaseUrl(context);

    final response = await http.get(
      Uri.parse('$baseUrl/vouchers'),
    );

    if (response.statusCode != 200) {
      throw Exception('Không tải được voucher');
    }

    final data = decodeListPayload(
      jsonDecode(response.body),
    );

    return data
        .whereType<Map<String, dynamic>>()
        .map((e) => VoucherModel.fromJson(e))
        .where(
          (voucher) =>
      voucher.status.toLowerCase() == 'active',
    )
        .toList();
  }
}