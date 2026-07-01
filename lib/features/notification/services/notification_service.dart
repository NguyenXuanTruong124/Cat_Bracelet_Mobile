import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../core/services/api_helpers.dart';
import '/config/api_config.dart';
import '../models/notification_model.dart';

class NotificationService {
  final BuildContext context;

  NotificationService(this.context);

  String get _baseUrl => ApiConfig.getBaseUrl(context);

  Future<List<NotificationModel>> getNotifications() async {
    try {
      final response = await apiGet(
        Uri.parse('$_baseUrl/notifications'),
        json: true,
      );

      if (response.statusCode != 200) {
        throw Exception('Load notifications failed');
      }

      final data = jsonDecode(response.body);

      return (data as List).map((e) => NotificationModel.fromJson(e)).toList();
    } catch (e) {
      debugPrint('getNotifications error: $e');
      return [];
    }
  }

  Future<int> getUnreadCount() async {
    try {
      final response = await apiGet(
        Uri.parse('$_baseUrl/notifications/unread-count'),
        json: true,
      );

      if (response.statusCode != 200) {
        return 0;
      }

      final data = jsonDecode(response.body);

      if (data is int) {
        return data;
      }

      if (data is Map && data['count'] != null) {
        return data['count'];
      }

      return 0;
    } catch (e) {
      debugPrint('getUnreadCount error: $e');
      return 0;
    }
  }

  Future<bool> markAsRead(String notificationId) async {
    try {
      final response = await apiPatch(
        Uri.parse('$_baseUrl/notifications/$notificationId/read'),
        json: true,
      );

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      debugPrint('markAsRead error: $e');
      return false;
    }
  }
}
