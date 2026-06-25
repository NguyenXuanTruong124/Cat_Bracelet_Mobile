import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
  });

  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: Container(
        height: 70.h,
        decoration: BoxDecoration(
          color: isLoading
              ? AppColors.wine.withValues(alpha: 0.6)
              : AppColors.wine,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            if (!isLoading)
              BoxShadow(
                color: AppColors.wine.withValues(alpha: 0.22),
                blurRadius: 22.r,
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
                    color: AppColors.gold,
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
                        color: AppColors.gold,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.1,
                      ),
                    ),
                    SizedBox(width: 16),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: AppColors.gold,
                      size: 28,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class RegisterPrompt extends StatelessWidget {
  const RegisterPrompt({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text.rich(
          TextSpan(
            text: 'Chưa có tài khoản? ',
            style: const TextStyle(
              color: AppColors.taupe,
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
