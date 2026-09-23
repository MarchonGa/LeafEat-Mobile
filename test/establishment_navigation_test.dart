import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leafeat_mobile/features/explore/presentation/pages/explore_page.dart';

void main() {
  testWidgets('visitor opens an establishment and its nutritional details', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ExplorePage()));

    expect(find.text('3 estabelecimentos encontrados'), findsOneWidget);
    await tester.tap(find.text('Sabor Natural'));
    await tester.pumpAndSettle();

    expect(find.text('Pratos'), findsOneWidget);
    expect(find.text('Bowl de frango e legumes'), findsOneWidget);

    await tester.tap(find.text('Bowl de frango e legumes'));
    await tester.pumpAndSettle();

    expect(find.text('Informações nutricionais'), findsOneWidget);
    expect(find.text('510 kcal'), findsOneWidget);
    expect(find.text('Sem lactose'), findsOneWidget);
  });
}
