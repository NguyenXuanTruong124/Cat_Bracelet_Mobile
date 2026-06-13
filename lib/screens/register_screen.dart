import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  static const Color _wine = Color(0xFF902021);
  static const Color _roseBorder = Color(0xFFF1DADA);
  static const Color _softRose = Color(0xFFFFF8F7);
  static const Color _taupe = Color(0xFF8D7B79);
  static const Color _gold = Color(0xFFDAB47D);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  Future<void> _handleRegister() async {
    final email = _emailController.text.trim();
    final fullName = _fullNameController.text.trim();
    final password = _passwordController.text;
    final phone = _phoneController.text.trim();

    if (email.isEmpty || fullName.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập đủ các thông tin bắt buộc'),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final baseUrl = ApiConfig.getBaseUrl(context);
      final url = Uri.parse('$baseUrl/user/register');

      final Map<String, dynamic> body = {
        'email': email,
        'fullName': fullName,
        'password': password,
      };

      if (phone.isNotEmpty) {
        body['phone'] = phone;
      }

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Đăng ký thành công, vui lòng kiểm tra email để lấy mã OTP',
            ),
          ),
        );
        Navigator.pushReplacementNamed(context, '/otp', arguments: email);
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
    _fullNameController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF3EE),
        elevation: 0,
        iconTheme: const IconThemeData(color: RegisterScreen._wine),
        title: const Text(
          'Đăng Ký',
          style: TextStyle(
            color: RegisterScreen._wine,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
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
                        constraints.maxWidth < 380 ? 28 : 40,
                        40,
                        constraints.maxWidth < 380 ? 28 : 40,
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
                          const Text(
                            'Tạo tài khoản mới',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: RegisterScreen._wine,
                              fontFamily: 'serif',
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 32),
                          _buildFieldLabel('HỌ VÀ TÊN (*)'),
                          const SizedBox(height: 8),
                          _buildInputBox(
                            controller: _fullNameController,
                            icon: Icons.person_outline_rounded,
                            hintText: 'Nhập họ tên',
                          ),
                          const SizedBox(height: 20),
                          _buildFieldLabel('EMAIL (*)'),
                          const SizedBox(height: 8),
                          _buildInputBox(
                            controller: _emailController,
                            icon: Icons.mail_outline_rounded,
                            hintText: 'Nhập địa chỉ email',
                          ),
                          const SizedBox(height: 20),
                          _buildFieldLabel('SỐ ĐIỆN THOẠI'),
                          const SizedBox(height: 8),
                          _buildInputBox(
                            controller: _phoneController,
                            icon: Icons.phone_outlined,
                            hintText: 'Nhập số điện thoại',
                          ),
                          const SizedBox(height: 20),
                          _buildFieldLabel('MẬT KHẨU (*)'),
                          const SizedBox(height: 8),
                          _buildInputBox(
                            controller: _passwordController,
                            icon: Icons.lock_outline_rounded,
                            hintText: 'Nhập mật khẩu (từ 6 ký tự)',
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
                                color: RegisterScreen._roseBorder.withValues(
                                  alpha: 0.95,
                                ),
                                size: 26,
                              ),
                            ),
                          ),
                          const SizedBox(height: 36),
                          GestureDetector(
                            onTap: _isLoading ? null : _handleRegister,
                            child: Container(
                              height: 60,
                              decoration: BoxDecoration(
                                color: _isLoading
                                    ? RegisterScreen._wine.withValues(
                                        alpha: 0.6,
                                      )
                                    : RegisterScreen._wine,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  if (!_isLoading)
                                    BoxShadow(
                                      color: RegisterScreen._wine.withValues(
                                        alpha: 0.22,
                                      ),
                                      blurRadius: 15,
                                      offset: const Offset(0, 8),
                                    ),
                                ],
                              ),
                              child: Center(
                                child: _isLoading
                                    ? const SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(
                                          color: RegisterScreen._gold,
                                          strokeWidth: 3,
                                        ),
                                      )
                                    : const Text(
                                        'ĐĂNG KÝ',
                                        style: TextStyle(
                                          color: RegisterScreen._gold,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 2.1,
                                        ),
                                      ),
                              ),
                            ),
                          ),
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

  Widget _buildFieldLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: RegisterScreen._taupe,
        fontSize: 14,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildInputBox({
    required IconData icon,
    required String hintText,
    TextEditingController? controller,
    bool obscureText = false,
    Widget? trailing,
  }) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: RegisterScreen._softRose,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: RegisterScreen._roseBorder, width: 1.5),
      ),
      child: Row(
        children: [
          Icon(icon, color: RegisterScreen._roseBorder, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: obscureText,
              style: const TextStyle(
                color: RegisterScreen._wine,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hintText,
                hintStyle: TextStyle(
                  color: RegisterScreen._roseBorder.withValues(alpha: 0.92),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 8), trailing],
        ],
      ),
    );
  }
}
