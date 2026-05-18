import 'package:flutter/material.dart';
import 'package:nutriday/theme.dart';

class NutriDayHeader extends StatelessWidget {
  const NutriDayHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(
          'assets/images/logo_nutriday.png',
          width: 220,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 4),
        const Text(
          'NutriDay',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Seu diário alimentar diário',
          style: TextStyle(
            fontSize: 16,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}
