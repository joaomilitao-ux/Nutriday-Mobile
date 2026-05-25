import 'package:flutter/material.dart';
import 'package:nutriday/app_routes.dart';
import 'package:nutriday/widgets/auth_card.dart';
import 'package:nutriday/widgets/nutriday_header.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                const NutriDayHeader(),
                const SizedBox(height: 28),
                AuthCard(
                  title: 'Cadastro',
                  buttonText: 'Criar Conta',
                  showConfirmPassword: true,
                  onSubmit: () {
                    Navigator.pushNamed(context, AppRoutes.onboarding);
                  },
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('J\u00E1 tem uma conta? Entrar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
