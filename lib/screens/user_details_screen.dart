import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/user_session.dart';
import '../services/api_helpers.dart';
import '../theme/app_colors.dart';

class UserDetailsScreen extends StatefulWidget {
  const UserDetailsScreen({super.key});

  @override
  State<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  static const Color _wine = Color(0xFF902021);

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _avatarController = TextEditingController();
  final _avatarPathController = TextEditingController();

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
    _emailController.dispose();
    _phoneController.dispose();
    _avatarController.dispose();
    _avatarPathController.dispose();
    super.dispose();
  }

  void _fill(AppUser? user) {
    _nameController.text = user?.fullName ?? '';
    _emailController.text = user?.email ?? '';
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
          'email': _emailController.text.trim(),
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
        ).showSnackBar(const SnackBar(content: Text('Da cap nhat thong tin')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Loi cap nhat: ${response.statusCode}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _uploadAvatarFromPath() async {
    final user = UserSession.currentUser;
    final filePath = _avatarPathController.text.trim();
    if (user == null || filePath.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Nhap duong dan file anh')));
      return;
    }

    final file = File(filePath);
    if (!file.existsSync()) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Khong tim thay file anh')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final baseUrl = ApiConfig.getBaseUrl(context);
      final request = http.MultipartRequest(
        'PATCH',
        Uri.parse('$baseUrl/user/profile/${user.id}'),
      );
      request.headers.addAll(apiHeaders());
      request.fields.addAll({
        'fullName': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
      });
      request.files.add(await http.MultipartFile.fromPath('avatar', filePath));

      final response = await request.send();
      final body = await response.stream.bytesToString();

      if (!mounted) {
        return;
      }

      if (response.statusCode == 200) {
        final decoded = jsonDecode(body);
        if (decoded is Map<String, dynamic>) {
          UserSession.currentUser = AppUser.fromJson(decoded);
          _fill(UserSession.currentUser);
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Da upload avatar')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload avatar loi: ${response.statusCode}')),
        );
      }
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
        title: const Text('Thong tin tai khoan'),
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
                    ? 'VIP: Chua co'
                    : 'VIP: ${user!.vipLevelName}',
              ),
            ),
          ),
          if ((user?.vipBenefits ?? '').isNotEmpty)
            Center(child: Text(user!.vipBenefits!)),
          const SizedBox(height: 20),
          _field(_nameController, 'Ho ten', Icons.person),
          _field(_emailController, 'Email', Icons.mail),
          _field(_phoneController, 'So dien thoai', Icons.phone),
          _field(_avatarController, 'Avatar URL', Icons.image),
          _field(
            _avatarPathController,
            'Duong dan file avatar tren may',
            Icons.upload_file,
          ),
          OutlinedButton.icon(
            onPressed: _isLoading ? null : _uploadAvatarFromPath,
            icon: const Icon(Icons.upload),
            label: const Text('Upload avatar tu may'),
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
            label: const Text('Luu thong tin'),
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
