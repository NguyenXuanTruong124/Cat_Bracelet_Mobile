import 'package:flutter/material.dart';
import '../../features/address/screens/address_form_screen.dart';
import '../../features/address/screens/delivery_address_screen.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/otp_screen.dart';
import '../../features/collection/screens/collection_screen.dart';
import '../../features/cart/screens/cart_screen.dart';
import '../../features/checkout/screens/checkout_screen.dart';
import '../../features/order_history/screens/order_history_screen.dart';
import '../../features/search/screen/search_screen.dart';
import '../../features/profile/screens/user_details_screen.dart';
import '../../features/voucher/screens/voucher_screen.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/notification/screen/notification_screen.dart';
import '../../features/order_detail/screens/order_detail_screen.dart';
import '../../features/payment/screens/payment_screen.dart';

import '../../features/support/screens/support_ticket_screen.dart';
import '../../features/support/screens/chat_support_screen.dart';
import '../../features/support/models/support_ticket.dart';
import '../../features/shop/screens/shop_location_screen.dart';

class AppRoutes {
  static const splash = '/splash';
  static const login = '/login';
  static const register = '/register';
  static const otp = '/otp';
  static const order = '/order';
  static const home = '/home';
  static const collection = '/collection';
  static const profile = '/profile';
  static const cart = '/cart';
  static const checkout = '/checkout';
  static const orders = '/orders';
  static const search = '/search';
  static const vouchers = '/vouchers';
  static const forgotPassword = '/forgot-password';
  static const notifications = '/notifications';
  static const addresses = '/addresses';
  static const addressForm = '/address-form';
  static const paymentSuccess = '/payment-success';
  static const support = '/support';
  static const shops = '/shops';
  static const orderTracking = '/order-tracking';
  static const orderDetail = '/order-detail';
  static const chatSupport = '/chat-support';

  static Map<String, WidgetBuilder> routes = {
    splash: (context) => const SplashScreen(),
    '/': (context) => const SplashScreen(),
    home : (context) => const HomeScreen(),
    register: (context) => const RegisterScreen(),
    otp: (context) => const OtpScreen(),
    collection: (context) => const CollectionScreen(),
    profile: (context) => const UserDetailsScreen(),
    cart: (context) => const CartScreen(),
    checkout: (context) => const CheckoutScreen(),
    orders: (context) => const OrderHistoryScreen(),
    search: (context) => const SearchScreen(),
    vouchers: (context) => const VoucherScreen(),
    forgotPassword: (context) => const ForgotPasswordScreen(),
    notifications: (context) => const NotificationScreen(),
    addresses: (context) => const DeliveryAddressScreen(),
    addressForm: (context) => const AddressFormScreen(),
    shops: (context) => const ShopLocationScreen(),
    paymentSuccess: (context) => const PaymentScreen(),
    support: (context) => const SupportTicketScreen(),
    login : (context) => const LoginScreen(),
  };

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    if (settings.name == orderTracking ||
        settings.name == orderDetail) {
      final orderId = settings.arguments as String? ?? '';
      return MaterialPageRoute(
        builder: (context) => OrderDetailScreen(orderId: orderId),
      );
    }
    if (settings.name == chatSupport) {
      final ticket = settings.arguments as SupportTicket;
      return MaterialPageRoute(
        builder: (context) => ChatSupportScreen(ticket: ticket),
      );
    }
    return null;
  }
}
