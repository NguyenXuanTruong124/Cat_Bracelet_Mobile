import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AppNotification {
  static void showSuccess({
    required BuildContext context,
    required String message,
  }) {
    _show(
      context: context,
      message: message,
      isError: false,
    );
  }

  static void showError({
    required BuildContext context,
    required String message,
  }) {
    _show(
      context: context,
      message: message,
      isError: true,
    );
  }

  static void _show({
    required BuildContext context,
    required String message,
    required bool isError,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: isError ? const Color(0xFF8B3A3A) : AppColors.wine,
          elevation: 8,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          content: Row(
            children: [
              Icon(
                isError
                    ? Icons.error_outline_rounded
                    : Icons.check_circle_outline_rounded,
                color: AppColors.gold,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }
}
