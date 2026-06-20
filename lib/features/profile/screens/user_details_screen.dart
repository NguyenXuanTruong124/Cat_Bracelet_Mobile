import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/app_user.dart';
import '../models/user_session.dart';
import '../services/user_service.dart';
import '../widgets/menu_tile.dart';
import '../widgets/user_avatar.dart';
import '../widgets/user_info_form.dart';
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

    _loadProfile();

  }

  void _fill(AppUser? user) {
    _nameController.text = user?.fullName ?? '';
    _phoneController.text = user?.phone ?? '';
    _avatarController.text = user?.avatar ?? '';
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    final user = await UserService.fetchProfile(context);
    if (user != null) {
      UserSession.currentUser = user;
      _fill(user);
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);
    final user = await UserService.saveProfile(
      context,
      fullName: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      avatar: _avatarController.text.trim(),
    );
    if (user != null) {
      UserSession.currentUser = user;
      _showSnackBar('Đã cập nhật thông tin');
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _uploadAvatar() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (image == null) return;

    setState(() => _isLoading = true);
    final success = await UserService.uploadAvatar(context, image);
    if (success) {
      await _loadProfile();
      _showSnackBar('Đã upload avatar');
    }
    if (mounted) setState(() => _isLoading = false);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
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
          MenuTile(
            icon: Icons.notifications_outlined,
            title: 'Thông báo',
            onTap: () => Navigator.pushNamed(context, '/notifications'),
          ),
          MenuTile(
            icon: Icons.receipt_long_outlined,
            title: 'Đơn hàng của tôi',
            onTap: () => Navigator.pushNamed(context, '/orders'),
          ),
          MenuTile(
            icon: Icons.location_on_outlined,
            title: 'Địa chỉ giao hàng',
            onTap: () => Navigator.pushNamed(context, '/addresses'),
          ),
          const Divider(height: 32),

          // Avatar
          Center(child: UserAvatar(avatarUrl: _avatarController.text)),
          const SizedBox(height: 16),

          // VIP chip
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

          // Form thông tin (Họ tên, SĐT, Email read-only)
          UserInfoForm(
            nameController: _nameController,
            phoneController: _phoneController,
            email: user?.email ?? '',
          ),

          // Upload avatar
          OutlinedButton.icon(
            onPressed: _isLoading ? null : _uploadAvatar,
            icon: const Icon(Icons.upload),
            label: const Text('Chọn ảnh đại diện'),
          ),
          const SizedBox(height: 20),

          // Save profile
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

}
