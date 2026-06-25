import 'package:flutter/material.dart';

import '../../core/app_routes.dart';
import '../../core/app_theme.dart';
import '../../services/auth_service.dart';
import '../../services/sim_service.dart';
import '../../services/order_service.dart';
import '../../widgets/app_logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _openNextScreen();
  }

  Future<void> _openNextScreen() async {
    debugPrint('[SplashScreen] Bắt đầu khôi phục phiên đăng nhập...');
    final user = await AuthService.instance.restoreSession();
    debugPrint('[SplashScreen] Kết quả khôi phục: ${user != null ? "Thành công (User: ${user.fullName})" : "Chưa đăng nhập"}');
    
    try {
      debugPrint('[SplashScreen] Đang tải danh sách SIM...');
      await SimService.instance.loadSims();
      debugPrint('[SplashScreen] Tải danh sách SIM hoàn tất.');

      if (user != null) {
        debugPrint('[SplashScreen] Đang tải danh sách đơn hàng của người dùng...');
        await OrderService.instance.loadOrders();
        debugPrint('[SplashScreen] Tải đơn hàng hoàn tất.');
      }
    } catch (e, stack) {
      debugPrint('[SplashScreen] LỖI khi tải dữ liệu khởi tạo: $e');
      debugPrint(stack.toString());
    }

    if (!mounted) {
      return;
    }

    debugPrint('[SplashScreen] Điều hướng sang màn hình: ${user == null ? "Xác thực (Auth)" : "Trang chủ (Home)"}');
    Navigator.of(
      context,
    ).pushReplacementNamed(user == null ? AppRoutes.auth : AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppPalette.red, AppPalette.redDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28, 36, 28, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.18),
                      ),
                    ),
                    child: const Text(
                      'SIM SỐ ĐẸP',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.92, end: 1),
                  duration: const Duration(milliseconds: 520),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Transform.scale(scale: value, child: child);
                  },
                  child: const AppLogo(size: 220, showText: true, onDark: true),
                ),
                const SizedBox(height: 18),
                Text(
                  'Kho SIM đẹp cho kinh doanh và cá nhân',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                  ),
                ),
                const Spacer(),
                const Center(
                  child: SizedBox(
                    width: 30,
                    height: 30,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Đang kiểm tra phiên đăng nhập',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.82),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
