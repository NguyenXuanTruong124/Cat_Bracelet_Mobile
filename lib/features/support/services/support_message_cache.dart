import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/support_message.dart';

class SupportMessageCache {
  static String _cacheKey(String ticketId) => 'support_messages_$ticketId';

  static Future<List<SupportMessage>> load(String ticketId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cacheKey(ticketId));
    if (raw == null || raw.isEmpty) {
      return [];
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return [];
      }

      return decoded
          .whereType<Map<String, dynamic>>()
          .map((item) => SupportMessage.fromJson(item))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> save(
    String ticketId,
    List<SupportMessage> messages,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = jsonEncode(
      messages.map((message) => message.toJson()).toList(),
    );
    await prefs.setString(_cacheKey(ticketId), payload);
  }

  static Future<void> clear(String ticketId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheKey(ticketId));
  }
}
