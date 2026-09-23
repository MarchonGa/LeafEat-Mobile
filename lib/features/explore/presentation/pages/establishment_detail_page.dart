import 'package:flutter/material.dart';
import 'package:leafeat_mobile/core/theme/app_colors.dart';
import 'package:leafeat_mobile/features/establishments/domain/models/dish.dart';
import 'package:leafeat_mobile/features/establishments/domain/models/establishment.dart';
import 'package:leafeat_mobile/features/explore/presentation/pages/dish_detail_page.dart';
import 'package:leafeat_mobile/features/explore/presentation/widgets/badge_chip.dart';

class EstablishmentDetailPage extends StatelessWidget {
  const EstablishmentDetailPage({required this.establishment, super.key});

  final Establishment establishment;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(establishment.name),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(
                radius: 32,
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                child: Icon(Icons.restaurant, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(establishment.category, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 20),
                        const SizedBox(width: 4),
                        Text('${establishment.averageRating.toStringAsFixed(1)} (${establishment.reviews.length})'),
                      ],
                    ),
                    if (establishment.badge.isVisible) ...[
                      const SizedBox(height: 8),
                      BadgeChip(badge: establishment.badge),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(establishment.description),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on_outlined, size: 20),
              const SizedBox(width: 8),
              Expanded(child: Text(establishment.address)),
            ],
          ),
          const SizedBox(height: 26),
          Text('Pratos', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          ...establishment.dishes.map((dish) => _DishCard(dish: dish)),
        ],
      ),
    );
  }
}

class _DishCard extends StatelessWidget {
  const _DishCard({required this.dish});

  final Dish dish;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: const CircleAvatar(child: Icon(Icons.lunch_dining)),
        title: Text(dish.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text('${dish.calories} kcal • R\$ ${dish.price.toStringAsFixed(2).replaceAll('.', ',')}'),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => DishDetailPage(dish: dish))),
      ),
    );
  }
}
