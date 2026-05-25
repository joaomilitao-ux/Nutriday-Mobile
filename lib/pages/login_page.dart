import 'package:flutter/material.dart';
import 'package:nutriday/app_routes.dart';
import 'package:nutriday/widgets/auth_card.dart';
import 'package:nutriday/widgets/nutriday_header.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

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
                  title: 'Login',
                  buttonText: 'Entrar',
                  showConfirmPassword: false,
                  onSubmit: () {
                    Navigator.pushReplacementNamed(context, AppRoutes.inicio);
                  },
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.register);
                  },
                  child: const Text('N\u00E3o tem conta? Criar agora'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
