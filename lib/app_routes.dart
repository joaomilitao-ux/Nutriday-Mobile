import 'package:flutter/material.dart';
import 'package:nutriday/pages/historico_screen.dart';
import 'package:nutriday/pages/inicio_screen.dart';
import 'package:nutriday/pages/lista_compras_screen.dart';
import 'package:nutriday/pages/login_page.dart';
import 'package:nutriday/pages/onboarding_questions_page.dart';
import 'package:nutriday/pages/perfil_screen.dart';
import 'package:nutriday/pages/register_page.dart';
import 'package:nutriday/pages/registrar_refeicao_screen.dart';
import 'package:nutriday/pages/sugestoes_screen.dart';

class AppRoutes {
  static const String login = '/';
  static const String inicio = '/inicio';
  static const String historico = '/historico';
  static const String register = '/register';
  static const String onboarding = '/onboarding';
  static const String compras = '/compras';
  static const String perfil = '/perfil';
  static const String registrarRefeicao = '/registrar-refeicao';
  static const String sugestoes = '/sugestoes';
  static const List<String> bottomNavRoutes = [
    inicio,
    historico,
    sugestoes,
    compras,
    perfil,
  ];

  static Map<String, WidgetBuilder> get routes => {
        login: (_) => const LoginPage(),
        inicio: (_) => const InicioScreen(),
        historico: (_) => const HistoricoScreen(),
        register: (_) => const RegisterPage(),
        onboarding: (_) => const OnboardingQuestionsPage(),
        compras: (_) => const ComprasScreen(),
        perfil: (_) => const PerfilScreen(),
        registrarRefeicao: (_) => const RegistrarRefeicaoScreen(),
        sugestoes: (_) => const SugestoesScreen(),
      };
}
