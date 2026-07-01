import 'package:flutter/material.dart';

import '../../features/profile/models/user_session.dart';

class SessionManager {
  SessionManager._();

  static final navigatorKey = GlobalKey<NavigatorState>();

  static Future<void> logout() async {
    await UserSession.clear();

    final navigator = navigatorKey.currentState;
    if (navigator == null) return;

    navigator.pushNamedAndRemoveUntil(
      '/login',
          (route) => false,
    );
  }
}