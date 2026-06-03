import 'package:flutter/material.dart';

import 'core/app_routes.dart';
import 'core/app_theme.dart';
import 'screens/admin/admin_screen.dart';
import 'screens/auth/login_register_screen.dart';
import 'screens/checkout/checkout_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/orders/my_orders_screen.dart';
import 'screens/sim_detail/sim_detail_screen.dart';
import 'screens/sim_list/sim_list_screen.dart';
import 'screens/splash/splash_screen.dart';

void main() {
  runApp(const SimDepApp());
}

class SimDepApp extends StatelessWidget {
  const SimDepApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sim Dep',
      theme: AppTheme.light(),
      initialRoute: AppRoutes.splash,
      routes: {
        AppRoutes.splash: (_) => const SplashScreen(),
        AppRoutes.auth: (_) => const LoginRegisterScreen(),
        AppRoutes.home: (_) => const HomeScreen(),
        AppRoutes.simList: (_) => const SimListScreen(),
        AppRoutes.simDetail: (_) => const SimDetailScreen(),
        AppRoutes.checkout: (_) => const CheckoutScreen(),
        AppRoutes.myOrders: (_) => const MyOrdersScreen(),
        AppRoutes.admin: (_) => const AdminScreen(),
      },
    );
  }
}
