import 'package:flutter/material.dart';

import '../common/placeholder_feature_screen.dart';

class MyOrdersScreen extends StatelessWidget {
  const MyOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderFeatureScreen(
      title: 'Đơn hàng của tôi',
      icon: Icons.receipt_long_outlined,
      subtitle: 'Theo dõi trạng thái giữ số, xác nhận và giao SIM.',
    );
  }
}
