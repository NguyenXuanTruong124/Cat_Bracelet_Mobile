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
    // Đọc dữ liệu đã lưu
    await UserSession.initialize();

    if (!mounted) return;

    // Không có refresh token -> Login
    if (UserSession.refreshToken == null ||
        UserSession.refreshToken!.isEmpty) {
      _goToLogin();
      return;
    }

    // Thử refresh token
    final success = await UserSession.refreshTokens();

    if (!mounted) return;

    if (success) {
      await UserSession.refreshCurrentUser();

      if (!mounted) return;

      _goToHome();
    } else {
      await UserSession.clear();

      if (!mounted) return;

      _goToLogin();
    }
  }

  void _goToHome() {
    Navigator.pushReplacementNamed(
      context,
      AppRoutes.home,
    );
  }

  void _goToLogin() {
    Navigator.pushReplacementNamed(
      context,
      AppRoutes.login,
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}