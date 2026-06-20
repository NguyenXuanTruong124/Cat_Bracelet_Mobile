import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import 'package:cat_bracelet_mobile/features/profile/models/user_session.dart';
import '../widgets/home_voucher_section.dart';
import '../widgets/user_avatar_menu.dart';
import '../widgets/home_search_bar.dart';
import '../widgets/member_card.dart';
import '../widgets/hero_section.dart';
import '../widgets/features_section.dart';
import '../widgets/about_section.dart';
import '../widgets/testimonials_section.dart';
import '../widgets/footer_section.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const Color _wine = AppColors.wine;
  static const Color _gold = AppColors.gold;

  void _logout() {
    UserSession.clear();
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
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
              child: UserAvatarMenu(onLogout: _logout),
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
                icon: const Icon(Icons.notifications_outlined, color: Colors.white),
              ),
              IconButton(
                tooltip: 'Tìm kiếm',
                onPressed: () => Navigator.pushNamed(context, '/search'),
                icon: const Icon(Icons.search, color: Colors.white),
              ),
              IconButton(
                tooltip: 'Giỏ hàng',
                onPressed: () => Navigator.pushNamed(context, '/cart'),
                icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
              ),
              const SizedBox(width: 8),
            ],
          ),

          const SliverToBoxAdapter(child: HomeSearchBar()),

          const SliverToBoxAdapter(child: MemberCard()),

          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: const HeroSection(),
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
                      onPressed: () => Navigator.pushNamed(context, '/collection'),
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
                child: const FeaturesSection(),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: const AboutSection(),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: const TestimonialsSection(),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: HomeVoucherSection()),

          const SliverToBoxAdapter(child: FooterSection()),
        ],
      ),
    );
  }
}