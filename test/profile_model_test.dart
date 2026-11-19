import 'package:flutter_test/flutter_test.dart';
import 'package:leafeat_mobile/features/auth/data/auth_user.dart';
import 'package:leafeat_mobile/features/profile/data/account_profile.dart';

void main() {
  test('maps customer profile returned by API', () {
    final profile = AccountProfile.fromJson({
      'id': 'customer-id',
      'name': 'Cliente LeafEat',
      'email': 'cliente@leafeat.local',
      'role': 'Customer',
      'dietaryRestrictions': ['Lactose', 'Amendoim'],
      'establishmentId': null,
      'cnpj': null,
      'zipCode': null,
      'addressNumber': null,
      'neighborhood': null,
      'description': null,
      'category': null,
    });

    expect(profile.dietaryRestrictions, ['Lactose', 'Amendoim']);
    expect(profile.role, 'Customer');
  });

  test('copies updated user data without losing identity', () {
    final user = AuthUser.fromJson({
      'id': 'customer-id',
      'name': 'Nome antigo',
      'email': 'antigo@leafeat.local',
      'role': 'Customer',
      'dietaryRestrictions': <String>[],
      'establishmentId': null,
    });

    final updated = user.copyWith(
      name: 'Nome novo',
      email: 'novo@leafeat.local',
      dietaryRestrictions: ['Camarão'],
    );

    expect(updated.id, user.id);
    expect(updated.name, 'Nome novo');
    expect(updated.dietaryRestrictions, ['Camarão']);
  });
}
