import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leafeat_mobile/features/explore/presentation/pages/explore_page.dart';
import 'package:leafeat_mobile/features/restaurant/presentation/pages/dish_form_page.dart';
import 'package:leafeat_mobile/features/review/presentation/pages/review_form_page.dart';

void main() {
  testWidgets('opens establishment filters', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ExplorePage()));
    await tester.tap(find.byTooltip('Filtros'));
    await tester.pumpAndSettle();
    expect(find.text('Filtros e ordenação'), findsOneWidget);
    expect(find.text('Com opção vegana'), findsOneWidget);
    expect(find.text('Aplicar'), findsOneWidget);
  });

  testWidgets('shows dish creation fields', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: DishFormPage()));
    expect(find.text('Novo prato'), findsOneWidget);
    expect(find.text('Nome do prato'), findsOneWidget);
    expect(find.text('Informações por porção'), findsOneWidget);
  });

  testWidgets('shows dish and environment review fields', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ReviewFormPage()));
    expect(find.text('Nota do prato: 5 ★'), findsOneWidget);
    expect(find.text('Nota do ambiente: 5 ★'), findsOneWidget);
    expect(find.text('Enviar avaliação'), findsOneWidget);
  });
}
