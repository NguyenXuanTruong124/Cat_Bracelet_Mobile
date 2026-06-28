import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import 'package:cat_bracelet_mobile/features/profile/models/user_session.dart';
import '../../notification/services/notification_service.dart';

import '../widgets/home_voucher_section.dart';
import '../widgets/user_avatar_menu.dart';
import '../widgets/home_search_bar.dart';
import '../widgets/hero_section.dart';
import '../widgets/features_section.dart';
import '../widgets/about_section.dart';
import '../widgets/testimonials_section.dart';
import '../widgets/footer_section.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cat_bracelet_mobile/features/cart/widgets/cart_icon_badge.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const Color _wine = AppColors.wine;
  static const Color _gold = AppColors.gold;

  late NotificationService _notificationService;

  int _unreadCount = 0;

  Future<void> _logout() async {
    await UserSession.clear();
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _notificationService = NotificationService(context);

    _loadUnreadCount();
  }

  Future<void> _loadUnreadCount() async {
    final count = await _notificationService.getUnreadCount();

    if (!mounted) return;

    setState(() {
      _unreadCount = count;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F6F2),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        backgroundColor: Colors.white,
        indicatorColor: _wine.withValues(alpha: 0.12),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        onDestinationSelected: (index) {
          if (index == 1) {
            Navigator.pushNamed(context, '/collection');
          } else if (index == 2) {
            Navigator.pushNamed(context, '/shops');
          } else if (index == 3) {
            Navigator.pushNamed(context, '/support');
          } else if (index == 4) {
            Navigator.pushNamed(context, '/profile');
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Trang chủ',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_bag_outlined),
            selectedIcon: Icon(Icons.shopping_bag),
            label: 'Sản phẩm',
          ),
          NavigationDestination(
            icon: Icon(Icons.diamond_outlined),
            selectedIcon: Icon(Icons.diamond),
            label: 'Cửa hàng',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_outlined),
            selectedIcon: Icon(Icons.chat),
            label: 'Hỗ trợ',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Tài khoản',
          ),
        ],
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              toolbarHeight: 60.h,
              expandedHeight: 60.h,
              floating: true,
              pinned: true,
              elevation: 0,
              backgroundColor: _wine,
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_wine, _wine.withValues(alpha: 0.92)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              leading: Padding(
                padding: EdgeInsets.only(left: 12.w),
                child: UserAvatarMenu(onLogout: _logout),
              ),
              centerTitle: true,
              title: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'Cat Bracelet',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontWeight: FontWeight.bold,
                    color: _gold,
                    fontSize: 24.sp,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              actions: [
                Badge(
                  isLabelVisible: _unreadCount > 0,
                  label: Text(_unreadCount.toString()),
                  child: IconButton(
                    tooltip: 'Thông báo',
                    onPressed: () async {
                      await Navigator.pushNamed(context, '/notifications');

                      _loadUnreadCount();
                    },
                    icon: const Icon(
                      Icons.notifications_outlined,
                      color: Colors.white,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Tìm kiếm',
                  onPressed: () => Navigator.pushNamed(context, '/search'),
                  icon: const Icon(Icons.search, color: Colors.white),
                ),
                const CartIconBadge(),
                SizedBox(width: 8.w),
              ],
            ),

            SliverToBoxAdapter(child: SizedBox(height: 4.h)),

            const SliverToBoxAdapter(child: HomeSearchBar()),

            SliverToBoxAdapter(child: SizedBox(height: 12.h)),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const HeroSection(),
                    ),
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 36)),

            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  children: [
                    Text(
                      'Bộ sưu tập nổi bật',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28.sp,
                        fontFamily: 'serif',
                        fontWeight: FontWeight.bold,
                        color: _wine,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Những mẫu vòng tay dành riêng cho người yêu mèo',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 14.sp,
                      ),
                    ),
                    SizedBox(height: 24.h),
                    SizedBox(
                      width: 280.w,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/collection');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _wine,
                          foregroundColor: Colors.white,
                          elevation: 4,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                        ),
                        child: Text(
                          'Khám phá bộ sưu tập',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15.sp,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 40)),

            SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: const FeaturesSection(),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: const AboutSection(),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: const TestimonialsSection(),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            const SliverToBoxAdapter(child: HomeVoucherSection()),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            const SliverToBoxAdapter(child: FooterSection()),
          ],
        ),
      ),
    );
  }
}
