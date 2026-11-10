import 'package:flutter/material.dart';
import 'package:leafeat_mobile/core/theme/app_colors.dart';
import 'package:leafeat_mobile/features/establishments/data/mock_establishments.dart';
import 'package:leafeat_mobile/features/establishments/domain/models/dish.dart';
import 'package:leafeat_mobile/features/restaurant/presentation/pages/dish_form_page.dart';
import 'package:leafeat_mobile/features/establishments/data/establishments_repository.dart';
import 'package:leafeat_mobile/app/session/app_session.dart';

class RestaurantMenuPage extends StatefulWidget {
  const RestaurantMenuPage({super.key});
  @override
  State<RestaurantMenuPage> createState() => _RestaurantMenuPageState();
}

class _RestaurantMenuPageState extends State<RestaurantMenuPage> {
  late final List<Dish> _dishes;
  bool _loaded = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _dishes = [...mockEstablishments.first.dishes];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    _loadDishes();
  }

  Future<void> _loadDishes() async {
    final session = AppSessionScope.read(context);
    final establishmentId = session.user?.establishmentId;
    if (establishmentId == null) {
      setState(() => _loading = false);
      return;
    }
    try {
      final establishment = await EstablishmentsRepository(session.apiClient).detail(establishmentId);
      if (mounted) setState(() { _dishes..clear()..addAll(establishment.dishes); });
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível atualizar o cardápio. Exibindo dados demonstrativos.')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(index == null ? 'Prato cadastrado.' : 'Edição mantida nesta sessão.')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meu cardápio'), backgroundColor: AppColors.primary, foregroundColor: AppColors.onPrimary),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
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
