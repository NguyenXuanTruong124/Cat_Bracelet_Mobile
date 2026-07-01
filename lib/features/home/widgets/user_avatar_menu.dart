import 'package:flutter/material.dart';

import '../../../config/api_config.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/api_helpers.dart';
import '../../../core/theme/app_colors.dart';
import '../../profile/models/user_session.dart';

class UserAvatarMenu extends StatelessWidget {
  final VoidCallback onLogout;

  const UserAvatarMenu({super.key, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    final user = UserSession.currentUser;
    final avatar = user?.avatar;
    final avatarUrl = avatar != null && avatar.isNotEmpty
        ? buildImageUrl(ApiConfig.getBaseUrl(context), avatar)
        : null;

    return PopupMenuButton<String>(
      tooltip: 'Tài khoản',
      offset: const Offset(0, 54),
      onSelected: (value) {
        if (value == 'profile') {
          Navigator.pushNamed(context, AppRoutes.profile);
        } else if (value == 'orders') {
          Navigator.pushNamed(context, AppRoutes.orders);
        } else if (value == 'logout') {
          onLogout();
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          enabled: false,
          child: SizedBox(
            width: 240,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.fullName ?? 'Khách hàng',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(user?.email ?? 'Chưa đăng nhập'),
                const SizedBox(height: 8),
                Chip(
                  label: Text(
                    user?.vipLevelName == null
                        ? 'VIP: Chưa có'
                        : 'VIP: ${user!.vipLevelName}',
                  ),
                  backgroundColor: AppColors.softRose,
                ),
              ],
            ),
          ),
        ),

        const PopupMenuDivider(),

        const PopupMenuItem(
          value: 'profile',
          child: ListTile(
            dense: true,
            leading: Icon(Icons.manage_accounts),
            title: Text('Tùy chỉnh thông tin'),
          ),
        ),

        const PopupMenuItem(
          value: 'orders',
          child: ListTile(
            dense: true,
            leading: Icon(Icons.receipt_long),
            title: Text('Lịch sử đơn hàng'),
          ),
        ),

        const PopupMenuItem(
          value: 'logout',
          child: ListTile(
            dense: true,
            leading: Icon(Icons.logout),
            title: Text('Đăng xuất'),
          ),
        ),
      ],
      child: CircleAvatar(
        radius: 19,
        backgroundColor: AppColors.gold,
        backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
        child: avatarUrl == null
            ? const Icon(Icons.person, color: Colors.white)
            : null,
      ),
    );
  }
}
