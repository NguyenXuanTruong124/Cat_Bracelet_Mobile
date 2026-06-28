import 'package:flutter/material.dart';
import 'dart:convert';
import '../../profile/models/user_session.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../services/auth_service.dart';
import '../widgets/login_header.dart';
import '../widgets/login_form.dart';
import '../widgets/login_widgets.dart';
import '../../../core/widgets/app_notification.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      AppNotification.showError(
        context: context,
        message: 'Vui lòng nhập email và mật khẩu',
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await AuthService(context).login(email, password);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);

        if (decoded is Map<String, dynamic>) {
          await UserSession.setFromLogin(decoded);
        }

        if (!mounted) return;

        AppNotification.showSuccess(
          context: context,
          message: 'Đăng nhập thành công',
        );

        await Future.delayed(const Duration(milliseconds: 800));

        if (!mounted) return;

        Navigator.pushReplacementNamed(context, '/home');
      } else {
        if (!mounted) return;
        AppNotification.showError(
          context: context,
          message: 'Email hoặc mật khẩu không chính xác',
        );
      }
    } catch (e) {
      if (!mounted) return;
      AppNotification.showError(
        context: context,
        message: 'Không thể kết nối tới máy chủ',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFF3EE), Color(0xFFFFFAF8)],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final horizontalPadding = constraints.maxWidth < 380
                  ? 22.0
                  : 34.0;
              final panelRadius = constraints.maxWidth < 380 ? 34.0 : 48.0;

              return Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: 24,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: Container(
                      padding: EdgeInsets.fromLTRB(
                        constraints.maxWidth < 380 ? 28 : 56,
                        56,
                        constraints.maxWidth < 380 ? 28 : 56,
                        42,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.94),
                        borderRadius: BorderRadius.circular(panelRadius),
                        border: Border.all(color: const Color(0xFFFFE8E1)),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const LoginHeader(),
                          SizedBox(height: 58.h),
                          LoginForm(
                            emailController: _emailController,
                            passwordController: _passwordController,
                          ),
                          SizedBox(height: 36.h),
                          PrimaryButton(
                            isLoading: _isLoading,
                            onPressed: _handleLogin,
                          ),
                          SizedBox(height: 42.h),
                          const RegisterPrompt(),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
