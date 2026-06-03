import 'package:flutter/material.dart';

import '../common/placeholder_feature_screen.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderFeatureScreen(
      title: 'Quản trị',
      icon: Icons.admin_panel_settings_outlined,
    );
  }
}
