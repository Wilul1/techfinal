import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/product_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/wishlist_provider.dart';
import 'providers/shipping_provider.dart';
import 'providers/payment_provider.dart';
import 'providers/order_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/main_screen.dart';
import 'screens/profile/wishlist_screen.dart';
import 'screens/payment/payment_methods_screen.dart';
import 'screens/shipping-address/shipping_address_screen.dart';
import 'screens/orders/checkout_screen.dart';
import 'screens/orders/orders_screen.dart';
import 'screens/splash_screen.dart';
import 'utils/colors.dart';
import 'config/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(
          create: (_) {
            final wishlistProvider = WishlistProvider();
            wishlistProvider.loadWishlist();
            return wishlistProvider;
          },
        ),
        ChangeNotifierProvider(
          create: (_) {
            final shippingProvider = ShippingProvider();
            shippingProvider.loadAddresses();
            return shippingProvider;
          },
        ),
        ChangeNotifierProvider(
          create: (_) {
            final paymentProvider = PaymentProvider();
            paymentProvider.loadPaymentMethods();
            return paymentProvider;
          },
        ),
        ChangeNotifierProvider(
          create: (_) {
            final orderProvider = OrderProvider();
            orderProvider.loadOrders();
            return orderProvider;
          },
        ),
      ],
      child: MaterialApp(
        title: 'TechHub',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: AppColors.primary,
          scaffoldBackgroundColor: AppColors.background,
          fontFamily: 'Inter',
          useMaterial3: true,
        ),
        home: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            // Show loading screen while checking authentication
            if (authProvider.isLoading) {
              return const SplashScreen();
            }

            // Navigate based on authentication status
            if (authProvider.isAuthenticated) {
              return const MainScreen();
            } else {
              return const LoginScreen();
            }
          },
        ),
        onGenerateRoute: AppRoutes.generateRoute,
        routes: {
          '/login': (context) => const LoginScreen(),
          '/main': (context) => const MainScreen(),
          '/wishlist': (context) => const WishlistScreen(),
          '/payment-methods': (context) => const PaymentMethodsScreen(),
          '/shipping-address': (context) => const ShippingAddressScreen(),
          '/checkout': (context) => const CheckoutScreen(),
          '/orders': (context) => const OrdersScreen(),
        },
      ),
    );
  }
}
