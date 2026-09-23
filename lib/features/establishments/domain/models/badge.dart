enum BadgeLevel { none, bronze, silver, gold }

class Badge {
  const Badge._({required this.level, required this.percentage});

  factory Badge.fromPercentage(double percentage) {
    final normalizedPercentage = percentage.clamp(0, 100).toDouble();

    if (normalizedPercentage < 10) {
      return Badge._(
        level: BadgeLevel.none,
        percentage: normalizedPercentage,
      );
    }
    if (normalizedPercentage < 50) {
      return Badge._(
        level: BadgeLevel.bronze,
        percentage: normalizedPercentage,
      );
    }
    if (normalizedPercentage < 100) {
      return Badge._(
        level: BadgeLevel.silver,
        percentage: normalizedPercentage,
      );
    }
    return Badge._(
      level: BadgeLevel.gold,
      percentage: normalizedPercentage,
    );
  }

  final BadgeLevel level;
  final double percentage;

  bool get isVisible => level != BadgeLevel.none;

  String get label => switch (level) {
    BadgeLevel.none => 'Sem selo',
    BadgeLevel.bronze => 'Bronze',
    BadgeLevel.silver => 'Prata',
    BadgeLevel.gold => 'Ouro',
  };
}
