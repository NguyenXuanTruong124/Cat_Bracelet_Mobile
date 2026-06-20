import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:cat_bracelet_mobile/config/api_config.dart';
import 'package:cat_bracelet_mobile/features/profile/models/user_session.dart';
import '../../../core/services/api_helpers.dart';
import '../../../core/theme/app_colors.dart';
import '../widgets/address_cart.dart';
import '../screens/address_form_screen.dart';

class DeliveryAddressScreen extends StatefulWidget {
  const DeliveryAddressScreen({super.key});

  @override
  State<DeliveryAddressScreen> createState() => _DeliveryAddressScreenState();
}

class _DeliveryAddressScreenState extends State<DeliveryAddressScreen> {
  List<Map<String, dynamic>> _addresses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAddresses();
  }

  Future<void> _fetchAddresses() async {
    final user = UserSession.currentUser;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final baseUrl = ApiConfig.getBaseUrl(context);
      final response = await http.get(
        Uri.parse('$baseUrl/user-address/${user.id}'),
        headers: apiHeaders(),
      );
      if (response.statusCode == 200) {
        _addresses = decodeListPayload(jsonDecode(response.body))
            .whereType<Map<String, dynamic>>()
            .where(
              (a) => (a['status'] ?? '').toString().toUpperCase() == 'ACTIVE',
        )
            .toList();
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _setDefault(String addressId) async {
    final user = UserSession.currentUser;
    if (user == null) return;

    final baseUrl = ApiConfig.getBaseUrl(context);
    final response = await http.patch(
      Uri.parse('$baseUrl/user-address/${user.id}/$addressId/default'),
      headers: apiHeaders(json: true),
    );

    if (response.statusCode == 200) {
      await _fetchAddresses();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã đặt làm địa chỉ mặc định')),
        );
      }
    }
  }

  Future<void> _deleteAddress(String addressId) async {
    final user = UserSession.currentUser;
    if (user == null) return;

    final baseUrl = ApiConfig.getBaseUrl(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa địa chỉ'),
        content: const Text('Bạn có chắc muốn xóa địa chỉ này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final response = await http.delete(
      Uri.parse('$baseUrl/user-address/${user.id}/$addressId'),
      headers: apiHeaders(),
    );

    if (response.statusCode == 200) {
      await _fetchAddresses();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã xóa địa chỉ')),
        );
      }
    }
  }

  Future<void> _openForm({Map<String, dynamic>? address}) async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => AddressFormScreen(address: address),
      ),
    );
    if (saved == true) _fetchAddresses();
  }

  @override
  Widget build(BuildContext context) {
    final user = UserSession.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primary),
        title: const Text(
          'ĐỊA CHỈ GIAO HÀNG',
          style: TextStyle(
            fontFamily: 'serif',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 2,
            color: AppColors.primary,
          ),
        ),
        centerTitle: true,
      ),
      floatingActionButton: user == null
          ? null
          : FloatingActionButton.extended(
        onPressed: () => _openForm(),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_location_alt),
        label: const Text('Thêm địa chỉ'),
      ),
      body: user == null
          ? const Center(child: Text('Vui lòng đăng nhập'))
          : _isLoading
          ? const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      )
          : _addresses.isEmpty
          ? _buildEmpty()
          : RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _fetchAddresses,
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
          itemCount: _addresses.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            return AddressCard(
              address: _addresses[index],
              onEdit: () => _openForm(address: _addresses[index]),
              onDelete: () =>
                  _deleteAddress(_addresses[index]['id'].toString()),
              onSetDefault: () =>
                  _setDefault(_addresses[index]['id'].toString()),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_off_outlined,
              size: 64,
              color: AppColors.outlineVariant.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 16),
            const Text(
              'Chưa có địa chỉ giao hàng',
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Thêm địa chỉ để đặt hàng nhanh hơn',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}