import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '/config/api_config.dart';
import '../../../core/services/api_helpers.dart';

class AddressService {
  static Future<List<Map<String, dynamic>>> fetchAddresses(
      BuildContext context,
      String userId,
      ) async {
    final baseUrl = ApiConfig.getBaseUrl(context);

    final response = await http.get(
      Uri.parse('$baseUrl/user-address/$userId'),
      headers: apiHeaders(),
    );

    if (response.statusCode != 200) {
      return [];
    }

    return decodeListPayload(jsonDecode(response.body))
        .whereType<Map<String, dynamic>>()
        .where(
          (a) => (a['status'] ?? '').toString().toUpperCase() == 'ACTIVE',
    )
        .toList();
  }

  static Future<bool> setDefaultAddress(
      BuildContext context,
      String userId,
      String addressId,
      ) async {
    final baseUrl = ApiConfig.getBaseUrl(context);

    final response = await http.patch(
      Uri.parse('$baseUrl/user-address/$userId/$addressId/default'),
      headers: apiHeaders(json: true),
    );

    return response.statusCode == 200;
  }

  static Future<bool> deleteAddress(
      BuildContext context,
      String userId,
      String addressId,
      ) async {
    final baseUrl = ApiConfig.getBaseUrl(context);

    final response = await http.delete(
      Uri.parse('$baseUrl/user-address/$userId/$addressId'),
      headers: apiHeaders(),
    );

    return response.statusCode == 200;
  }

  static Future<List<Map<String, dynamic>>> getProvinces(
      BuildContext context,
      ) async {
    final baseUrl = ApiConfig.getBaseUrl(context);

    final response = await http.get(
      Uri.parse('$baseUrl/shipments/provinces'),
    );

    if (response.statusCode != 200) return [];

    return decodeListPayload(jsonDecode(response.body))
        .whereType<Map<String, dynamic>>()
        .toList();
  }

  static Future<List<Map<String, dynamic>>> getDistricts(
      BuildContext context,
      String provinceId,
      ) async {
    final baseUrl = ApiConfig.getBaseUrl(context);

    final response = await http.get(
      Uri.parse('$baseUrl/shipments/districts/$provinceId'),
    );

    if (response.statusCode != 200) return [];

    return decodeListPayload(jsonDecode(response.body))
        .whereType<Map<String, dynamic>>()
        .toList();
  }

  static Future<List<Map<String, dynamic>>> getWards(
      BuildContext context,
      String districtId,
      ) async {
    final baseUrl = ApiConfig.getBaseUrl(context);

    final response = await http.get(
      Uri.parse('$baseUrl/shipments/wards/$districtId'),
    );

    if (response.statusCode != 200) return [];

    return decodeListPayload(jsonDecode(response.body))
        .whereType<Map<String, dynamic>>()
        .toList();
  }

  static Future<http.Response> createAddress(
      BuildContext context,
      String userId,
      String body,
      ) async {
    final baseUrl = ApiConfig.getBaseUrl(context);

    return http.post(
      Uri.parse('$baseUrl/user-address/$userId'),
      headers: apiHeaders(json: true),
      body: body,
    );
  }

  static Future<http.Response> updateAddress(
      BuildContext context,
      String userId,
      String addressId,
      String body,
      ) async {
    final baseUrl = ApiConfig.getBaseUrl(context);

    return http.patch(
      Uri.parse('$baseUrl/user-address/$userId/$addressId'),
      headers: apiHeaders(json: true),
      body: body,
    );
  }
}