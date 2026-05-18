import 'package:flutter/material.dart';
import 'package:nutriday/pages/login_page.dart';
import 'package:nutriday/theme.dart';

void main() {
  runApp(const NutridayApp());
}

class NutridayApp extends StatelessWidget {
  const NutridayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NutriDay',
      theme: AppTheme.theme,
      debugShowCheckedModeBanner: false,
      home: const LoginPage(),
    );
  }
}
