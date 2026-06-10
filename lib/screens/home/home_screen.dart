import 'package:flutter/material.dart';

import '../../core/app_routes.dart';
import '../../core/app_theme.dart';
import '../../core/formatters.dart';
import '../../data/mock_sim_data.dart';
import '../../services/auth_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser;
    final featuredSims = mockSims.take(3).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trang chủ'),
        actions: [
          if (user != null)
            if (user.isAdmin)
              IconButton(
                tooltip: 'Quản trị',
                onPressed: () {
                  Navigator.of(context).pushNamed(AppRoutes.admin);
                },
                icon: const Icon(Icons.admin_panel_settings),
              )
            else
              IconButton(
                tooltip: 'Đơn hàng của tôi',
                onPressed: () {
                  Navigator.of(context).pushNamed(AppRoutes.myOrders);
                },
                icon: const Icon(Icons.receipt_long),
              ),
          IconButton(
            tooltip: 'Đăng xuất',
            onPressed: () {
              AuthService.instance.signOut();
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil(AppRoutes.auth, (route) => false);
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppPalette.teal,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Xin chào, ${user?.fullName ?? 'khách'}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Chọn sim đẹp phù hợp nhu cầu của bạn.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.84),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SearchBar(
            enabled: false,
            hintText: 'Tìm số sim...',
            leading: const Icon(Icons.search),
            elevation: const WidgetStatePropertyAll(0),
            backgroundColor: const WidgetStatePropertyAll(Colors.white),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.black.withValues(alpha: 0.08)),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              Chip(label: Text('Tam hoa')),
              Chip(label: Text('Tứ quý')),
              Chip(label: Text('Lộc phát')),
              Chip(label: Text('Thần tài')),
              Chip(label: Text('Năm sinh')),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Sim nổi bật',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppPalette.ink,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          ...featuredSims.map(
            (sim) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Card(
                child: ListTile(
                  leading: const Icon(Icons.sim_card, color: AppPalette.teal),
                  title: Text(
                    sim.phoneNumber,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  subtitle: Text('${sim.carrier} • ${sim.type}'),
                  trailing: Text(
                    formatCurrency(sim.price),
                    style: const TextStyle(
                      color: AppPalette.teal,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
