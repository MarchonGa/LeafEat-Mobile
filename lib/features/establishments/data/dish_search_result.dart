import 'package:leafeat_mobile/features/establishments/domain/models/dish.dart';
import 'package:leafeat_mobile/features/establishments/domain/models/establishment.dart';

class DishSearchResult {
  const DishSearchResult({
    required this.establishment,
    required this.dish,
    required this.matchScore,
    required this.isExactMatch,
  });

  factory DishSearchResult.fromJson(Map<String, dynamic> json) {
    final establishmentJson =
        json['establishment'] as Map<String, dynamic>;
    final dishJson = json['dish'] as Map<String, dynamic>;
    final dish = Dish.fromJson(dishJson);

    return DishSearchResult(
      establishment: Establishment.fromJson({
        ...establishmentJson,
        'dishes': [dishJson],
      }),
      dish: dish,
      matchScore: (json['matchScore'] as num).toDouble(),
      isExactMatch: json['isExactMatch'] as bool,
    );
  }

  final Establishment establishment;
  final Dish dish;
  final double matchScore;
  final bool isExactMatch;
}
