import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../config/api_config.dart';
import 'package:cat_bracelet_mobile/features/product/models/product.dart';
import '../../../core/services/api_helpers.dart';
import '../../../features/product/screens/collection_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  static const Color _wine = Color(0xFF902021);
  static const Color _cream = Color(0xFFFFFAEF);

  final TextEditingController _controller = TextEditingController();
  List<Product> _suggestions = [];

  @override
  void initState() {
    super.initState();
    _fetchSuggestions();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _fetchSuggestions() async {
    try {
      final baseUrl = ApiConfig.getBaseUrl(context);
      final response = await http.get(Uri.parse('$baseUrl/products'));
      if (response.statusCode != 200) {
        return;
      }

      final products = decodeListPayload(jsonDecode(response.body))
          .whereType<Map<String, dynamic>>()
          .map(Product.fromJson)
          .where((product) => product.status.toLowerCase() == 'active')
          .take(5)
          .toList();

      if (!mounted) {
        return;
      }
      setState(() => _suggestions = products);
    } catch (_) {}
  }

  void _submit([String? value]) {
    final query = (value ?? _controller.text).trim();
    if (query.isEmpty) {
      return;
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => CollectionScreen(initialSearch: query),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final baseUrl = ApiConfig.getBaseUrl(context);
    final trends = ['Ruby', 'Da tu nhien', 'Vong tay', 'Aquamarine', 'Silver'];

    return Scaffold(
      backgroundColor: _cream,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          children: [
            Row(
              children: [
                const Icon(Icons.search, color: _wine, size: 34),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    autofocus: true,
                    textInputAction: TextInputAction.search,
                    onSubmitted: _submit,
                    style: const TextStyle(
                      color: _wine,
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Tim trong Cat Bracelet',
                      hintStyle: TextStyle(color: Color(0xAA902021)),
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(color: _wine, width: 2),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: _wine, width: 2),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: _wine, size: 32),
                ),
              ],
            ),
            const SizedBox(height: 36),
            const Row(
              children: [
                Icon(Icons.trending_up, color: _wine),
                SizedBox(width: 14),
                Text(
                  'Xu huong',
                  style: TextStyle(
                    color: _wine,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            ...trends.map(
              (trend) => ListTile(
                contentPadding: const EdgeInsets.only(left: 40),
                title: Text(
                  trend,
                  style: const TextStyle(color: _wine, fontSize: 20),
                ),
                onTap: () => _submit(trend),
              ),
            ),
            const Divider(height: 40),
            const Row(
              children: [
                Icon(Icons.auto_awesome, color: _wine),
                SizedBox(width: 14),
                Text(
                  'Danh cho ban',
                  style: TextStyle(
                    color: _wine,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ..._suggestions.map((product) {
              final imageUrl = buildImageUrl(baseUrl, product.thumbnail);
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                leading: SizedBox(
                  width: 56,
                  height: 56,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: imageUrl.isEmpty
                        ? const ColoredBox(
                            color: Colors.white,
                            child: Icon(Icons.image_not_supported),
                          )
                        : Image.network(imageUrl, fit: BoxFit.cover),
                  ),
                ),
                title: Text(
                  product.productName,
                  style: const TextStyle(color: _wine, fontSize: 18),
                ),
                onTap: () => _submit(product.productName),
              );
            }),
          ],
        ),
      ),
    );
  }
}
