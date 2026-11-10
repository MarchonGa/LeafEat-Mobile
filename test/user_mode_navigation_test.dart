import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leafeat_mobile/app/app.dart';

void main() {
  testWidgets('switches between guest, customer, and restaurant views', (tester) async {
    await tester.pumpWidget(const LeafEatApp());
    await tester.tap(find.text('Explorar locais'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Perfil'));
    await tester.pumpAndSettle();

    expect(find.text('Visitante'), findsOneWidget);

    final customerChip = find.widgetWithText(ChoiceChip, 'Cliente');
    await tester.scrollUntilVisible(customerChip, 300);
    await tester.tap(customerChip);
    await tester.pumpAndSettle();

    expect(find.text('Cliente LeafEat'), findsOneWidget);
    expect(find.byIcon(Icons.lock_outline), findsNothing);

    final restaurantChip = find.widgetWithText(
      ChoiceChip,
      'Restaurante',
    );
    await tester.scrollUntilVisible(restaurantChip, 300);
    await tester.tap(restaurantChip);
    await tester.pumpAndSettle();

    expect(find.text('Início'), findsOneWidget);
    expect(find.text('Cardápio'), findsOneWidget);
    expect(find.text('Avaliações'), findsOneWidget);
    expect(find.text('Perfil'), findsOneWidget);
  });
}
