import 'package:flutter/material.dart';
import 'package:nutriday/pages/register_page.dart';
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
                const AuthCard(
                  title: 'Login',
                  buttonText: 'Entrar',
                  showConfirmPassword: false,
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegisterPage(),
                      ),
                    );
                  },
                  child: const Text('Não tem conta? Criar agora'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
