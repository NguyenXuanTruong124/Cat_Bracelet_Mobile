import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../config/api_config.dart';
import '../models/product.dart';
import '../models/product_variants.dart';
import '../services/api_helpers.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Product product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  static const Color _wine = Color(0xFF902021);
  static const Color _gold = Color(0xFFDAB47D);
  static const Color _softRose = Color(0xFFFFF8F7);

  late Product _product;
  List<ProductVariants> _variants = [];
  ProductVariants? _selectedVariant;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _product = widget.product;
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final baseUrl = ApiConfig.getBaseUrl(context);
      final productUrl = Uri.parse('$baseUrl/products/${_product.id}');
      final variantsUrl = Uri.parse(
        '$baseUrl/product-variants/by-name/${Uri.encodeComponent(_product.productName)}',
      );

      final responses = await Future.wait([
        http.get(productUrl),
        http.get(variantsUrl),
      ]);

      Product nextProduct = _product;
      if (responses[0].statusCode == 200) {
        final decodedProduct = _decodeObject(responses[0].body);
        if (decodedProduct != null) {
          nextProduct = Product.fromJson(decodedProduct);
        }
      }

      List<ProductVariants> nextVariants = [];
      if (responses[1].statusCode == 200) {
        nextVariants = _decodeList(responses[1].body)
            .whereType<Map<String, dynamic>>()
            .map(ProductVariants.fromJson)
            .where((variant) => variant.status.toLowerCase() == 'active')
            .toList();
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _product = nextProduct;
        _variants = nextVariants;
        _selectedVariant = nextVariants.isNotEmpty ? nextVariants.first : null;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage = 'Khong the tai chi tiet san pham';
        _isLoading = false;
      });
    }
  }

  List<dynamic> _decodeList(String body) {
    final decoded = jsonDecode(body);
    if (decoded is List) {
      return decoded;
    }
    if (decoded is Map<String, dynamic>) {
      final data = decoded['data'] ?? decoded['items'] ?? decoded['content'];
      if (data is List) {
        return data;
      }
      return [decoded];
    }
    return [];
  }

  Map<String, dynamic>? _decodeObject(String body) {
    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) {
      final data = decoded['data'];
      if (data is Map<String, dynamic>) {
        return data;
      }
      return decoded;
    }
    return null;
  }

  int get _displayPrice {
    return _product.basePrice + ((_selectedVariant?.extraPrice ?? 0).toInt());
  }

  String _formatPrice(num price) {
    final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: 'd');
    return formatCurrency.format(price);
  }

  String _getImageUrl(String? thumbnail) {
    return buildImageUrl(ApiConfig.getBaseUrl(context), thumbnail);
  }

  Future<void> _addToCart() async {
    if (_selectedVariant == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Vui long chon bien the')));
      return;
    }

    try {
      final baseUrl = ApiConfig.getBaseUrl(context);
      final response = await http.post(
        Uri.parse('$baseUrl/cart/add'),
        headers: apiHeaders(json: true),
        body: jsonEncode({'variantId': _selectedVariant!.id, 'quantity': 1}),
      );

      if (!mounted) {
        return;
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showAddedToCart();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Khong the them gio: ${response.statusCode}')),
        );
      }
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Khong the ket noi gio hang')),
      );
    }
  }

  void _showAddedToCart() {
    final variantText = _selectedVariant == null
        ? ''
        : ' - ${_selectedVariant!.color ?? ''} ${_selectedVariant!.size ?? ''}'
              .trimRight();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_product.productName}$variantText da them vao gio'),
        backgroundColor: _wine,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = _getImageUrl(_product.thumbnail);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Chi tiet san pham',
          style: TextStyle(fontFamily: 'serif', fontWeight: FontWeight.bold),
        ),
        backgroundColor: _wine,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _wine))
          : _errorMessage.isNotEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  _errorMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            )
          : RefreshIndicator(
              color: _wine,
              onRefresh: _fetchDetails,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                children: [
                  Container(
                    height: 340,
                    decoration: BoxDecoration(
                      color: _softRose,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _gold.withValues(alpha: 0.35)),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: imageUrl.isNotEmpty
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.image_not_supported,
                                size: 54,
                                color: Colors.grey,
                              );
                            },
                          )
                        : const Icon(
                            Icons.image_not_supported,
                            size: 54,
                            color: Colors.grey,
                          ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _product.productName,
                    style: const TextStyle(
                      color: Color(0xFF2E2A28),
                      fontFamily: 'serif',
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _formatPrice(_displayPrice),
                    style: const TextStyle(
                      color: _wine,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if ((_product.description ?? '').trim().isNotEmpty) ...[
                    const SizedBox(height: 18),
                    Text(
                      _product.description!,
                      style: const TextStyle(
                        color: Color(0xFF4A403B),
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),
                  ],
                  if (_product.categoryName != null ||
                      _product.materialNames.isNotEmpty) ...[
                    const SizedBox(height: 18),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (_product.categoryName != null)
                          _infoChip(Icons.category, _product.categoryName!),
                        ..._product.materialNames.map(
                          (material) => _infoChip(Icons.diamond, material),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 24),
                  _buildVariantSection(),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _wine,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: (_selectedVariant?.stock ?? 1) > 0
                          ? _addToCart
                          : null,
                      icon: const Icon(Icons.add_shopping_cart),
                      label: const Text(
                        'Them vao gio hang',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildVariantSection() {
    if (_variants.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _gold.withValues(alpha: 0.35)),
        ),
        child: const Text('San pham hien chua co bien the.'),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Chon bien the',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E2A28),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _variants.map((variant) {
            final isSelected = variant.id == _selectedVariant?.id;
            final label = [
              if ((variant.color ?? '').isNotEmpty) variant.color,
              if ((variant.size ?? '').isNotEmpty) variant.size,
            ].join(' / ');

            return ChoiceChip(
              selected: isSelected,
              label: Text(label.isEmpty ? variant.sku : label),
              avatar: variant.stock > 0
                  ? null
                  : const Icon(Icons.block, size: 16),
              selectedColor: _wine,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF2E2A28),
                fontWeight: FontWeight.w600,
              ),
              side: BorderSide(color: _gold.withValues(alpha: 0.5)),
              onSelected: variant.stock > 0
                  ? (_) {
                      setState(() {
                        _selectedVariant = variant;
                      });
                    }
                  : null,
            );
          }).toList(),
        ),
        if (_selectedVariant != null) ...[
          const SizedBox(height: 12),
          Text(
            'Ton kho: ${_selectedVariant!.stock}',
            style: const TextStyle(color: Color(0xFF6B5E56), fontSize: 13),
          ),
        ],
      ],
    );
  }

  Widget _infoChip(IconData icon, String label) {
    return Chip(
      avatar: Icon(icon, size: 16, color: _wine),
      label: Text(label),
      backgroundColor: _softRose,
      side: BorderSide(color: _gold.withValues(alpha: 0.35)),
    );
  }
}
