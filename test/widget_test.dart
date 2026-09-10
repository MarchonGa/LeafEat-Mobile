import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leafeat_mobile/app/app.dart';

void main() {
  testWidgets('Welcome page shows the initial LeafEat experience', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const LeafEatApp());

    expect(find.text('Bem-vindo ao LeafEat!'), findsOneWidget);
    expect(find.text('Explorar locais'), findsOneWidget);
    expect(find.byIcon(Icons.eco), findsOneWidget);

    await tester.tap(find.text('Explorar locais'));
    await tester.pump();

    expect(find.text('O LeafEat está funcionando!'), findsOneWidget);
  });
}
