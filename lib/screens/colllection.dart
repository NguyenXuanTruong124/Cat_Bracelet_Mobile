import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../config/api_config.dart';
import '../models/product.dart';
import 'home_screen.dart';
class CollectionScreen extends StatefulWidget {
  const CollectionScreen({super.key});

  @override
  State<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends State<CollectionScreen> {
  static const Color _wine = Color(0xFF902021);
  static const Color _gold = Color(0xFFDAB47D);
  static const Color _softRose = Color(0xFFFFF8F7);

  List<Product> _products = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {

    try {
      final baseUrl = ApiConfig.getBaseUrl(context);
      final url = Uri.parse('$baseUrl/products');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        setState(() {
          _products = data
              .map((json) => Product.fromJson(json))
              .where(
                (product) => product.status.toString().toLowerCase() == 'active',
          )
              .toList();

          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Lỗi tải dữ liệu: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Không thể kết nối đến máy chủ';
        _isLoading = false;
      });
    }
  }

  String _formatPrice(int price) {
    final formatCurrency = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: 'đ',
    );
    return formatCurrency.format(price);
  }

  String _getImageUrl(String? thumbnail) {
    if (thumbnail == null || thumbnail.isEmpty) {
      return '';
    }

    if (thumbnail.startsWith('http')) {
      return thumbnail;
    }

    final baseUrl = ApiConfig.getBaseUrl(context);
    final cleanPath =
    thumbnail.startsWith('/') ? thumbnail : '/$thumbnail';

    return '$baseUrl$cleanPath';
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    int crossAxisCount = 2;

    if (screenWidth >= 1200) {
      crossAxisCount = 5;
    } else if (screenWidth >= 900) {
      crossAxisCount = 4;
    } else if (screenWidth >= 600) {
      crossAxisCount = 3;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Bộ sưu tập',
          style: TextStyle(
            fontFamily: 'serif',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: _wine,
        foregroundColor: Colors.white,

        // Nút back bên trái
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Quay lại',
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => const HomeScreen(),
              ),
                  (route) => false,
            );
          },
        ),

        // Nút giỏ hàng bên phải
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            tooltip: 'Giỏ hàng',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đi tới giỏ hàng'),
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(
          color: _wine,
        ),
      )
          : _errorMessage.isNotEmpty
          ? Center(
        child: Text(
          _errorMessage,
          style: const TextStyle(
            color: Colors.red,
          ),
        ),
      )
          : GridView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _products.length,
        gridDelegate:
        SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio:
          screenWidth < 600 ? 0.68 : 0.75,
        ),
        itemBuilder: (context, index) {
          final product = _products[index];
          final imageUrl =
          _getImageUrl(product.thumbnail);

          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
              BorderRadius.circular(16),
              border: Border.all(
                color: _gold.withOpacity(0.3),
              ),
              boxShadow: [
                BoxShadow(
                  color:
                  Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 6,
                  child: Container(
                    color: _softRose,
                    child: imageUrl.isNotEmpty
                        ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (
                          context,
                          child,
                          loadingProgress,
                          ) {
                        if (loadingProgress ==
                            null) {
                          return child;
                        }

                        return const Center(
                          child:
                          CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        );
                      },
                      errorBuilder: (
                          context,
                          error,
                          stackTrace,
                          ) {
                        return const Icon(
                          Icons
                              .image_not_supported,
                          color: Colors.grey,
                          size: 40,
                        );
                      },
                    )
                        : const Icon(
                      Icons
                          .image_not_supported,
                      color: Colors.grey,
                      size: 40,
                    ),
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: Padding(
                    padding:
                    const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      mainAxisAlignment:
                      MainAxisAlignment
                          .spaceBetween,
                      children: [
                        Text(
                          product.productName,
                          maxLines: 2,
                          overflow:
                          TextOverflow.ellipsis,
                          style:
                          const TextStyle(
                            fontSize: 14,
                            fontWeight:
                            FontWeight.w700,
                            color:
                            Color(0xFF333333),
                            height: 1.3,
                          ),
                        ),
                        Text(
                          _formatPrice(
                            product.basePrice,
                          ),
                          style:
                          const TextStyle(
                            fontSize: 15,
                            fontWeight:
                            FontWeight.w800,
                            color: _wine,
                          ),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        SizedBox(
                          width:
                          double.infinity,
                          child:
                          ElevatedButton.icon(
                            style:
                            ElevatedButton
                                .styleFrom(
                              backgroundColor:
                              _wine,
                              foregroundColor:
                              Colors.white,
                              padding:
                              const EdgeInsets
                                  .symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              shape:
                              RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius
                                    .circular(
                                  8,
                                ),
                              ),
                            ),
                            onPressed: () {
                              ScaffoldMessenger.of(
                                  context)
                                  .showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '${product.productName} đã thêm vào giỏ hàng',
                                  ),
                                  backgroundColor:
                                  _wine,
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons
                                  .add_shopping_cart,
                              size: 18,
                            ),
                            label: const Text(
                              'Thêm vào giỏ',
                              style:
                              TextStyle(
                                fontSize: 13,
                                fontWeight:
                                FontWeight
                                    .bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}