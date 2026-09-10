import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leafeat_mobile/app/app.dart';

void main() {
  testWidgets('User opens the exploration page from the welcome page', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const LeafEatApp());

    expect(find.text('Bem-vindo ao LeafEat!'), findsOneWidget);
    expect(find.text('Explorar locais'), findsOneWidget);
    expect(find.byIcon(Icons.eco), findsOneWidget);

    await tester.tap(find.text('Explorar locais'));
    await tester.pumpAndSettle();

    expect(find.text('O que você procura?'), findsOneWidget);
    expect(find.text('3 locais encontrados'), findsOneWidget);
    expect(find.text('Sabor Natural'), findsOneWidget);
    expect(find.text('Horta da Praça'), findsOneWidget);
    expect(find.text('Vida Leve'), findsOneWidget);
  });
}
