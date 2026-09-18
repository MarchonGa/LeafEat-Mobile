import 'package:flutter_test/flutter_test.dart';
import 'package:leafeat_mobile/features/establishments/domain/models/badge.dart';

void main() {
  group('Badge.fromPercentage', () {
    test('does not award a badge below 10%', () {
      expect(Badge.fromPercentage(9.99).level, BadgeLevel.none);
    });

    test('awards Bronze from 10% up to less than 50%', () {
      expect(Badge.fromPercentage(10).level, BadgeLevel.bronze);
      expect(Badge.fromPercentage(49.99).level, BadgeLevel.bronze);
    });

    test('awards Silver from 50% up to less than 100%', () {
      expect(Badge.fromPercentage(50).level, BadgeLevel.silver);
      expect(Badge.fromPercentage(99.99).level, BadgeLevel.silver);
    });

    test('awards Gold at 100%', () {
      expect(Badge.fromPercentage(100).level, BadgeLevel.gold);
    });
  });
}
