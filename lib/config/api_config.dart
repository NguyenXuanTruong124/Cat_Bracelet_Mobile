import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  static String getBaseUrl(BuildContext context) {
    String baseUrl = dotenv.env['BASE_URL'] ?? '';
    try {
      if (Theme.of(context).platform == TargetPlatform.android) {
        dotenv.env['BASE_URL'];
      }
    } catch (_) {}
    return baseUrl;
  }

  static String getPayOsReturnUrl(BuildContext context) {
    return dotenv.env['PAYOS_RETURN_URL'] ?? getBaseUrl(context);
  }

  static String getPayOsCancelUrl(BuildContext context) {
    return dotenv.env['PAYOS_CANCEL_URL'] ?? getBaseUrl(context);
  }
}
