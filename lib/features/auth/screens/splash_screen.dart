import 'package:flutter/material.dart';

import '../../../core/routes/app_routes.dart';
import '../../profile/models/user_session.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeSession();
  }

  Future<void> _initializeSession() async {
    debugPrint('SPLASH: starting session initialization');
    // Đọc dữ liệu đã lưu
    await UserSession.initialize();

    if (!mounted) return;

    // Không có refresh token -> Login
    if (UserSession.refreshToken == null || UserSession.refreshToken!.isEmpty) {
      debugPrint('SPLASH: no refresh token, going to login');
      _goToLogin();
      return;
    }

    // Thử refresh token
    final success = await UserSession.refreshTokens();

    if (!mounted) return;

    if (success) {
      debugPrint('SPLASH: refresh token success, loading profile');
      await UserSession.refreshCurrentUser();

      if (!mounted) return;

      debugPrint('SPLASH: going to home');
      _goToHome();
    } else {
      debugPrint('SPLASH: refresh token failed, keeping existing session');
      if (UserSession.accessToken != null || UserSession.currentUser != null) {
        if (!mounted) return;
        debugPrint('SPLASH: going to home using existing session');
        _goToHome();
      } else {
        if (!mounted) return;
        debugPrint('SPLASH: going to login');
        _goToLogin();
      }
    }
  }

  void _goToHome() {
    Navigator.pushReplacementNamed(context, AppRoutes.home);
  }

  void _goToLogin() {
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
