import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leafeat_mobile/features/establishments/data/mock_establishments.dart';
import 'package:leafeat_mobile/features/establishments/domain/models/establishment.dart';
import 'package:leafeat_mobile/features/explore/presentation/pages/establishment_detail_page.dart';

void main() {
  testWidgets('visitor opens a dish and its nutritional details', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: EstablishmentDetailPage(
          establishment: mockEstablishments.first,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Pratos'), findsOneWidget);
    expect(find.text('Bowl de frango e legumes'), findsOneWidget);

    await tester.tap(find.text('Bowl de frango e legumes'));
    await tester.pumpAndSettle();

    expect(find.text('Informações nutricionais'), findsOneWidget);
    expect(find.text('510 kcal'), findsOneWidget);
    expect(find.text('Proteínas'), findsOneWidget);
  });

  testWidgets('shows a clear message when an establishment has no dishes',
      (tester) async {
    const establishment = Establishment(
      id: 'empty-menu',
      name: 'Restaurante sem cardápio',
      category: 'Restaurante',
      description: 'Descrição do estabelecimento.',
      address: 'Centro',
      distanceKm: 1,
      badgePercentage: 0,
      dishes: [],
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: EstablishmentDetailPage(establishment: establishment),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Pratos'), findsOneWidget);
    expect(
      find.text('Este estabelecimento ainda não cadastrou pratos.'),
      findsOneWidget,
    );
  });
}
