import 'package:flutter/material.dart';

import '../../core/app_routes.dart';
import '../../core/app_theme.dart';
import '../../core/formatters.dart';
import '../../data/mock_sim_data.dart';
import '../../models/beautiful_sim.dart';
import '../../models/sim_list_filter.dart';
import '../../services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _popularTypes = [
    _PopularSimType('Sim tam hoa', Icons.filter_3, AppPalette.teal),
    _PopularSimType('Sim tứ quý', Icons.looks_4, AppPalette.blue),
    _PopularSimType('Sim lộc phát', Icons.trending_up, AppPalette.gold),
    _PopularSimType(
      'Sim thần tài',
      Icons.workspace_premium_outlined,
      Color(0xFF8A5A12),
    ),
    _PopularSimType('Sim năm sinh', Icons.cake_outlined, Color(0xFF7C5C9A)),
  ];

  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openSimList({String query = '', String? type}) {
    Navigator.of(context).pushNamed(
      AppRoutes.simList,
      arguments: SimListFilter(query: query.trim(), type: type),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser;
    final availableSims = mockSims
        .where((sim) => sim.status == SimStatus.available)
        .toList();
    final featuredSims = availableSims.take(4).toList();
    final lowestPrice = mockSims
        .map((sim) => sim.price)
        .reduce((current, next) => current < next ? current : next);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trang chủ'),
        actions: [
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
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          _HomeBanner(
            name: user?.fullName ?? 'khách',
            availableCount: availableSims.length,
            lowestPrice: lowestPrice,
          ),
          const SizedBox(height: 16),
          SearchBar(
            key: const ValueKey('home_search_bar'),
            controller: _searchController,
            hintText: 'Tìm số sim...',
            leading: const Icon(Icons.search),
            trailing: [
              IconButton(
                tooltip: 'Tìm kiếm',
                onPressed: () => _openSimList(query: _searchController.text),
                icon: const Icon(Icons.arrow_forward),
              ),
            ],
            onSubmitted: (value) => _openSimList(query: value),
            elevation: const WidgetStatePropertyAll(0),
            backgroundColor: const WidgetStatePropertyAll(Colors.white),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.black.withValues(alpha: 0.08)),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Loại sim phổ biến',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppPalette.ink,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _popularTypes.map((type) {
              return ActionChip(
                avatar: Icon(type.icon, size: 18, color: type.color),
                label: Text(type.name),
                labelStyle: TextStyle(
                  color: type.color,
                  fontWeight: FontWeight.w800,
                ),
                backgroundColor: type.color.withValues(alpha: 0.10),
                side: BorderSide(color: type.color.withValues(alpha: 0.20)),
                onPressed: () => _openSimList(type: type.name),
              );
            }).toList(),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Sim nổi bật',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppPalette.ink,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () => _openSimList(),
                icon: const Icon(Icons.list_alt, size: 18),
                label: const Text('Xem tất cả'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...featuredSims.map(
            (sim) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _FeaturedSimCard(sim: sim),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeBanner extends StatelessWidget {
  const _HomeBanner({
    required this.name,
    required this.availableCount,
    required this.lowestPrice,
  });

  final String name;
  final int availableCount;
  final int lowestPrice;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppPalette.teal, AppPalette.blue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Xin chào, $name',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        height: 1.14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Chọn sim đẹp, dễ nhớ và đặt mua nhanh với thanh toán khi nhận hàng.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.88),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.sim_card, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _BannerStat(
                  icon: Icons.inventory_2_outlined,
                  label: '$availableCount sim',
                  caption: 'Còn hàng',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _BannerStat(
                  icon: Icons.payments_outlined,
                  label: 'Từ ${formatCurrency(lowestPrice)}',
                  caption: 'Khoảng giá',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BannerStat extends StatelessWidget {
  const _BannerStat({
    required this.icon,
    required this.label,
    required this.caption,
  });

  final IconData icon;
  final String label;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  caption,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.76),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeaturedSimCard extends StatelessWidget {
  const _FeaturedSimCard({required this.sim});

  final BeautifulSim sim;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppPalette.teal.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.sim_card, color: AppPalette.teal),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sim.phoneNumber,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: AppPalette.ink,
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${sim.carrier} • ${sim.type}',
                        style: const TextStyle(
                          color: AppPalette.muted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                _MiniStatusBadge(label: sim.status.label),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: AppPalette.gold.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                formatCurrency(sim.price),
                textAlign: TextAlign.right,
                style: const TextStyle(
                  color: AppPalette.ink,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniStatusBadge extends StatelessWidget {
  const _MiniStatusBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: AppPalette.teal.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppPalette.teal,
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _PopularSimType {
  const _PopularSimType(this.name, this.icon, this.color);

  final String name;
  final IconData icon;
  final Color color;
}
