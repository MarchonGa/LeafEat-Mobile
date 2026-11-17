class AccountProfile {
  const AccountProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.dietaryRestrictions,
    required this.establishmentId,
    this.cnpj,
    this.zipCode,
    this.addressNumber,
    this.neighborhood,
    this.description,
    this.category,
  });

  factory AccountProfile.fromJson(Map<String, dynamic> json) => AccountProfile(
        id: json['id'] as String,
        name: json['name'] as String,
        email: json['email'] as String,
        role: json['role'] as String,
        dietaryRestrictions:
            (json['dietaryRestrictions'] as List<dynamic>? ?? const [])
                .map((item) => item.toString())
                .toList(),
        cnpj: json['cnpj'] as String?,
        zipCode: json['zipCode'] as String?,
        addressNumber: json['addressNumber'] as String?,
        neighborhood: json['neighborhood'] as String?,
        establishmentId: json['establishmentId'] as String?,
        description: json['description'] as String?,
        category: json['category'] as String?,
      );

  final String id;
  final String name;
  final String email;
  final String role;
  final List<String> dietaryRestrictions;
  final String? cnpj;
  final String? zipCode;
  final String? addressNumber;
  final String? neighborhood;
  final String? establishmentId;
  final String? description;
  final String? category;
}
