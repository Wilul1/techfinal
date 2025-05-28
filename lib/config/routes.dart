import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/main_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/cart/cart_screen.dart';
import '../screens/admin/admin_dashboard.dart';
import '../screens/admin/admin_account_creator.dart';
import '../screens/products/product_detail_screen.dart';
import '../screens/orders/checkout_screen.dart';
import '../screens/orders/order_confirmation_screen.dart';
import '../screens/orders/orders_screen.dart'; // ✅ Fixed import
import '../screens/orders/order_detail_screen.dart';
import '../models/order.dart'; // ✅ Add this import for Order class

class AppRoutes {
  // Route Names
  static const String splash = '/splash';
  static const String home = '/home';
  static const String main = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String profile = '/profile';
  static const String cart = '/cart';
  static const String admin = '/admin';
  static const String adminCreator = '/admin-creator';
  static const String productDetail = '/product-detail';
  static const String checkout = '/checkout';
  static const String orderConfirmation = '/order-confirmation';
  static const String orders = '/orders';
  static const String orderDetail = '/order-detail';

  // Route Generator
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return _buildRoute(const SplashScreen(), settings);
      case main:
        return _buildRoute(const MainScreen(), settings);
      case home:
        return _buildRoute(const HomeScreen(), settings);
      case login:
        return _buildRoute(const LoginScreen(), settings);
      case register:
        return _buildRoute(const RegisterScreen(), settings);
      case profile:
        return _buildRoute(const ProfileScreen(), settings);
      case cart:
        return _buildRoute(const CartScreen(), settings);
      case admin:
        return _buildRoute(const AdminDashboard(), settings);
      case adminCreator:
        return _buildRoute(const AdminAccountCreator(), settings);
      case productDetail:
        final productId = settings.arguments as String? ?? '';
        return _buildRoute(ProductDetailScreen(productId: productId), settings);
      case checkout:
        return MaterialPageRoute(
          builder: (_) => const CheckoutScreen(),
          settings: settings,
        );
      case orderConfirmation:
        final order = settings.arguments as Order; // ✅ Now Order is imported
        return MaterialPageRoute(
          builder: (_) => OrderConfirmationScreen(order: order),
          settings: settings,
        );
      case orders: // ✅ Fixed route name
        return MaterialPageRoute(
          builder: (_) => const OrdersScreen(), // ✅ Fixed class name
          settings: settings,
        );
      case orderDetail:
        final order = settings.arguments as Order; // ✅ Now Order is imported
        return MaterialPageRoute(
          builder: (_) => OrderDetailScreen(order: order),
          settings: settings,
        );
      default:
        return _buildRoute(
          const Scaffold(
            body: Center(child: Text('Page not found')),
          ),
          settings,
        );
    }
  }

  static PageRoute _buildRoute(Widget child, RouteSettings settings) {
    return MaterialPageRoute(
      settings: settings,
      builder: (context) => child,
    );
  }
}