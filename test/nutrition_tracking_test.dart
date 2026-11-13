import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leafeat_mobile/features/customer/presentation/pages/nutrition_tracking_page.dart';

void main() {
  testWidgets('adds an external meal to daily nutrition totals', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: NutritionTrackingPage()));

    await tester.ensureVisible(find.text('Adicionar refeição externa'));
    await tester.tap(find.text('Adicionar refeição externa'));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextFormField, 'Nome da refeição'), 'Marmita caseira');
    await tester.enterText(find.widgetWithText(TextFormField, 'Calorias'), '500');
    await tester.enterText(find.widgetWithText(TextFormField, 'Carboidratos'), '60');
    await tester.enterText(find.widgetWithText(TextFormField, 'Proteínas'), '30');
    await tester.enterText(find.widgetWithText(TextFormField, 'Gorduras'), '15');
    await tester.ensureVisible(find.text('Adicionar ao resumo'));
    await tester.tap(find.text('Adicionar ao resumo'));
    await tester.pumpAndSettle();

    expect(find.text('Marmita caseira'), findsOneWidget);
    expect(find.text('Calorias: 1780 de 2000 kcal'), findsOneWidget);
    expect(find.text('Proteínas: 102 de 110 g'), findsOneWidget);
    expect(find.text('Carboidratos: 205 de 240 g'), findsOneWidget);
    expect(find.text('Gorduras: 59 de 65 g'), findsOneWidget);
  });
}
