import 'package:flutter/material.dart';
import '../../features/address/screens/delivery_address_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/otp_screen.dart';
import '../../features/collection/screens/collection_screen.dart';
import '../../features/cart/screens/cart_screen.dart';
import '../../features/order/screens/checkout_screen.dart';
import '../../features/order/screens/order_history_screen.dart';
import '../../features/search/screen/search_screen.dart';
import '../../features/profile/screens/user_details_screen.dart';
import '../../features/voucher/screens/voucher_screen.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/order/screens/order_tracking_screen.dart';
import '../../features/notification/screen/notification_screen.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> routes = {
    '/': (context) => const LoginScreen(),
    '/home': (context) => const HomeScreen(),
    '/register': (context) => const RegisterScreen(),
    '/otp': (context) => const OtpScreen(),
    '/collection': (context) => const CollectionScreen(),
    '/profile': (context) => const UserDetailsScreen(),
    '/cart': (context) => const CartScreen(),
    '/checkout': (context) => const CheckoutScreen(),
    '/orders': (context) => const OrderHistoryScreen(),
    '/search': (context) => const SearchScreen(),
    '/vouchers': (context) => const VoucherScreen(),
    '/forgot-password': (context) => const ForgotPasswordScreen(),
    '/notifications': (context) => const NotificationScreen(),
    '/addresses': (context) => const DeliveryAddressScreen(),
  };

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    if (settings.name == '/order-tracking') {
      final orderId = settings.arguments as String? ?? '';
      return MaterialPageRoute(
        builder: (context) => OrderTrackingScreen(orderId: orderId),
      );
    }
    return null;
  }
}


