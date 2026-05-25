import 'package:flutter/material.dart';
import 'package:nutriday/app_session.dart';
import 'package:nutriday/pages/perfil_screen.dart';
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
                AuthCard(
                  title: 'Login',
                  buttonText: 'Entrar',
                  showConfirmPassword: false,
                  onSubmit: (email, password) {
                    final profile = AppSession.resolveProfileForLogin(email);

                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => PerfilScreen(profile: profile),
                      ),
                    );
                  },
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
