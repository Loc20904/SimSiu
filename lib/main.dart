import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';

import 'core/app_routes.dart';
import 'core/app_theme.dart';
import 'screens/admin/admin_screen.dart';
import 'screens/auth/login_register_screen.dart';
import 'screens/chat/chat_screen.dart';
import 'screens/checkout/checkout_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/orders/my_orders_screen.dart';
import 'screens/sim_detail/sim_detail_screen.dart';
import 'screens/sim_list/sim_list_screen.dart';
import 'screens/splash/splash_screen.dart';
import 'services/sim_service.dart';

void main() {
  runApp(const SimDepApp());
}

class SimDepApp extends StatefulWidget {
  const SimDepApp({super.key});

  @override
  State<SimDepApp> createState() => _SimDepAppState();
}

class _SimDepAppState extends State<SimDepApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    _listenForPaymentLinks();
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  void _listenForPaymentLinks() {
    final appLinks = AppLinks();
    _linkSubscription = appLinks.uriLinkStream.listen(_handleIncomingLink);
    appLinks.getInitialLink().then((uri) {
      if (uri != null) {
        _handleIncomingLink(uri);
      }
    });
  }

  Future<void> _handleIncomingLink(Uri uri) async {
    if (uri.scheme != 'simsiu' || uri.host != 'payment') {
      return;
    }

    await SimService.instance.fetchSims(force: true);
    final navigator = _navigatorKey.currentState;
    if (navigator == null) {
      return;
    }

    final simId = uri.queryParameters['simId'];
    if (uri.path.contains('cancel') && simId != null && simId.isNotEmpty) {
      navigator.pushNamedAndRemoveUntil(
        AppRoutes.simDetail,
        (route) => route.settings.name == AppRoutes.home,
        arguments: simId,
      );
      return;
    }

    if (uri.path.contains('success')) {
      navigator.pushNamedAndRemoveUntil(
        AppRoutes.myOrders,
        (route) => route.settings.name == AppRoutes.home,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: MaterialApp(
        navigatorKey: _navigatorKey,
        debugShowCheckedModeBanner: false,
        title: 'Viettal',
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
          AppRoutes.chat: (_) => const ChatScreen(),
        },
      ),
    );
  }
}
