import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class SearchHeader extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSubmitted;

  const SearchHeader({
    super.key,
    required this.controller,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.search,
          color: AppColors.primary,
          size: 34,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextField(
            controller: controller,
            autofocus: true,
            textInputAction: TextInputAction.search,
            onSubmitted: onSubmitted,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
            decoration: const InputDecoration(
              hintText: 'Tìm trong Cat Bracelet',
              border: UnderlineInputBorder(),
            ),
          ),
        ),
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.close,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}