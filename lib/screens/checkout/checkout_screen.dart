import 'package:flutter/material.dart';

import '../common/placeholder_feature_screen.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderFeatureScreen(
      title: 'Đặt mua sim',
      icon: Icons.shopping_bag_outlined,
      subtitle: 'Xác nhận thông tin nhận SIM và phương thức thanh toán.',
    );
  }
}
