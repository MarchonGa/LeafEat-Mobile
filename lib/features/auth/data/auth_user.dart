import 'package:leafeat_mobile/app/session/user_mode.dart';

class AuthUser {
  const AuthUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.dietaryRestrictions,
    this.establishmentId,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
        id: json['id'] as String,
        name: json['name'] as String,
        email: json['email'] as String,
        role: json['role'] == 'Restaurant' ? UserMode.restaurant : UserMode.customer,
        dietaryRestrictions: (json['dietaryRestrictions'] as List<dynamic>? ?? const [])
            .map((item) => item.toString())
            .toList(),
        establishmentId: json['establishmentId'] as String?,
      );

  final String id;
  final String name;
  final String email;
  final UserMode role;
  final List<String> dietaryRestrictions;
  final String? establishmentId;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role == UserMode.restaurant ? 'Restaurant' : 'Customer',
        'dietaryRestrictions': dietaryRestrictions,
        'establishmentId': establishmentId,
      };
}
