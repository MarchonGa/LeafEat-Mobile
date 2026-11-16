import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:leafeat_mobile/app/session/app_session.dart';
import 'package:leafeat_mobile/core/network/api_client.dart';
import 'package:leafeat_mobile/features/auth/data/auth_repository.dart';
import 'package:leafeat_mobile/features/auth/data/auth_user.dart';
import 'package:leafeat_mobile/features/customer/presentation/pages/nutrition_tracking_page.dart';

void main() {
  testWidgets('adds an external meal to daily nutrition totals', (tester) async {
    var mealAdded = false;
    final client = MockClient((request) async {
      final path = request.url.path;
      if (request.method == 'GET' && path == '/api/customer/nutrition') {
        final entries = <Map<String, dynamic>>[
          _entry('breakfast', 'Café da manhã', 1280, 72, 145, 44),
          if (mealAdded)
            _entry('external', 'Marmita caseira', 500, 30, 60, 15),
        ];
        return _jsonResponse({'entries': entries});
      }
      if (request.method == 'GET' &&
          path == '/api/customer/nutrition-goals') {
        return _jsonResponse({
          'calories': 2000,
          'proteinGrams': 110,
          'carbohydrateGrams': 240,
          'fatGrams': 65,
          'fiberGrams': 30,
        });
      }
      if (request.method == 'POST' && path == '/api/customer/nutrition') {
        mealAdded = true;
        return _jsonResponse(
          _entry('external', 'Marmita caseira', 500, 30, 60, 15),
          statusCode: 201,
        );
      }
      return http.Response('Not found', 404);
    });
    final session = AppSession(
      apiClient: ApiClient(httpClient: client, baseUrl: 'http://test'),
      enablePersistence: false,
    );
    addTearDown(session.dispose);
    await session.authenticate(const AuthResult(
      token: 'test-token',
      user: AuthUser(
        id: 'customer-id',
        name: 'Cliente Teste',
        email: 'cliente@teste.local',
        role: UserMode.customer,
        dietaryRestrictions: [],
      ),
    ));

    await tester.pumpWidget(AppSessionScope(
      notifier: session,
      child: const MaterialApp(home: NutritionTrackingPage()),
    ));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Adicionar refeição externa'));
    await tester.tap(find.text('Adicionar refeição externa'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nome da refeição'),
      'Marmita caseira',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Calorias'),
      '500',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Carboidratos'),
      '60',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Proteínas'),
      '30',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Gorduras'),
      '15',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Fibras'),
      '0',
    );
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

Map<String, dynamic> _entry(
  String id,
  String name,
  num calories,
  num proteins,
  num carbohydrates,
  num fats,
) =>
    {
      'id': id,
      'name': name,
      'consumedAt': '2026-11-16T12:00:00Z',
      'calories': calories,
      'proteinGrams': proteins,
      'carbohydrateGrams': carbohydrates,
      'fatGrams': fats,
      'fiberGrams': 0,
      'isExternal': id == 'external',
    };

http.Response _jsonResponse(Object body, {int statusCode = 200}) =>
    http.Response(
      jsonEncode(body),
      statusCode,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );
