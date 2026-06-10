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
      AppPalette.violet,
    ),
    _PopularSimType('Sim năm sinh', Icons.cake_outlined, AppPalette.coral),
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

  void _showSupportMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tư vấn viên sẽ liên hệ trong ít phút.')),
    );
  }

  void _handleDestinationTap(int index, bool isAdmin) {
    switch (index) {
      case 0:
        return;
      case 1:
        _openSimList();
        return;
      case 2:
        Navigator.of(context).pushNamed(AppRoutes.myOrders);
        return;
      case 3:
        if (isAdmin) {
          Navigator.of(context).pushNamed(AppRoutes.admin);
        }
        return;
    }
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
    final isAdmin = user?.isAdmin ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('FBT Telecom'),
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
            tooltip: 'Thông báo',
            onPressed: _showSupportMessage,
            icon: const Icon(Icons.notifications_none),
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
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (index) => _handleDestinationTap(index, isAdmin),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Trang chủ',
          ),
          const NavigationDestination(
            icon: Icon(Icons.sim_card_outlined),
            selectedIcon: Icon(Icons.sim_card),
            label: 'Kho SIM',
          ),
          const NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Đơn hàng',
          ),
          if (isAdmin)
            const NavigationDestination(
              icon: Icon(Icons.admin_panel_settings_outlined),
              selectedIcon: Icon(Icons.admin_panel_settings),
              label: 'Quản trị',
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          _AccountHero(
            name: user?.fullName ?? 'khách',
            phone: user?.phone ?? 'Chưa cập nhật',
            availableCount: availableSims.length,
            lowestPrice: lowestPrice,
          ),
          const SizedBox(height: 14),
          SearchBar(
            key: const ValueKey('home_search_bar'),
            controller: _searchController,
            hintText: 'Tìm số SIM, ví dụ 686868',
            leading: const Icon(Icons.search),
            trailing: [
              IconButton(
                tooltip: 'Tìm kiếm',
                onPressed: () => _openSimList(query: _searchController.text),
                icon: const Icon(Icons.arrow_forward),
              ),
            ],
            onSubmitted: (value) => _openSimList(query: value),
          ),
          const SizedBox(height: 18),
          _SectionHeader(
            title: 'Tiện ích nhanh',
            actionLabel: 'Kho SIM',
            onActionPressed: () => _openSimList(),
          ),
          const SizedBox(height: 10),
          _QuickActionGrid(
            actions: [
              _QuickAction(
                icon: Icons.search,
                label: 'Tìm SIM',
                color: AppPalette.red,
                onTap: () => _openSimList(),
              ),
              _QuickAction(
                icon: Icons.workspace_premium_outlined,
                label: 'SIM VIP',
                color: AppPalette.gold,
                onTap: () => _openSimList(type: 'Sim tứ quý'),
              ),
              _QuickAction(
                icon: Icons.shopping_bag_outlined,
                label: 'Giữ số',
                color: AppPalette.blue,
                onTap: () =>
                    Navigator.of(context).pushNamed(AppRoutes.checkout),
              ),
              _QuickAction(
                icon: Icons.support_agent,
                label: 'Tư vấn',
                color: AppPalette.teal,
                onTap: _showSupportMessage,
              ),
            ],
          ),
          const SizedBox(height: 16),
          const _OfferBand(),
          const SizedBox(height: 20),
          Text(
            'Loại sim phổ biến',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppPalette.ink,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 94,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _popularTypes.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final type = _popularTypes[index];
                return _PopularTypeCard(
                  type: type,
                  onTap: () => _openSimList(type: type.name),
                );
              },
            ),
          ),
          const SizedBox(height: 22),
          _SectionHeader(
            title: 'Sim nổi bật',
            actionLabel: 'Xem tất cả',
            onActionPressed: () => _openSimList(),
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

class _AccountHero extends StatelessWidget {
  const _AccountHero({
    required this.name,
    required this.phone,
    required this.availableCount,
    required this.lowestPrice,
  });

  final String name;
  final String phone;
  final int availableCount;
  final int lowestPrice;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppPalette.red, AppPalette.redDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: AppPalette.red.withValues(alpha: 0.24),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
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
                    Row(
                      children: [
                        const Icon(
                          Icons.phone_android,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            phone,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.86),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.18),
                  ),
                ),
                child: const Icon(Icons.sim_card, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _HeroMetric(
                  icon: Icons.inventory_2_outlined,
                  label: '$availableCount SIM',
                  caption: 'Còn hàng',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _HeroMetric(
                  icon: Icons.payments_outlined,
                  label: 'Từ ${formatCurrency(lowestPrice)}',
                  caption: 'Giá tốt',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroMetric extends StatelessWidget {
  const _HeroMetric({
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
      height: 64,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.actionLabel,
    required this.onActionPressed,
  });

  final String title;
  final String actionLabel;
  final VoidCallback onActionPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppPalette.ink,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        TextButton.icon(
          onPressed: onActionPressed,
          icon: const Icon(Icons.arrow_forward, size: 18),
          label: Text(actionLabel),
        ),
      ],
    );
  }
}

class _QuickActionGrid extends StatelessWidget {
  const _QuickActionGrid({required this.actions});

  final List<_QuickAction> actions;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: actions.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.86,
      ),
      itemBuilder: (context, index) {
        final action = actions[index];
        return Material(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: AppPalette.line),
          ),
          child: InkWell(
            onTap: action.onTap,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: action.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(action.icon, color: action.color, size: 21),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    action.label,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppPalette.ink,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      height: 1.15,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _OfferBand extends StatelessWidget {
  const _OfferBand();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7E5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppPalette.gold.withValues(alpha: 0.28)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppPalette.gold.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.local_offer_outlined,
              color: AppPalette.gold,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ưu đãi hôm nay',
                  style: TextStyle(
                    color: AppPalette.ink,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Miễn phí giao SIM và hỗ trợ kích hoạt tại nhà.',
                  style: TextStyle(
                    color: AppPalette.muted,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
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

class _PopularTypeCard extends StatelessWidget {
  const _PopularTypeCard({required this.type, required this.onTap});

  final _PopularSimType type;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 132,
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: AppPalette.line),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: type.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(type.icon, size: 18, color: type.color),
                ),
                const Spacer(),
                Text(
                  type.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppPalette.ink,
                    fontWeight: FontWeight.w900,
                    height: 1.15,
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

class _FeaturedSimCard extends StatelessWidget {
  const _FeaturedSimCard({required this.sim});

  final BeautifulSim sim;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => Navigator.of(context).pushNamed(AppRoutes.checkout),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: AppPalette.red.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.sim_card, color: AppPalette.red),
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
                        const SizedBox(height: 5),
                        Text(
                          '${sim.carrier} • ${sim.type}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        color: AppPalette.red.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        formatCurrency(sim.price),
                        style: const TextStyle(
                          color: AppPalette.red,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  FilledButton.icon(
                    onPressed: () {
                      Navigator.of(context).pushNamed(AppRoutes.checkout);
                    },
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(106, 44),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    icon: const Icon(Icons.shopping_bag_outlined, size: 18),
                    label: const Text('Đặt mua'),
                  ),
                ],
              ),
            ],
          ),
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

class _QuickAction {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
}

class _PopularSimType {
  const _PopularSimType(this.name, this.icon, this.color);

  final String name;
  final IconData icon;
  final Color color;
}
