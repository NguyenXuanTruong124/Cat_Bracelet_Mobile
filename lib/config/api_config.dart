import 'package:flutter/material.dart';

class ApiConfig {
  static String getBaseUrl(BuildContext context) {
    String baseUrl = 'http://localhost:3000';
    try {
      if (Theme.of(context).platform == TargetPlatform.android) {
        baseUrl = 'http://10.0.2.2:3000';
      }
    } catch (_) {}
    return baseUrl;
  }
}
