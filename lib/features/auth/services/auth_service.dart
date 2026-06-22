import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../../../config/api_config.dart';

class AuthService {
  final BuildContext context;
  AuthService(this.context);

  Future<http.Response> login(String email, String password) async {
    final baseUrl = ApiConfig.getBaseUrl(context);
    final url = Uri.parse('$baseUrl/user/login');
    return await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
  }

  Future<http.Response> register({
    required String email,
    required String fullName,
    required String password,
    String? phone,
  }) async {
    final baseUrl = ApiConfig.getBaseUrl(context);
    final url = Uri.parse('$baseUrl/user/register');
    
    final Map<String, dynamic> body = {
      'email': email,
      'fullName': fullName,
      'password': password,
    };
    if (phone != null && phone.isNotEmpty) {
      body['phone'] = phone;
    }

    return await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
  }

  Future<http.Response> verifyOtp(String email, String otp) async {
    final baseUrl = ApiConfig.getBaseUrl(context);
    final url = Uri.parse('$baseUrl/user/verify-otp');
    return await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'otp': otp}),
    );
  }

  Future<http.Response> requestPasswordReset(String email) async {
    final baseUrl = ApiConfig.getBaseUrl(context);
    final url = Uri.parse('$baseUrl/user/request-password-reset');
    return await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );
  }

  Future<http.Response> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    final baseUrl = ApiConfig.getBaseUrl(context);
    final url = Uri.parse('$baseUrl/user/reset-password');
    return await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'otp': otp,
        'newPassword': newPassword,
      }),
    );
  }
}
