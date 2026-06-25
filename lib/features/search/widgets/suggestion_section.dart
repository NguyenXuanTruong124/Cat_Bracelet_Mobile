import 'package:flutter/material.dart';

import '../../../config/api_config.dart';
import '../../../core/services/api_helpers.dart';
import '../../product/models/product.dart';
import 'suggestion_item.dart';

class SuggestionSection extends StatelessWidget {
  final List<Product> products;
  final ValueChanged<String> onTap;

  const SuggestionSection({
    super.key,
    required this.products,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final baseUrl =
    ApiConfig.getBaseUrl(context);

    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.auto_awesome),
            SizedBox(width: 12),
            Text(
              'Dành cho bạn',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...products.map((product) {
          return SuggestionItem(
            imageUrl: buildImageUrl(
              baseUrl,
              product.thumbnail,
            ),
            productName:
            product.productName,
            onTap: () => onTap(
              product.productName,
            ),
          );
        }),
      ],
    );
  }
}