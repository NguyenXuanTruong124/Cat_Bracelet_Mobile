import 'package:flutter/material.dart';
import '../../features/address/screens/address_form_screen.dart';
import '../../features/address/screens/delivery_address_screen.dart';
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
    '/address-form': (context) => const AddressFormScreen(),
    '/payment-success': (context) => const PaymentScreen(),
    '/support': (context) => const SupportTicketScreen(),
  };

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    if (settings.name == '/order-tracking' ||
        settings.name == '/order-detail') {
      final orderId = settings.arguments as String? ?? '';
      return MaterialPageRoute(
        builder: (context) => OrderDetailScreen(orderId: orderId),
      );
    }
    if (settings.name == '/chat-support') {
      final ticket = settings.arguments as SupportTicket;
      return MaterialPageRoute(
        builder: (context) => ChatSupportScreen(ticket: ticket),
      );
    }
    return null;
  }
}
