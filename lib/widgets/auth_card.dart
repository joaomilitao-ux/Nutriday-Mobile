import 'package:flutter/material.dart';
import 'package:nutriday/theme.dart';
import 'package:nutriday/widgets/input_field.dart';

class AuthCard extends StatelessWidget {
  final String title;
  final String buttonText;
  final bool showConfirmPassword;

  const AuthCard({
    super.key,
    required this.title,
    required this.buttonText,
    required this.showConfirmPassword,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.12),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 24),
          const InputField(
            label: 'Email',
            hint: 'seu@email.com',
            obscureText: false,
          ),
          const SizedBox(height: 16),
          const InputField(
            label: 'Senha',
            hint: '••••••••',
            obscureText: true,
          ),
          if (showConfirmPassword) ...[
            const SizedBox(height: 16),
            const InputField(
              label: 'Confirmar Senha',
              hint: '••••••••',
              obscureText: true,
            ),
          ],
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {},
            child: Text(
              buttonText,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
