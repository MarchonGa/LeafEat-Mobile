import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leafeat_mobile/features/explore/presentation/pages/explore_page.dart';
import 'package:leafeat_mobile/features/restaurant/presentation/pages/dish_form_page.dart';
import 'package:leafeat_mobile/features/review/presentation/pages/review_form_page.dart';

void main() {
  testWidgets('shows nutrition search targets and dietary filters',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ExplorePage()));

    expect(find.text('Qual meta você quer atingir?'), findsOneWidget);
    expect(find.text('Calorias'), findsOneWidget);
    expect(find.text('Proteínas'), findsOneWidget);
    expect(find.text('Carboidratos'), findsOneWidget);
    expect(find.text('Lipídios'), findsOneWidget);
    expect(find.text('Somente pratos veganos'), findsOneWidget);
    expect(find.text('Somente pratos sem lactose'), findsOneWidget);
    expect(find.text('Buscar melhores pratos'), findsOneWidget);
  });

  testWidgets('shows dish creation fields and automatic calories', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: DishFormPage()));
    expect(find.text('Novo prato'), findsOneWidget);
    expect(find.text('Nome do prato'), findsOneWidget);
    expect(find.text('Informações por porção'), findsOneWidget);
    expect(
      find.text('Calorias calculadas automaticamente'),
      findsOneWidget,
    );
    expect(find.text('0 kcal'), findsOneWidget);
  });

  testWidgets('shows dish and environment review fields', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ReviewFormPage()));
    expect(find.text('Nota do prato: 5 ★'), findsOneWidget);
    expect(find.text('Nota do ambiente: 5 ★'), findsOneWidget);

    await tester.drag(
      find.byType(ListView),
      const Offset(0, -400),
    );
    await tester.pumpAndSettle();

    expect(find.text('Enviar avaliação'), findsOneWidget);
  });
}
