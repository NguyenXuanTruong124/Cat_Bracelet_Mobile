import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({
    super.key,
    required this.emailController,
    required this.passwordController,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const FieldLabel(text: 'EMAIL'),
        const SizedBox(height: 5),
        InputBox(
          controller: widget.emailController,
          icon: Icons.mail_outline_rounded,
          hintText: 'Nhập địa chỉ email',
        ),
        const SizedBox(height: 20),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            FieldLabel(text: 'MẬT KHẨU'),
            SizedBox(width: 16),
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: ForgotPasswordLink(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        InputBox(
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
              color: AppColors.roseBorder.withValues(alpha: 0.95),
              size: 30,
            ),
          ),
        ),
      ],
    );
  }
}

class ForgotPasswordLink extends StatelessWidget {
  const ForgotPasswordLink({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/forgot-password'),
      child: const Text(
        'Quên mật khẩu?',
        style: TextStyle(
          color: Color(0xFFA38C69),
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class FieldLabel extends StatelessWidget {
  const FieldLabel({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.taupe,
        fontSize: 16,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.4,
      ),
    );
  }
}

class InputBox extends StatelessWidget {
  const InputBox({
    super.key,
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
      height: 80.h,
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      decoration: BoxDecoration(
        color: AppColors.softRose,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: AppColors.roseBorder, width: 1.5),
      ),
      child: Row(
        children: [
          Icon(icon, size: 30.sp),
          SizedBox(width: 16.w),
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: obscureText,
              style: TextStyle(
                color: AppColors.wine,
                fontSize: 21.sp,
                fontWeight: FontWeight.w700,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hintText,
                hintStyle: TextStyle(
                  color: AppColors.roseBorder.withValues(alpha: 0.92),
                  fontSize: 21.sp,
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
