import 'package:flutter/material.dart';
import 'features/home/screens/home_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/register_screen.dart';
import 'features/auth/screens/otp_screen.dart';
import 'features/product/screens/collection_screen.dart';
import 'features/cart/screens/cart_screen.dart';
import 'features/order/screens/checkout_screen.dart';
import 'features/order/screens/order_history_screen.dart';
import 'features/search/screen/search_screen.dart';
import 'features/profile/screens/user_details_screen.dart';
import 'features/voucher/screens/voucher_screen.dart';
import 'features/auth/screens/forgot_password_screen.dart';
import 'features/order/screens/order_tracking_screen.dart';
import 'features/profile/screens/delivery_address_screen.dart';
import 'features/notification/screen/notification_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
  runApp(const CatBraceletApp());
}

class CatBraceletApp extends StatelessWidget {
  const CatBraceletApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Cat Bracelet',
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF8F2022),
            ),
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
                builder: (context) =>
                    OrderTrackingScreen(orderId: orderId),
              );
            }
            return null;
          },
        );
      },
    );
  }
}
