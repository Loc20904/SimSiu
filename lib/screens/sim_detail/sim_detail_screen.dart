import 'package:flutter/material.dart';

import '../../core/app_routes.dart';
import '../../core/app_theme.dart';
import '../../core/formatters.dart';
import '../../models/beautiful_sim.dart';
import '../../services/sim_service.dart';

class SimDetailScreen extends StatefulWidget {
  const SimDetailScreen({super.key});

  @override
  State<SimDetailScreen> createState() => _SimDetailScreenState();
}

class _SimDetailScreenState extends State<SimDetailScreen> {
  final _simService = SimService.instance;

  @override
  void initState() {
    super.initState();
    _simService.addListener(_handleSimChanged);
    _simService.fetchSims(force: true);
  }

  @override
  void dispose() {
    _simService.removeListener(_handleSimChanged);
    super.dispose();
  }

  void _handleSimChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  BeautifulSim? _resolveSim(Object? arguments) {
    final simId = switch (arguments) {
      BeautifulSim sim => sim.id,
      String id => id,
      _ => null,
    };
    if (simId == null) {
      return null;
    }

    for (final sim in _simService.getAllSims()) {
      if (sim.id == simId) {
        return sim;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final sim = _resolveSim(ModalRoute.of(context)?.settings.arguments);
    if (sim == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chi tiết SIM')),
        body: const _MissingSim(),
      );
    }

    final isAvailable = sim.status == SimStatus.available;
    final statusColor = isAvailable ? AppPalette.teal : AppPalette.danger;

    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết SIM')),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 10, 20, 16),
        child: FilledButton.icon(
          key: const ValueKey('buy_sim_button'),
          onPressed: isAvailable
              ? () => Navigator.of(
                  context,
                ).pushNamed(AppRoutes.checkout, arguments: sim.id)
              : null,
          icon: Icon(
            isAvailable ? Icons.shopping_bag_outlined : Icons.block_outlined,
          ),
          label: Text(isAvailable ? 'Đặt mua SIM' : 'SIM đã được bán'),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppPalette.red, AppPalette.redDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Container(
                  width: 62,
                  height: 62,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.sim_card,
                    color: Colors.white,
                    size: 34,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  sim.phoneNumber,
                  key: const ValueKey('detail_phone_number'),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  formatCurrency(sim.price),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    sim.status.label,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: _QuickInfo(
                      icon: Icons.cell_tower_outlined,
                      label: 'Nhà mạng',
                      value: sim.carrier,
                      color: AppPalette.blue,
                    ),
                  ),
                  Container(width: 1, height: 54, color: AppPalette.line),
                  Expanded(
                    child: _QuickInfo(
                      icon: Icons.category_outlined,
                      label: 'Loại SIM',
                      value: sim.type,
                      color: AppPalette.violet,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          _DetailSection(
            icon: Icons.auto_awesome_outlined,
            title: 'Ý nghĩa SIM',
            content: sim.meaning,
            color: AppPalette.gold,
          ),
          const SizedBox(height: 12),
          _DetailSection(
            icon: Icons.notes_outlined,
            title: 'Mô tả',
            content: sim.description,
            color: AppPalette.teal,
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.verified_user_outlined,
                    color: AppPalette.blue,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mua SIM an tâm',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                color: AppPalette.ink,
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          'Thanh toán khi nhận hàng. Nhân viên sẽ liên hệ xác nhận trước khi giao SIM.',
                          style: TextStyle(
                            color: AppPalette.muted,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickInfo extends StatelessWidget {
  const _QuickInfo({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(color: AppPalette.muted, fontSize: 12),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppPalette.ink,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({
    required this.icon,
    required this.title,
    required this.content,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String content;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppPalette.ink,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: const TextStyle(color: AppPalette.muted, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _MissingSim extends StatelessWidget {
  const _MissingSim();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.sim_card_alert_outlined,
              size: 58,
              color: AppPalette.muted,
            ),
            const SizedBox(height: 14),
            const Text(
              'Không tìm thấy thông tin SIM.',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 14),
            OutlinedButton(
              onPressed: () =>
                  Navigator.of(context).pushReplacementNamed(AppRoutes.simList),
              child: const Text('Về kho SIM'),
            ),
          ],
        ),
      ),
    );
  }
}
