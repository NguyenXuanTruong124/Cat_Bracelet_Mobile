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

  static bool get isLoggedIn =>
      currentUser != null && (accessToken != null || refreshToken != null);

  static Map<String, dynamic> _extractSessionPayload(
    Map<String, dynamic> json,
  ) {
    final payload = <String, dynamic>{};

    final data = json['data'];
    if (data is Map) {
      for (final entry in data.entries) {
        payload[entry.key.toString()] = entry.value;
      }
    }

    for (final entry in json.entries) {
      payload.putIfAbsent(entry.key.toString(), () => entry.value);
    }

    return payload;
  }

  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    accessToken = prefs.getString(_accessTokenKey);
    refreshToken = prefs.getString(_refreshTokenKey);

    debugPrint(
      'SESSION_INIT: accessToken=${accessToken?.isNotEmpty == true ? "present" : "missing"}, refreshToken=${refreshToken?.isNotEmpty == true ? "present" : "missing"}',
    );

    final savedUserJson = prefs.getString(_userJsonKey);
    if (savedUserJson != null && savedUserJson.isNotEmpty) {
      try {
        final userMap = jsonDecode(savedUserJson);
        if (userMap is Map<String, dynamic>) {
          currentUser = AppUser.fromJson(userMap);
          debugPrint('SESSION_INIT: user restored for ${currentUser?.id}');
        }
      } catch (error) {
        currentUser = null;
        debugPrint('SESSION_INIT: failed to restore user -> $error');
      }
    } else {
      debugPrint('SESSION_INIT: no saved user found');
    }
  }

  static Future<void> setFromLogin(Map<String, dynamic> json) async {
    final payload = _extractSessionPayload(json);
    debugPrint('SESSION_LOGIN: payload received -> $payload');
    final userJson = payload['user'];
    if (userJson is Map) {
      currentUser = AppUser.fromJson(
        Map<String, dynamic>.from(userJson as Map<dynamic, dynamic>),
      );
    }

    final tokenData = payload['tokens'];
    if (tokenData is Map) {
      accessToken =
          tokenData['accessToken']?.toString() ??
          tokenData['access_token']?.toString();
      refreshToken =
          tokenData['refreshToken']?.toString() ??
          tokenData['refresh_token']?.toString();
    } else {
      accessToken =
          payload['accessToken']?.toString() ??
          payload['access_token']?.toString();
      refreshToken =
          payload['refreshToken']?.toString() ??
          payload['refresh_token']?.toString();
    }

    final prefs = await SharedPreferences.getInstance();
    if (accessToken != null && accessToken!.isNotEmpty) {
      await prefs.setString(_accessTokenKey, accessToken!);
    }
    if (refreshToken != null && refreshToken!.isNotEmpty) {
      await prefs.setString(_refreshTokenKey, refreshToken!);
    }
    if (currentUser != null) {
      await prefs.setString(_userJsonKey, jsonEncode(currentUser!.toJson()));
    }

    debugPrint(
      'SESSION_LOGIN: saved session -> user=${currentUser?.id}, accessToken=${accessToken?.isNotEmpty == true ? "present" : "missing"}, refreshToken=${refreshToken?.isNotEmpty == true ? "present" : "missing"}',
    );
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
    debugPrint('SESSION_CLEAR: clearing session');
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
    debugPrint('SESSION_REFRESH: starting refresh');
    if (refreshToken == null || refreshToken.isEmpty) {
      debugPrint('SESSION_REFRESH: missing refresh token');
      return false;
    }

    final baseUrl = ApiConfig.cleanBaseUrl;
    if (baseUrl.isEmpty) {
      debugPrint('SESSION_REFRESH: base URL is empty');
      return false;
    }

    try {
      debugPrint('SESSION_REFRESH: calling $baseUrl/user/refresh-token');
      final response = await http.post(
        Uri.parse('$baseUrl/user/refresh-token'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      );

      debugPrint(
        'SESSION_REFRESH: status=${response.statusCode}, body=${response.body}',
      );
      if (response.statusCode < 200 || response.statusCode >= 300) {
        debugPrint('SESSION_REFRESH: refresh failed with non-success status');
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
        debugPrint('SESSION_REFRESH: invalid payload -> $tokenData');
        return false;
      }

      await updateTokens(
        accessToken: newAccessToken,
        refreshToken: newRefreshToken,
      );

      debugPrint('SESSION_REFRESH: success');
      return true;
    } catch (error) {
      debugPrint('SESSION_REFRESH: exception -> $error');
      return false;
    }
  }

  static Future<bool> refreshCurrentUser() async {
    if (currentUser == null) {
      debugPrint('SESSION_PROFILE: no current user to refresh');
      return false;
    }

    final baseUrl = ApiConfig.cleanBaseUrl;
    if (baseUrl.isEmpty) {
      debugPrint('SESSION_PROFILE: base URL is empty');
      return false;
    }

    try {
      debugPrint('SESSION_PROFILE: fetching profile for ${currentUser!.id}');
      final response = await apiGet(
        Uri.parse('$baseUrl/user/profile/${currentUser!.id}'),
      );

      debugPrint(
        'SESSION_PROFILE: status=${response.statusCode}, body=${response.body}',
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

      debugPrint('SESSION_PROFILE: success');
      return true;
    } catch (error) {
      debugPrint('SESSION_PROFILE: exception -> $error');
      return false;
    }
  }
}
