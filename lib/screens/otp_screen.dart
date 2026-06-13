import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  static const Color _wine = Color(0xFF902021);
  static const Color _roseBorder = Color(0xFFF1DADA);
  static const Color _softRose = Color(0xFFFFF8F7);
  static const Color _taupe = Color(0xFF8D7B79);
  static const Color _gold = Color(0xFFDAB47D);

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController _otpController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleVerifyOtp(String email) async {
    final otp = _otpController.text.trim();

    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập đúng mã OTP gồm 6 chữ số')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final baseUrl = ApiConfig.getBaseUrl(context);
      final url = Uri.parse('$baseUrl/user/verify-otp');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'otp': otp}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Xác thực thành công! Vui lòng đăng nhập.'),
          ),
        );
        Navigator.pushReplacementNamed(context, '/'); // Go back to login
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
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Nhận email từ tham số điều hướng
    final String email =
        ModalRoute.of(context)?.settings.arguments as String? ?? '';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF3EE),
        elevation: 0,
        iconTheme: const IconThemeData(color: OtpScreen._wine),
        title: const Text(
          'Xác thực tài khoản',
          style: TextStyle(color: OtpScreen._wine, fontWeight: FontWeight.bold),
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
              return Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 24,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.94),
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(color: const Color(0xFFFFE8E1)),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Icon(
                            Icons.mark_email_read_outlined,
                            size: 60,
                            color: OtpScreen._gold,
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Nhập mã OTP',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: OtpScreen._wine,
                              fontFamily: 'serif',
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Mã xác thực đã được gửi tới email:\n$email',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: OtpScreen._taupe,
                              fontSize: 15,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 32),
                          Container(
                            height: 60,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: OtpScreen._softRose,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: OtpScreen._roseBorder,
                                width: 1.5,
                              ),
                            ),
                            child: TextField(
                              controller: _otpController,
                              keyboardType: TextInputType.number,
                              maxLength: 6,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: OtpScreen._wine,
                                fontSize: 24,
                                letterSpacing: 8.0,
                                fontWeight: FontWeight.bold,
                              ),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                counterText: '',
                                hintText: '------',
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          GestureDetector(
                            onTap: _isLoading
                                ? null
                                : () => _handleVerifyOtp(email),
                            child: Container(
                              height: 56,
                              decoration: BoxDecoration(
                                color: _isLoading
                                    ? OtpScreen._wine.withValues(alpha: 0.6)
                                    : OtpScreen._wine,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  if (!_isLoading)
                                    BoxShadow(
                                      color: OtpScreen._wine.withValues(
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
                                          color: OtpScreen._gold,
                                          strokeWidth: 3,
                                        ),
                                      )
                                    : const Text(
                                        'XÁC NHẬN',
                                        style: TextStyle(
                                          color: OtpScreen._gold,
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
}
