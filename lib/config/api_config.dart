import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  static String sanitizeUrl(String url) {
    var sanitized = url.trim();
    if (sanitized.length >= 2) {
      final first = sanitized[0];
      final last = sanitized[sanitized.length - 1];
      if ((first == "'" && last == "'") || (first == '"' && last == '"')) {
        sanitized = sanitized.substring(1, sanitized.length - 1);
      }
    }
    return sanitized;
  }

  static String get cleanBaseUrl {
    final baseUrl = dotenv.env['BASE_URL'] ?? '';
    return sanitizeUrl(baseUrl);
  }

  static String getBaseUrl(BuildContext context) {
    String baseUrl = dotenv.env['BASE_URL'] ?? '';
    baseUrl = sanitizeUrl(baseUrl);
    try {
      if (Theme.of(context).platform == TargetPlatform.android) {
        dotenv.env['BASE_URL'];
      }
    } catch (_) {}
    return baseUrl;
  }

  static String getPayOsReturnUrl(BuildContext context) {
    final rawUrl = dotenv.env['PAYOS_RETURN_URL'];
    return rawUrl != null ? sanitizeUrl(rawUrl) : getBaseUrl(context);
  }

  static String getPayOsCancelUrl(BuildContext context) {
    final rawUrl = dotenv.env['PAYOS_CANCEL_URL'];
    return rawUrl != null ? sanitizeUrl(rawUrl) : getBaseUrl(context);
  }
}
