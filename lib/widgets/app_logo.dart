import 'package:flutter/material.dart';

import '../core/app_theme.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.size = 56,
    this.showText = true,
    this.alignment = MainAxisAlignment.center,
  });

  final double size;
  final bool showText;
  final MainAxisAlignment alignment;

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.titleLarge?.copyWith(
      color: AppPalette.ink,
      fontWeight: FontWeight.w900,
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: alignment,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: AppPalette.teal,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: AppPalette.teal.withValues(alpha: 0.18),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Icon(Icons.sim_card, color: Colors.white, size: size * 0.48),
        ),
        if (showText) ...[
          const SizedBox(width: 12),
          Text('Sim Đẹp', style: titleStyle),
        ],
      ],
    );
  }
}
