import 'package:flutter_test/flutter_test.dart';
import 'package:leafeat_mobile/app/session/user_mode.dart';
import 'package:leafeat_mobile/features/auth/data/auth_user.dart';
import 'package:leafeat_mobile/features/establishments/domain/models/establishment.dart';

void main() {
  test('maps restaurant session returned by API', () {
    final user = AuthUser.fromJson({
      'id': 'user-id',
      'name': 'Sabor Natural',
      'email': 'restaurante@leafeat.local',
      'role': 'Restaurant',
      'dietaryRestrictions': <String>[],
      'establishmentId': 'establishment-id',
    });

    expect(user.role, UserMode.restaurant);
    expect(user.establishmentId, 'establishment-id');
  });

  test('maps establishment and dishes returned by API', () {
    final establishment = Establishment.fromJson({
      'id': 'establishment-id',
      'name': 'Sabor Natural',
      'category': 'Saudável',
      'description': 'Refeições equilibradas.',
      'address': 'Centro',
      'distanceKm': 0.8,
      'averageRating': 4.8,
      'badgePercentage': 100.0,
      'dishes': [
        {
          'id': 'dish-id',
          'name': 'Bowl vegano',
          'description': 'Grão-de-bico e legumes.',
          'price': 27.5,
          'calories': 419,
          'proteinGrams': 18.0,
          'carbohydrateGrams': 62.0,
          'fatGrams': 11.0,
          'fiberGrams': 12.0,
          'isVegan': true,
          'isLactoseFree': true,
        }
      ],
    });

    expect(establishment.averageRating, 4.8);
    expect(establishment.dishes.single.name, 'Bowl vegano');
    expect(establishment.badge.label, 'Ouro');
  });
}
