import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'app_user.dart';
import '../../../config/api_config.dart';
import '../../../core/services/api_helpers.dart';
class UserSession {
  static const _accessTokenKey = 'userSession.accessToken';
  static const _refreshTokenKey = 'userSession.refreshToken';
  static const _userJsonKey = 'userSession.user';

  static AppUser? currentUser;
  static String? accessToken;
  static String? refreshToken;

  static bool get isLoggedIn => currentUser != null && accessToken != null;

  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    accessToken = prefs.getString(_accessTokenKey);
    refreshToken = prefs.getString(_refreshTokenKey);

    final savedUserJson = prefs.getString(_userJsonKey);
    if (savedUserJson != null && savedUserJson.isNotEmpty) {
      try {
        final userMap = jsonDecode(savedUserJson);
        if (userMap is Map<String, dynamic>) {
          currentUser = AppUser.fromJson(userMap);
        }
      } catch (_) {
        currentUser = null;
      }
    }
  }

  static Future<void> setFromLogin(Map<String, dynamic> json) async {
    final userJson = json['user'];
    if (userJson is Map<String, dynamic>) {
      currentUser = AppUser.fromJson(userJson);
    }
    accessToken = json['accessToken']?.toString();
    refreshToken = json['refreshToken']?.toString();

    final prefs = await SharedPreferences.getInstance();
    if (accessToken != null) {
      await prefs.setString(_accessTokenKey, accessToken!);
    }
    if (refreshToken != null) {
      await prefs.setString(_refreshTokenKey, refreshToken!);
    }
    if (currentUser != null) {
      await prefs.setString(_userJsonKey, jsonEncode(currentUser!.toJson()));
    }
  }

  static Future<void> setCurrentUser(AppUser? user) async {
    currentUser = user;
    final prefs = await SharedPreferences.getInstance();
    if (user == null) {
      await prefs.remove(_userJsonKey);
      return;
    }
    await prefs.setString(_userJsonKey, jsonEncode(user.toJson()));
  }

  static Future<void> clear() async {
    currentUser = null;
    accessToken = null;
    refreshToken = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_userJsonKey);
  }

  static Future<void> updateTokens({
    String? accessToken,
    String? refreshToken,
  }) async {
    if (accessToken != null) {
      UserSession.accessToken = accessToken;
    }
    if (refreshToken != null) {
      UserSession.refreshToken = refreshToken;
    }

    final prefs = await SharedPreferences.getInstance();
    if (accessToken != null) {
      await prefs.setString(_accessTokenKey, accessToken);
    }
    if (refreshToken != null) {
      await prefs.setString(_refreshTokenKey, refreshToken);
    }
  }

  static Future<bool> refreshTokens() async {
    final refreshToken = UserSession.refreshToken;
    if (refreshToken == null || refreshToken.isEmpty) {
      return false;
    }

    final baseUrl = ApiConfig.cleanBaseUrl;
    if (baseUrl.isEmpty) {
      return false;
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/user/refresh-token'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      );

      if (response.statusCode != 200) {
        await clear();
        return false;
      }

      final decoded = jsonDecode(response.body);
      var tokenData = decoded;
      if (decoded is Map<String, dynamic>) {
        if (decoded['data'] is Map<String, dynamic>) {
          tokenData = decoded['data'] as Map<String, dynamic>;
        } else if (decoded['data'] is List && decoded['data'].isNotEmpty) {
          final firstElement = decoded['data'][0];
          if (firstElement is Map<String, dynamic>) {
            tokenData = firstElement;
          }
        }
      }

      final newAccessToken =
          tokenData['accessToken']?.toString() ??
          tokenData['access_token']?.toString();
      final newRefreshToken =
          tokenData['refreshToken']?.toString() ??
          tokenData['refresh_token']?.toString();

      if (newAccessToken == null || newRefreshToken == null) {
        debugPrint('DEBUG: Token refresh payload invalid: $tokenData');
        return false;
      }

      await updateTokens(
        accessToken: newAccessToken,
        refreshToken: newRefreshToken,
      );

      return true;
    } catch (error) {
      await clear();
      return false;
    }
  }
  static Future<bool> refreshCurrentUser() async {
    if (currentUser == null) return false;

    final baseUrl = ApiConfig.cleanBaseUrl;
    if (baseUrl.isEmpty) return false;

    try {
      final response = await apiGet(
        Uri.parse('$baseUrl/user/profile/${currentUser!.id}'),
      );

      if (response.statusCode != 200) {
        return false;
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        return false;
      }

      final user = AppUser.fromJson(decoded);

      await setCurrentUser(user);

      return true;
    } catch (_) {
      return false;
    }
  }
}
