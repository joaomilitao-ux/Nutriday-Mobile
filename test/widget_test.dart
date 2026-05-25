import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nutriday/main.dart';

void main() {
  testWidgets('NutriDay app shows login title', (WidgetTester tester) async {
    await tester.pumpWidget(const NutridayApp());

    expect(find.text('NutriDay'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
  });

  testWidgets('login opens profile screen', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 1000));
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });

    await tester.pumpWidget(const NutridayApp());
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'joao@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), '123456');
    await tester.ensureVisible(find.text('Entrar'));
    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();

    expect(find.text('joao@example.com'), findsOneWidget);
    expect(find.text('Joao'), findsOneWidget);
  });

  testWidgets('register flow opens profile after onboarding',
      (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 1000));
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });

    await tester.pumpWidget(const NutridayApp());
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Não tem conta? Criar agora'));
    await tester.tap(find.text('Não tem conta? Criar agora'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'carlos@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), '123456');
    await tester.enterText(find.byType(TextFormField).at(2), '123456');
    await tester.ensureVisible(find.text('Criar Conta'));
    await tester.tap(find.text('Criar Conta'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Ganhar massa'));
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), '70');
    await tester.enterText(find.byType(TextField).at(1), '175');
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), '28');
    await tester.tap(find.text('Masculino'));
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Moderado'));
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();

    expect(find.text('Cadastro concluído'), findsOneWidget);

    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(find.text('carlos@example.com'), findsOneWidget);
    expect(find.text('Ganhar massa'), findsOneWidget);
  });
}
