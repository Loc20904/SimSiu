import 'package:flutter/material.dart';

import '../common/placeholder_feature_screen.dart';

class SimListScreen extends StatelessWidget {
  const SimListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderFeatureScreen(
      title: 'Danh sách sim',
      icon: Icons.list_alt,
    );
  }
}
