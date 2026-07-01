import 'package:flutter/material.dart';

import '../../features/profile/models/user_session.dart';

class SessionManager {
  SessionManager._();

  static final navigatorKey = GlobalKey<NavigatorState>();

  static Future<void> logout() async {
    debugPrint('SESSION_MANAGER: logout requested');
    await UserSession.clear();

    final navigator = navigatorKey.currentState;
    if (navigator == null) return;

    navigator.pushNamedAndRemoveUntil('/login', (route) => false);
  }
}
