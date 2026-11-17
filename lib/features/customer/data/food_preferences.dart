class FoodPreferences {
  const FoodPreferences({
    this.vegan = false,
    this.lactoseFree = false,
    this.metricMenus = false,
  });

  factory FoodPreferences.fromJson(Map<String, dynamic> json) =>
      FoodPreferences(
        vegan: json['vegan'] as bool? ?? false,
        lactoseFree: json['lactoseFree'] as bool? ?? false,
        metricMenus: json['metricMenus'] as bool? ?? false,
      );

  final bool vegan;
  final bool lactoseFree;
  final bool metricMenus;

  Map<String, dynamic> toJson() => {
        'vegan': vegan,
        'lactoseFree': lactoseFree,
        'metricMenus': metricMenus,
      };

  @override
  bool operator ==(Object other) =>
      other is FoodPreferences &&
      other.vegan == vegan &&
      other.lactoseFree == lactoseFree &&
      other.metricMenus == metricMenus;

  @override
  int get hashCode => Object.hash(vegan, lactoseFree, metricMenus);
}
