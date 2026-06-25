import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../collection/screens/collection_screen.dart';
import '../../product/models/product.dart';
import '../services/search_service.dart';
import '../widgets/search_header.dart';
import '../widgets/suggestion_section.dart';
import '../widgets/trending_section.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() =>
      _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller =
  TextEditingController();

  final SearchService _searchService =
  SearchService();

  List<Product> _suggestions = [];

  bool _isLoading = false;
  String? _errorMessage;

  static const List<String> _trends = [
    'Ruby',
    'Đá tự nhiên',
    'Vòng tay',
    'Aquamarine',
    'Silver',
  ];

  @override
  void initState() {
    super.initState();
    _loadSuggestions();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadSuggestions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final products =
      await _searchService.getSuggestions(
        context,
      );

      if (!mounted) return;

      setState(() {
        _suggestions = products;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _errorMessage =
        'Không thể tải danh sách sản phẩm';
      });
    } finally {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    }
  }

  void _submit([String? value]) {
    final query =
    (value ?? _controller.text).trim();

    if (query.isEmpty) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => CollectionScreen(
          initialSearch: query,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth =
        MediaQuery.of(context).size.width;

    final isCompact = screenWidth < 600;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(
            horizontal: isCompact ? 16 : 24,
            vertical: 24,
          ),
          children: [
            SearchHeader(
              controller: _controller,
              onSubmitted: _submit,
            ),

            SizedBox(
              height: isCompact ? 24 : 32,
            ),

            TrendingSection(
              trends: _trends,
              onTap: _submit,
            ),

            Divider(
              height: isCompact ? 24 : 40,
            ),

            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(
                  color: AppColors.wine,
                ),
              ),

            if (_errorMessage != null)
              Padding(
                padding:
                const EdgeInsets.symmetric(
                  vertical: 24,
                ),
                child: Center(
                  child: Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.red,
                    ),
                  ),
                ),
              ),

            if (!_isLoading &&
                _errorMessage == null &&
                _suggestions.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(
                  vertical: 24,
                ),
                child: Center(
                  child: Text(
                    'Không có sản phẩm gợi ý',
                  ),
                ),
              ),

            if (!_isLoading &&
                _errorMessage == null &&
                _suggestions.isNotEmpty)
              SuggestionSection(
                products: _suggestions,
                onTap: _submit,
              ),
          ],
        ),
      ),
    );
  }
}