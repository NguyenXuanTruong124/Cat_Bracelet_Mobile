import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../core/config/api_config.dart';
import '../../../core/theme/app_colors.dart';
import '../../profile/models/user_session.dart';
import '../../../core/services/api_helpers.dart';
import '../widgets/home_sections.dart';
import '../../cart/screens/voucher_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const Color _wine = AppColors.wine;
  static const Color _gold = AppColors.gold;
  static const Color _softRose = AppColors.softRose;

  void _logout() {
    UserSession.clear();
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (index) {
          if (index == 1) {
            Navigator.pushNamed(context, '/collection');
          } else if (index == 2) {
            Navigator.pushNamed(context, '/cart');
          } else if (index == 3) {
            Navigator.pushNamed(context, '/vouchers');
          } else if (index == 4) {
            Navigator.pushNamed(context, '/profile');
          }
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Trang chủ'),
          NavigationDestination(
            icon: Icon(Icons.shopping_bag_outlined),
            label: 'Sản phẩm',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_cart_outlined),
            label: 'Giỏ hàng',
          ),
          NavigationDestination(
            icon: Icon(Icons.local_activity_outlined),
            label: 'Voucher',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: 'Tài khoản',
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: _wine,
            expandedHeight: isMobile ? 70 : 85,
            floating: true,
            pinned: true,
            leading: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: _UserAvatarMenu(onLogout: _logout),
            ),
            title: Text(
              'Cat Bracelet',
              style: TextStyle(
                fontFamily: 'serif',
                fontWeight: FontWeight.bold,
                color: _gold,
                fontSize: isMobile ? 20 : 24,
              ),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                tooltip: 'Thông báo',
                onPressed: () => Navigator.pushNamed(context, '/notifications'),
                icon: const Icon(
                  Icons.notifications_outlined,
                  color: Colors.white,
                ),
              ),
              IconButton(
                tooltip: 'Tìm kiếm',
                onPressed: () => Navigator.pushNamed(context, '/search'),
                icon: const Icon(Icons.search, color: Colors.white),
              ),
              IconButton(
                tooltip: 'Giỏ hàng',
                onPressed: () => Navigator.pushNamed(context, '/cart'),
                icon: const Icon(
                  Icons.shopping_cart_outlined,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
          SliverToBoxAdapter(
            child: Container(
              color: _wine,
              padding: EdgeInsets.fromLTRB(
                isMobile ? 16 : 32,
                8,
                isMobile ? 16 : 32,
                18,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => Navigator.pushNamed(context, '/search'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _gold.withValues(alpha: 0.55),
                        ),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.search, color: _wine),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Tìm vòng tay, đá, chất liệu...',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Color(0xFF7B6664),
                                fontSize: 15,
                              ),
                            ),
                          ),
                          Icon(Icons.arrow_forward, color: _wine),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              color: _wine,
              padding: EdgeInsets.fromLTRB(
                isMobile ? 16 : 32,
                0,
                isMobile ? 16 : 32,
                24,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFAEF),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _gold.withValues(alpha: 0.6)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 62,
                          height: 62,
                          decoration: BoxDecoration(
                            color: _softRose,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.diamond, color: _wine),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Điểm thành viên hiện tại',
                                style: TextStyle(
                                  color: _wine,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                'Kiểm tra VIP và ưu đãi riêng của bạn',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () =>
                              Navigator.pushNamed(context, '/profile'),
                          child: const Text('Xem'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: HomeSections.buildHeroSection(),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: isMobile ? 20 : 30,
                horizontal: isMobile ? 16 : 32,
              ),
              child: Column(
                children: [
                  Text(
                    'Bộ sưu tập nổi bật',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: isMobile ? 22 : 28,
                      fontFamily: 'serif',
                      fontWeight: FontWeight.bold,
                      color: _wine,
                    ),
                  ),
                  SizedBox(height: isMobile ? 12 : 20),
                  SizedBox(
                    width: isMobile ? double.infinity : 260,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _wine,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 20 : 24,
                          vertical: isMobile ? 14 : 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pushNamed(context, '/collection');
                      },
                      child: Text(
                        'Xem bộ sưu tập',
                        style: TextStyle(
                          fontSize: isMobile ? 14 : 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: HomeSections.buildFeaturesSection(),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: HomeSections.buildAboutSection(),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: HomeSections.buildTestimonialsSection(),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: _HomeVoucherSection()),
          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: HomeSections.buildFooter(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UserAvatarMenu extends StatelessWidget {
  final VoidCallback onLogout;

  const _UserAvatarMenu({required this.onLogout});

  @override
  Widget build(BuildContext context) {
    final user = UserSession.currentUser;
    final avatar = user?.avatar;

    return PopupMenuButton<String>(
      tooltip: 'Tài khoản',
      offset: const Offset(0, 54),
      onSelected: (value) {
        if (value == 'profile') {
          Navigator.pushNamed(context, '/profile');
        } else if (value == 'orders') {
          Navigator.pushNamed(context, '/orders');
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
                        ? 'VIP: Chua co'
                        : 'VIP: ${user!.vipLevelName}',
                  ),
                  backgroundColor: _HomeScreenState._softRose,
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
        backgroundColor: _HomeScreenState._gold,
        backgroundImage: avatar != null && avatar.isNotEmpty
            ? NetworkImage(avatar)
            : null,
        child: avatar == null || avatar.isEmpty
            ? const Icon(Icons.person, color: Colors.white)
            : null,
      ),
    );
  }
}

class _HomeVoucherSection extends StatefulWidget {
  const _HomeVoucherSection();

  @override
  State<_HomeVoucherSection> createState() => _HomeVoucherSectionState();
}

class _HomeVoucherSectionState extends State<_HomeVoucherSection> {
  static const Color _wine = AppColors.wine;

  List<Map<String, dynamic>> _vouchers = [];

  @override
  void initState() {
    super.initState();
    _fetchVouchers();
  }

  Future<void> _fetchVouchers() async {
    try {
      final baseUrl = ApiConfig.getBaseUrl(context);
      final response = await http.get(Uri.parse('$baseUrl/vouchers'));
      if (response.statusCode != 200) {
        return;
      }

      final vouchers = decodeListPayload(jsonDecode(response.body))
          .whereType<Map<String, dynamic>>()
          .where(
            (voucher) =>
                (voucher['status'] ?? '').toString().toLowerCase() == 'active',
          )
          .take(2)
          .toList();

      if (!mounted) {
        return;
      }
      setState(() => _vouchers = vouchers);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    if (_vouchers.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      color: const Color(0xFFFFFAEF),
      padding: const EdgeInsets.fromLTRB(16, 28, 16, 16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.local_activity, color: _wine),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Ưu đãi đang có',
                      style: TextStyle(
                        color: _wine,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/vouchers'),
                    child: const Text('Xem tất cả'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ..._vouchers.map(
                (voucher) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: VoucherCard(voucher: voucher),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


}
