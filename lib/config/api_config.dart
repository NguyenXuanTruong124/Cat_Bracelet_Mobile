import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  static String getBaseUrl(BuildContext context) {
    String baseUrl =
        dotenv.env['BASE_URL'] ?? dotenv.env['url_base_BE'] ?? '';
    try {
      if (Theme.of(context).platform == TargetPlatform.android) {
        dotenv.env['BASE_URL'] ?? dotenv.env['url_base_BE'];
      }
    } catch (_) {}
    return baseUrl;
  }
}
