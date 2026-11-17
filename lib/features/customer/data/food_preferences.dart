class FoodPreferences {
  const FoodPreferences({
    this.vegan = false,
    this.lactoseFree = false,
    this.metricMenus = false,
    this.dietaryRestrictions = const [],
  });

  factory FoodPreferences.fromJson(Map<String, dynamic> json) =>
      FoodPreferences(
        vegan: json['vegan'] as bool? ?? false,
        lactoseFree: json['lactoseFree'] as bool? ?? false,
        metricMenus: json['metricMenus'] as bool? ?? false,
        dietaryRestrictions:
            (json['dietaryRestrictions'] as List<dynamic>? ?? const [])
                .map((item) => item.toString())
                .toList(),
      );

  final bool vegan;
  final bool lactoseFree;
  final bool metricMenus;
  final List<String> dietaryRestrictions;

  Map<String, dynamic> toJson() => {
        'vegan': vegan,
        'lactoseFree': lactoseFree,
        'metricMenus': metricMenus,
        'dietaryRestrictions': dietaryRestrictions,
      };

  @override
  bool operator ==(Object other) =>
      other is FoodPreferences &&
      other.vegan == vegan &&
      other.lactoseFree == lactoseFree &&
      other.metricMenus == metricMenus &&
      _sameItems(other.dietaryRestrictions, dietaryRestrictions);

  @override
  int get hashCode => Object.hash(
        vegan,
        lactoseFree,
        metricMenus,
        Object.hashAll(dietaryRestrictions),
      );

  static bool _sameItems(List<String> first, List<String> second) {
    if (first.length != second.length) return false;
    for (var index = 0; index < first.length; index++) {
      if (first[index] != second[index]) return false;
    }
    return true;
  }
}
