import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class GemDivider extends StatelessWidget {
  const GemDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 46,
          child: Divider(color: AppColors.gold, thickness: 1.7),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Icon(
            Icons.diamond_outlined,
            color: AppColors.gold,
            size: 19,
          ),
        ),
        SizedBox(
          width: 46,
          child: Divider(color: AppColors.gold, thickness: 1.7),
        ),
      ],
    );
  }
}
