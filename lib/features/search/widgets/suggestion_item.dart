import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class SuggestionItem extends StatelessWidget {
  final String imageUrl;
  final String productName;
  final VoidCallback onTap;

  const SuggestionItem({
    super.key,
    required this.imageUrl,
    required this.productName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(
        vertical: 6,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          12,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        leading: ClipRRect(
          borderRadius:
          BorderRadius.circular(8),
          child: imageUrl.isEmpty
              ? const SizedBox(
            width: 60,
            height: 60,
            child: Icon(Icons.image),
          )
              : Image.network(
            imageUrl,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            errorBuilder:
                (_, __, ___) =>
            const Icon(
              Icons.broken_image,
            ),
          ),
        ),
        title: Text(
          productName,
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
        ),
      ),
    );
  }
}