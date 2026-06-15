import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'features/home/screens/home_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/register_screen.dart';
import 'features/auth/screens/otp_screen.dart';
import 'features/product/screens/collection_screen.dart';
import 'features/cart/screens/cart_screen.dart';
import 'features/cart/screens/checkout_screen.dart';
import 'features/order/screens/order_history_screen.dart';
import 'features/search/screen/search_screen.dart';
import 'features/profile/screens/user_details_screen.dart';
import 'features/cart/screens/voucher_screen.dart';
import 'features/auth/screens/forgot_password_screen.dart';
import 'features/order/screens/order_tracking_screen.dart';
import 'features/cart/screens/delivery_address_screen.dart';
import 'features/notification/screen/notification_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
  runApp(const CatBraceletApp());
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class CatBraceletApp extends StatefulWidget {
  const CatBraceletApp({super.key});

  @override
  State<CatBraceletApp> createState() => _CatBraceletAppState();
}

class _CatBraceletAppState extends State<CatBraceletApp> {
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initDeepLinks() async {
    final appLinks = AppLinks();
    _linkSubscription = appLinks.uriLinkStream.listen(_handleDeepLink);

    try {
      final initialUri = await appLinks.getInitialLink();
      if (mounted && initialUri != null) {
        _handleDeepLink(initialUri);
      }
    } catch (_) {
      // Ignore malformed initial links; normal app startup should continue.
    }
  }

  void _handleDeepLink(Uri uri) {
    if (uri.scheme != 'catbracelet') {
      return;
    }

    final isPaymentLink = uri.host == 'payment' || uri.path.contains('payment');
    if (!isPaymentLink) {
      return;
    }

    final status = uri.queryParameters['status']?.toLowerCase();
    final result = uri.path.contains('cancel') || status == 'cancel'
        ? 'cancel'
        : 'success';
    final orderId =
        uri.queryParameters['orderId'] ??
        uri.queryParameters['orderCode'] ??
        uri.queryParameters['id'];

    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      '/payment',
      (route) => route.settings.name == '/home',
      arguments: {
        'result': result,
        'order': {
          if (orderId != null) 'id': orderId,
        },
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Cat Bracelet',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF8F2022)),
        scaffoldBackgroundColor: const Color(0xFFFFF6F1),
        fontFamily: 'Roboto',
      ),
      initialRoute: '/',
      routes: {
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
        '/addresses': (context) => const DeliveryAddressScreen(),
        '/notifications': (context) => const NotificationScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/order-tracking') {
          final orderId = settings.arguments as String? ?? '';
          return MaterialPageRoute(
            builder: (context) => OrderTrackingScreen(orderId: orderId),
          );
        }
        return null;
      },
    );
  }
}
