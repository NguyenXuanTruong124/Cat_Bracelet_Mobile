import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';
import '../models/user_session.dart';
import 'package:flutter/gestures.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static const Color _wine = Color(0xFF902021);
  static const Color _roseBorder = Color(0xFFF1DADA);
  static const Color _softRose = Color(0xFFFFF8F7);
  static const Color _taupe = Color(0xFF8D7B79);
  static const Color _gold = Color(0xFFDAB47D);

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập email và mật khẩu')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // LƯU Ý:
      // - Nếu chạy app trên máy ảo Android (Emulator), phải dùng 10.0.2.2 thay cho localhost.
      // - Nếu chạy trên thiết bị thật, phải dùng địa chỉ IP LAN của máy tính (ví dụ 192.168.1.x).
      // - Đường dẫn thường có dạng /api/user/login, vui lòng sửa lại đúng với route API thực tế của bạn.
      final baseUrl = ApiConfig.getBaseUrl(context);
      final url = Uri.parse('$baseUrl/user/login');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          UserSession.setFromLogin(decoded);
        }
        if (!mounted) return;
        // Đăng nhập thành công, chuyển sang trang Home
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi ${response.statusCode}: ${response.body}'),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi kết nối tới Server: $e')));
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
                          const _LoginHeader(),
                          const SizedBox(height: 58),
                          _LoginForm(
                            emailController: _emailController,
                            passwordController: _passwordController,
                          ),
                          const SizedBox(height: 36),
                          _PrimaryButton(
                            isLoading: _isLoading,
                            onPressed: _handleLogin,
                          ),
                          const SizedBox(height: 42),
                          const _RegisterPrompt(),
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

class _LoginHeader extends StatelessWidget {
  const _LoginHeader();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Text(
          'Cat Bracelet',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: LoginScreen._wine,
            fontFamily: 'serif',
            fontSize: 36,
            fontWeight: FontWeight.w800,
            height: 1.05,
          ),
        ),
        SizedBox(height: 18),
        Text(
          'Năng lượng tinh khiết, phong\ncách tinh tế',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFFA08E8C),
            fontSize: 21,
            fontWeight: FontWeight.w600,
            height: 1.42,
          ),
        ),
        SizedBox(height: 34),
        _GemDivider(),
      ],
    );
  }
}

class _GemDivider extends StatelessWidget {
  const _GemDivider();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 46,
          child: Divider(color: LoginScreen._gold, thickness: 1.7),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Icon(
            Icons.diamond_outlined,
            color: LoginScreen._gold,
            size: 19,
          ),
        ),
        SizedBox(
          width: 46,
          child: Divider(color: LoginScreen._gold, thickness: 1.7),
        ),
      ],
    );
  }
}

class _LoginForm extends StatefulWidget {
  const _LoginForm({
    required this.emailController,
    required this.passwordController,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;

  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _FieldLabel('EMAIL'),
        const SizedBox(height: 13),
        _InputBox(
          controller: widget.emailController,
          icon: Icons.mail_outline_rounded,
          hintText: 'Nhập địa chỉ email',
        ),
        const SizedBox(height: 34),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _FieldLabel('MẬT KHẨU'),
            SizedBox(width: 16),
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Quên mật khẩu?',
                    style: TextStyle(
                      color: Color(0xFFA38C69),
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 13),
        _InputBox(
          controller: widget.passwordController,
          icon: Icons.lock_outline_rounded,
          hintText: 'Nhập mật khẩu',
          obscureText: !_isPasswordVisible,
          trailing: GestureDetector(
            onTap: () {
              setState(() {
                _isPasswordVisible = !_isPasswordVisible;
              });
            },
            child: Icon(
              _isPasswordVisible
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: LoginScreen._roseBorder.withValues(alpha: 0.95),
              size: 30,
            ),
          ),
        ),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: LoginScreen._taupe,
        fontSize: 16,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.4,
      ),
    );
  }
}

class _InputBox extends StatelessWidget {
  const _InputBox({
    required this.icon,
    required this.hintText,
    this.trailing,
    this.controller,
    this.obscureText = false,
  });

  final IconData icon;
  final String hintText;
  final Widget? trailing;
  final TextEditingController? controller;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: LoginScreen._softRose,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: LoginScreen._roseBorder, width: 1.5),
      ),
      child: Row(
        children: [
          Icon(icon, color: LoginScreen._roseBorder, size: 30),
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: obscureText,
              style: const TextStyle(
                color: LoginScreen._wine,
                fontSize: 21,
                fontWeight: FontWeight.w700,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hintText,
                hintStyle: TextStyle(
                  color: LoginScreen._roseBorder.withValues(alpha: 0.92),
                  fontSize: 21,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 10), trailing!],
        ],
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.isLoading, required this.onPressed});

  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: isLoading
              ? LoginScreen._wine.withValues(alpha: 0.6)
              : LoginScreen._wine,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            if (!isLoading)
              BoxShadow(
                color: LoginScreen._wine.withValues(alpha: 0.22),
                blurRadius: 22,
                offset: const Offset(0, 12),
              ),
          ],
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  height: 30,
                  width: 30,
                  child: CircularProgressIndicator(
                    color: LoginScreen._gold,
                    strokeWidth: 3,
                  ),
                )
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'ĐĂNG NHẬP',
                      style: TextStyle(
                        color: LoginScreen._gold,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.1,
                      ),
                    ),
                    SizedBox(width: 16),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: LoginScreen._gold,
                      size: 28,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _RegisterPrompt extends StatelessWidget {
  const _RegisterPrompt();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text.rich(
          TextSpan(
            text: 'Chưa có tài khoản? ',
            style: const TextStyle(
              color: LoginScreen._taupe,
              fontSize: 21,
              fontWeight: FontWeight.w500,
            ),
            children: [
              TextSpan(
                text: 'Đăng ký ngay',
                style: const TextStyle(
                  color: Color(0xFF80684A),
                  fontWeight: FontWeight.w800,
                  decoration: TextDecoration.underline,
                  decorationColor: Color(0xFFD5C2AB),
                  decorationThickness: 1.6,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    Navigator.pushNamed(context, '/register');
                  },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
