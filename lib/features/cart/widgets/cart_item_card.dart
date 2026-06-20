import 'package:flutter/material.dart';
import '../../../core/services/api_helpers.dart';
import 'package:cat_bracelet_mobile/core/utils/price_formatter.dart';

class CartItemCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final String baseUrl;
  final Function(String id, int quantity) onUpdateQuantity;
  final Function(String id) onRemoveItem;

  const CartItemCard({
    super.key,
    required this.item,
    required this.baseUrl,
    required this.onUpdateQuantity,
    required this.onRemoveItem,
  });

  @override
  Widget build(BuildContext context) {
    final product = item['product'] as Map<String, dynamic>?;
    final variant = item['variantDetails'] as Map<String, dynamic>?;
    final quantity = toInt(item['quantity']);
    final id = (item['cartItemId'] ?? item['id']).toString();
    final imageUrl = buildImageUrl(baseUrl, product?['thumbnail']?.toString());

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 72,
                height: 72,
                child: imageUrl.isEmpty
                    ? const ColoredBox(
                        color: Color(0xFFFFF8F7),
                        child: Icon(Icons.image_not_supported),
                      )
                    : Image.network(imageUrl, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (product?['productName'] ?? 'Sản phẩm').toString(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${variant?['color'] ?? ''} ${variant?['size'] ?? ''}'
                        .trim(),
                  ),
                  Text(formatPrice(toInt(item['subTotal']))),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          if (quantity == 1) {
                            onRemoveItem(id);
                          } else {
                            onUpdateQuantity(id, quantity - 1);
                          }
                        },
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                      Text('$quantity'),
                      IconButton(
                        onPressed: () => onUpdateQuantity(id, quantity + 1),
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => onRemoveItem(id),
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
