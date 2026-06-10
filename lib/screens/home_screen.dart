import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

import '../config/api_config.dart';
import '../models/product.dart';
import 'home/widgets/home_sections.dart';
// ... các import giữ nguyên

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Color palette
  static const Color _wine = Color(0xFF902021);
  static const Color _gold = Color(0xFFDAB47D);
  static const Color _softRose = Color(0xFFFFF8F7);
  static const Color _cream = Color(0xFFFFF3EE);

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
          _products = data.map((json) => Product.fromJson(json)).toList();
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
    final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    return formatCurrency.format(price);
  }

  String _getImageUrl(String? thumbnail) {
    if (thumbnail == null || thumbnail.isEmpty) return '';
    if (thumbnail.startsWith('http')) return thumbnail;

    final baseUrl = ApiConfig.getBaseUrl(context);
    final cleanPath = thumbnail.startsWith('/') ? thumbnail : '/$thumbnail';
    return '$baseUrl$cleanPath';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: _wine,
            expandedHeight: 80,
            floating: true,
            pinned: true,
            title: const Text(
              'Cát Bracelet',
              style: TextStyle(
                fontFamily: 'serif',
                fontWeight: FontWeight.bold,
                color: _gold,
              ),
            ),
            centerTitle: true,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: CircleAvatar(
                  backgroundColor: _gold.withOpacity(0.8),
                  child: const Icon(Icons.person, color: Colors.white),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/');
                },
                child: const Text(
                  'Đăng xuất',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),

          // Hero Section
          SliverToBoxAdapter(child: HomeSections.buildHeroSection()),

          // Bộ sưu tập (đưa lên gần đầu)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                children: [
                  const Text(
                    'Bộ sưu tập nổi bật',
                    style: TextStyle(
                      fontSize: 24,
                      fontFamily: 'serif',
                      fontWeight: FontWeight.bold,
                      color: _wine,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _wine,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/collection');
                    },
                    child: const Text(
                      'Xem bộ sưu tập',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Các section khác
          SliverToBoxAdapter(child: HomeSections.buildFeaturesSection()),
          SliverToBoxAdapter(child: HomeSections.buildAboutSection()),
          SliverToBoxAdapter(child: HomeSections.buildTestimonialsSection()),
          SliverToBoxAdapter(child: HomeSections.buildFooter()),
        ],
      ),
    );
  }

// Giữ nguyên _buildFeaturedProducts nếu cần dùng ở CollectionScreen
}

