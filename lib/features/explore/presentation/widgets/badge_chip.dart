import 'package:flutter/material.dart' hide Badge;
import 'package:leafeat_mobile/features/establishments/domain/models/badge.dart';

class BadgeChip extends StatelessWidget {
  const BadgeChip({required this.badge, super.key});

  final Badge badge;

  @override
  Widget build(BuildContext context) {
    if (!badge.isVisible) return const SizedBox.shrink();

    final (color, icon) = switch (badge.level) {
      BadgeLevel.none => (Colors.transparent, Icons.circle_outlined),
      BadgeLevel.bronze => (const Color(0xFF9C6B30), Icons.workspace_premium),
      BadgeLevel.silver => (const Color(0xFF6F7882), Icons.workspace_premium),
      BadgeLevel.gold => (const Color(0xFFC28B00), Icons.workspace_premium),
    };

    return Chip(
      visualDensity: VisualDensity.compact,
      avatar: Icon(icon, size: 18, color: color),
      label: Text(badge.label),
      side: BorderSide(color: color),
    );
  }
}
