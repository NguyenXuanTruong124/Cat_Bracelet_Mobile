import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'app_user.dart';

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
    if (userJson is Map<String, dynamic>) {
      await prefs.setString(_userJsonKey, jsonEncode(userJson));
    }
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
}
