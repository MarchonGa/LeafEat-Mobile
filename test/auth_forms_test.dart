import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leafeat_mobile/features/auth/presentation/pages/login_page.dart';
import 'package:leafeat_mobile/features/auth/presentation/pages/register_page.dart';

void main() {
  testWidgets('login offers password recovery and visibility control', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginPage()));
    expect(find.text('Esqueci minha senha'), findsOneWidget);
    expect(find.byTooltip('Mostrar senha'), findsOneWidget);
  });

  testWidgets('restaurant registration asks for business information', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: RegisterPage()));
    await tester.tap(find.text('Restaurante'));
    await tester.pump();
    expect(find.text('Nome fantasia'), findsOneWidget);
    expect(find.text('Razão social'), findsOneWidget);
    expect(find.text('CNPJ'), findsOneWidget);
  });

  testWidgets('customer registration reaches food preferences', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: RegisterPage()));
    await tester.enterText(find.byType(TextFormField).at(0), 'Cliente Teste');
    await tester.enterText(find.byType(TextFormField).at(1), 'cliente@teste.com');
    await tester.enterText(find.byType(TextFormField).at(2), '88999999999');
    await tester.enterText(find.byType(TextFormField).at(3), '01/01/2000');
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();
    expect(find.text('Intolerância à lactose'), findsOneWidget);
    expect(find.text('Camarão'), findsOneWidget);
    expect(find.text('Amendoim'), findsOneWidget);
  });
}
