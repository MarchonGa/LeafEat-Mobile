import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leafeat_mobile/app/app.dart';

void main() {
  testWidgets('User navigates through the main LeafEat areas', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const LeafEatApp());

    expect(find.text('Bem-vindo ao LeafEat!'), findsOneWidget);

    await tester.tap(find.text('Explorar locais'));
    await tester.pumpAndSettle();

    expect(
      find.text('O mapa interativo será exibido aqui'),
      findsOneWidget,
    );

    await tester.tap(find.text('Explorar'));
    await tester.pumpAndSettle();

    expect(find.text('O que você procura?'), findsOneWidget);
    expect(find.text('3 locais encontrados'), findsOneWidget);

    await tester.tap(find.text('Avaliar'));
    await tester.pumpAndSettle();

    expect(find.text('Avalie sua experiência'), findsOneWidget);

    await tester.tap(find.text('Perfil'));
    await tester.pumpAndSettle();

    expect(find.text('Visitante'), findsOneWidget);
    expect(find.text('Locais favoritos'), findsOneWidget);
  });
}
