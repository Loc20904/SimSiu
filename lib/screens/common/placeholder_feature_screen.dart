import 'package:flutter/material.dart';

import '../../core/app_theme.dart';

class PlaceholderFeatureScreen extends StatelessWidget {
  const PlaceholderFeatureScreen({
    super.key,
    required this.title,
    required this.icon,
    required this.subtitle,
  });

  final String title;
  final IconData icon;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppPalette.red, AppPalette.redDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.18),
                    ),
                  ),
                  child: Icon(icon, size: 28, color: Colors.white),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.84),
                          fontWeight: FontWeight.w600,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const _FeatureStep(
            icon: Icons.check_circle_outline,
            title: 'Tiếp nhận yêu cầu',
            caption: 'Thông tin được ghi nhận để đội ngũ hỗ trợ xử lý.',
          ),
          const SizedBox(height: 10),
          const _FeatureStep(
            icon: Icons.bolt_outlined,
            title: 'Xác minh thông tin',
            caption: 'Số SIM, người nhận và trạng thái đơn được kiểm tra.',
          ),
          const SizedBox(height: 10),
          const _FeatureStep(
            icon: Icons.security_outlined,
            title: 'Hoàn tất xử lý',
            caption: 'Kết quả được cập nhật để khách hàng theo dõi.',
          ),
        ],
      ),
    );
  }
}

class _FeatureStep extends StatelessWidget {
  const _FeatureStep({
    required this.icon,
    required this.title,
    required this.caption,
  });

  final IconData icon;
  final String title;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppPalette.red.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppPalette.red, size: 21),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppPalette.ink,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    caption,
                    style: const TextStyle(
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
      ),
    );
  }
}
