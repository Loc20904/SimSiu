import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.size = 180,
    this.showText = false,
    this.onDark = false,
  });

  final double size;
  final bool showText;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final logo = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: onDark ? 0.16 : 0.07),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: SizedBox(
        width: size,
        height: size * 0.30,
        child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
      ),
    );

    return Semantics(
      label: 'Viettal',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          logo,
          if (showText) ...[
            const SizedBox(height: 10),
            Text(
              'Viettal',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: onDark ? Colors.white : null,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
