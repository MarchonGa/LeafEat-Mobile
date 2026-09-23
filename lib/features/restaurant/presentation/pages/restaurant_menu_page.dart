import 'package:flutter/material.dart';
import 'package:leafeat_mobile/core/theme/app_colors.dart';
import 'package:leafeat_mobile/features/establishments/data/mock_establishments.dart';
import 'package:leafeat_mobile/features/establishments/domain/models/dish.dart';
import 'package:leafeat_mobile/features/restaurant/presentation/pages/dish_form_page.dart';

class RestaurantMenuPage extends StatefulWidget {
  const RestaurantMenuPage({super.key});
  @override
  State<RestaurantMenuPage> createState() => _RestaurantMenuPageState();
}

class _RestaurantMenuPageState extends State<RestaurantMenuPage> {
  late final List<Dish> _dishes;

  @override
  void initState() {
    super.initState();
    _dishes = [...mockEstablishments.first.dishes];
  }

  Future<void> _openForm({Dish? dish, int? index}) async {
    final result = await Navigator.of(context).push<Dish>(MaterialPageRoute(builder: (_) => DishFormPage(dish: dish)));
    if (result == null || !mounted) return;
    setState(() {
      if (index == null) {
        _dishes.add(result);
      } else {
        _dishes[index] = result;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(index == null ? 'Prato cadastrado em memória.' : 'Prato atualizado em memória.')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meu cardápio'), backgroundColor: AppColors.primary, foregroundColor: AppColors.onPrimary),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _dishes.length,
        itemBuilder: (context, index) {
          final dish = _dishes[index];
          return Card(
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.lunch_dining)),
              title: Text(dish.name),
              subtitle: Text('${dish.calories} kcal • R\$ ${dish.price.toStringAsFixed(2).replaceAll('.', ',')}'),
              trailing: const Icon(Icons.edit_outlined),
              onTap: () => _openForm(dish: dish, index: index),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(onPressed: _openForm, icon: const Icon(Icons.add), label: const Text('Novo prato')),
    );
  }
}
