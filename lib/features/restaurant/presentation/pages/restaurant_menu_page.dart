import 'package:flutter/material.dart';
import 'package:leafeat_mobile/core/theme/app_colors.dart';
import 'package:leafeat_mobile/features/establishments/data/mock_establishments.dart';

class RestaurantMenuPage extends StatelessWidget {
  const RestaurantMenuPage({super.key});
  @override
  Widget build(BuildContext context) {
    final dishes = mockEstablishments.first.dishes;
    return Scaffold(
      appBar: AppBar(title: const Text('Meu cardápio'), backgroundColor: AppColors.primary, foregroundColor: AppColors.onPrimary),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: dishes.length,
        itemBuilder: (context, index) {
          final dish = dishes[index];
          return Card(child: ListTile(leading: const CircleAvatar(child: Icon(Icons.lunch_dining)), title: Text(dish.name), subtitle: Text('${dish.calories} kcal • R\$ ${dish.price.toStringAsFixed(2).replaceAll('.', ',')}'), trailing: const Icon(Icons.edit_outlined), onTap: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Edição de ${dish.name} será conectada posteriormente.')))));
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cadastro de prato será conectado posteriormente.'))),
        icon: const Icon(Icons.add),
        label: const Text('Novo prato'),
      ),
    );
  }
}
