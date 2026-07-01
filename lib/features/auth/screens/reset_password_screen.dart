import 'package:flutter/material.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../services/auth_service.dart';
import '../../../core/widgets/app_notification.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;

  const ResetPasswordScreen({super.key, required this.email});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _otpController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final otp = _otpController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    if (otp.length != 6) {
      AppNotification.showError(
        context: context,
        message: 'Vui lòng nhập mã OTP gồm 6 chữ số',
      );
      return;
    }
    if (password.length < 6) {
      AppNotification.showError(
        context: context,
        message: 'Mật khẩu phải có ít nhất 6 ký tự',
      );
      return;
    }
    if (password != confirm) {
      AppNotification.showError(
        context: context,
        message: 'Mật khẩu xác nhận không khớp',
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await AuthService(
        context,
      ).resetPassword(email: widget.email, otp: otp, newPassword: password);

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        AppNotification.showSuccess(
          context: context,
          message: 'Đặt lại mật khẩu thành công. Vui lòng đăng nhập.',
        );
        if (!mounted) return;
        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
      } else {
        AppNotification.showError(
          context: context,
          message: 'Lỗi ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e) {
      if (!mounted) return;
      AppNotification.showError(context: context, message: 'Lỗi kết nối: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primary),
        title: const Text(
          'Đặt lại mật khẩu',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.verified_user_outlined,
              size: 64,
              color: AppColors.gold,
            ),
            const SizedBox(height: 16),
            Text(
              'Nhập mã OTP đã gửi tới\n${widget.email}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 32),
            _buildField(
              controller: _otpController,
              label: 'MÃ OTP',
              hint: '000000',
              keyboardType: TextInputType.number,
              maxLength: 6,
            ),
            _buildField(
              controller: _passwordController,
              label: 'MẬT KHẨU MỚI',
              hint: 'Nhập mật khẩu mới',
              obscureText: _obscurePassword,
              trailing: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.outlineVariant,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            _buildField(
              controller: _confirmController,
              label: 'XÁC NHẬN MẬT KHẨU',
              hint: 'Nhập lại mật khẩu',
              obscureText: _obscurePassword,
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'XÁC NHẬN',
                        style: TextStyle(
                          letterSpacing: 2,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    int? maxLength,
    bool obscureText = false,
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              maxLength: maxLength,
              obscureText: obscureText,
              decoration: InputDecoration(
                hintText: hint,
                counterText: '',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppColors.surfaceContainerLow,
                suffixIcon: trailing,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
