import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';
import '../../../config/api_config.dart';
import '../models/user_session.dart';
import '../../../core/services/api_helpers.dart';
import '../../../core/theme/app_colors.dart';

class UserDetailsScreen extends StatefulWidget {
  const UserDetailsScreen({super.key});

  @override
  State<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  static const Color _wine = AppColors.wine;

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _avatarController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fill(UserSession.currentUser);
    _fetchProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _avatarController.dispose();
    super.dispose();
  }

  void _fill(AppUser? user) {
    _nameController.text = user?.fullName ?? '';
    _phoneController.text = user?.phone ?? '';
    _avatarController.text = user?.avatar ?? '';
  }

  Future<void> _fetchProfile() async {
    final user = UserSession.currentUser;
    if (user == null) {
      return;
    }

    setState(() => _isLoading = true);
    try {
      final baseUrl = ApiConfig.getBaseUrl(context);
      final response = await http.get(
        Uri.parse('$baseUrl/user/profile/${user.id}'),
        headers: apiHeaders(),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          UserSession.currentUser = AppUser.fromJson(decoded);
          _fill(UserSession.currentUser);
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveProfile() async {
    final user = UserSession.currentUser;
    if (user == null) {
      return;
    }

    setState(() => _isLoading = true);
    try {
      final baseUrl = ApiConfig.getBaseUrl(context);
      final response = await http.patch(
        Uri.parse('$baseUrl/user/profile/${user.id}'),
        headers: apiHeaders(json: true),
        body: jsonEncode({
          'fullName': _nameController.text.trim(),
          'phone': _phoneController.text.trim(),
          'avatar': _avatarController.text.trim(),
        }),
      );

      if (!mounted) {
        return;
      }

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          UserSession.currentUser = AppUser.fromJson(decoded);
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Đã cập nhật thông tin')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi cập nhật: ${response.statusCode}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _uploadAvatar() async {
    final user = UserSession.currentUser;
    if (user == null) return;

    final picker = ImagePicker();

    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image == null) return;

    setState(() => _isLoading = true);

    try {
      final baseUrl = ApiConfig.getBaseUrl(context);

      final request = http.MultipartRequest(
        'PATCH',
        Uri.parse('$baseUrl/user/${user.id}/avatar'),
      );

      request.headers.addAll(apiHeaders());

      request.fields['type'] = 'A';

      final path = image.path.toLowerCase();

      MediaType mediaType;

      if (path.endsWith('.png')) {
        mediaType = MediaType('image', 'png');
      } else if (path.endsWith('.jpg') || path.endsWith('.jpeg')) {
        mediaType = MediaType('image', 'jpeg');
      } else if (path.endsWith('.webp')) {
        mediaType = MediaType('image', 'webp');
      } else {
        throw Exception('Định dạng ảnh không hỗ trợ');
      }

      request.files.add(
        await http.MultipartFile.fromPath(
          'avatar',
          image.path,
          contentType: mediaType,
        ),
      );

      final response = await request.send();
      final body = await response.stream.bytesToString();

      debugPrint('STATUS: ${response.statusCode}');
      debugPrint('BODY: $body');

      if (!mounted) return;

      if (response.statusCode == 200) {
        await _fetchProfile();

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Đã upload avatar')));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(body)));
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = UserSession.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông tin tài khoản'),
        backgroundColor: _wine,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _menuTile(
            icon: Icons.notifications_outlined,
            title: 'Thông báo',
            onTap: () => Navigator.pushNamed(context, '/notifications'),
          ),
          _menuTile(
            icon: Icons.receipt_long_outlined,
            title: 'Đơn hàng của tôi',
            onTap: () => Navigator.pushNamed(context, '/orders'),
          ),
          _menuTile(
            icon: Icons.location_on_outlined,
            title: 'Địa chỉ giao hàng',
            onTap: () => Navigator.pushNamed(context, '/addresses'),
          ),
          const Divider(height: 32),
          Center(
            child: CircleAvatar(
              radius: 46,
              backgroundImage: (_avatarController.text.isNotEmpty)
                  ? NetworkImage(_avatarController.text)
                  : null,
              child: _avatarController.text.isEmpty
                  ? const Icon(Icons.person, size: 44)
                  : null,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Chip(
              label: Text(
                user?.vipLevelName == null
                    ? 'VIP: Không có'
                    : 'VIP: ${user!.vipLevelName}',
              ),
            ),
          ),
          if ((user?.vipBenefits ?? '').isNotEmpty)
            Center(child: Text(user!.vipBenefits!)),
          const SizedBox(height: 20),
          _field(_nameController, 'Họ tên', Icons.person),
          _field(_phoneController, 'Số điện thoại', Icons.phone),

          OutlinedButton.icon(
            onPressed: _isLoading ? null : _uploadAvatar,
            icon: const Icon(Icons.upload),
            label: const Text('Chọn ảnh đại diện'),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: _wine,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(50),
            ),
            onPressed: _isLoading ? null : _saveProfile,
            icon: _isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save),
            label: const Text('Lưu thông tin'),
          ),
        ],
      ),
    );
  }

  Widget _field(TextEditingController controller, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Widget _menuTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      tileColor: Colors.white,
    );
  }
}
