import 'package:flutter/material.dart';
import 'package:nutriday/app_routes.dart';
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
      initialRoute: AppRoutes.login,
      routes: AppRoutes.routes,
    );
  }
}
