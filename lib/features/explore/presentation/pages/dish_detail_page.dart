import 'package:flutter/material.dart';
import 'package:leafeat_mobile/core/theme/app_colors.dart';
import 'package:leafeat_mobile/features/establishments/domain/models/dish.dart';

class DishDetailPage extends StatelessWidget {
  const DishDetailPage({required this.dish, super.key});

  final Dish dish;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(dish.name),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Icon(Icons.lunch_dining, size: 80, color: AppColors.primary),
          const SizedBox(height: 16),
          Text(dish.name, textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(dish.description, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          Text('R\$ ${dish.price.toStringAsFixed(2).replaceAll('.', ',')}', textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 24),
          Text('Informações nutricionais', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 6),
          const Text('Valores informados por porção do prato.'),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                _NutritionTile(label: 'Valor energético', value: '${dish.calories} kcal'),
                const Divider(height: 1),
                _NutritionTile(label: 'Proteínas', value: '${dish.proteinGrams.toStringAsFixed(1)} g'),
                const Divider(height: 1),
                _NutritionTile(label: 'Carboidratos', value: '${dish.carbohydrateGrams.toStringAsFixed(1)} g'),
                const Divider(height: 1),
                _NutritionTile(label: 'Gorduras', value: '${dish.fatGrams.toStringAsFixed(1)} g'),
                const Divider(height: 1),
                _NutritionTile(label: 'Fibras', value: '${dish.fiberGrams.toStringAsFixed(1)} g'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (dish.isVegan) const Chip(avatar: Icon(Icons.eco, size: 18), label: Text('Vegano')),
              if (dish.isLactoseFree) const Chip(avatar: Icon(Icons.no_food, size: 18), label: Text('Sem lactose')),
            ],
          ),
          if (dish.reviews.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text('Avaliações', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            ...dish.reviews.map(
              (review) => Card(
                child: ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: Text('${review.authorName} • ${review.rating.toStringAsFixed(1)} ★'),
                  subtitle: Text(review.comment),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _NutritionTile extends StatelessWidget {
  const _NutritionTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ListTile(title: Text(label), trailing: Text(value, style: const TextStyle(fontWeight: FontWeight.bold)));
  }
}
