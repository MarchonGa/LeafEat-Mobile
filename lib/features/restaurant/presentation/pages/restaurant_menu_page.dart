import 'package:flutter/material.dart';
import 'package:leafeat_mobile/app/session/app_session.dart';
import 'package:leafeat_mobile/core/theme/app_colors.dart';
import 'package:leafeat_mobile/features/establishments/data/establishments_repository.dart';
import 'package:leafeat_mobile/features/establishments/domain/models/dish.dart';
import 'package:leafeat_mobile/features/restaurant/data/restaurant_repository.dart';
import 'package:leafeat_mobile/features/restaurant/presentation/pages/dish_form_page.dart';

class RestaurantMenuPage extends StatefulWidget {
  const RestaurantMenuPage({super.key});

  @override
  State<RestaurantMenuPage> createState() =>
      _RestaurantMenuPageState();
}

class _RestaurantMenuPageState extends State<RestaurantMenuPage> {
  final List<Dish> _dishes = [];
  bool _loaded = false;
  bool _loading = true;
  String? _error;
  String? _deletingDishId;

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
      setState(() {
        _loading = false;
        _error = 'Entre como restaurante para consultar o cardápio.';
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final establishment = await EstablishmentsRepository(
        session.apiClient,
      ).detail(establishmentId);
      if (!mounted) return;
      setState(() {
        _dishes
          ..clear()
          ..addAll(establishment.dishes);
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error.toString();
      });
    }
  }

  Future<void> _openForm({Dish? dish, int? index}) async {
    final result = await Navigator.of(context).push<Dish>(
      MaterialPageRoute(
        builder: (_) => DishFormPage(dish: dish),
      ),
    );
    if (result == null || !mounted) return;
    setState(() {
      if (index == null) {
        _dishes.add(result);
      } else {
        _dishes[index] = result;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          index == null
              ? 'Prato cadastrado.'
              : 'Alterações salvas.',
        ),
      ),
    );
  }

  Future<void> _confirmDelete(Dish dish) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Excluir prato?'),
        content: Text(
          'O prato "${dish.name}" será removido do cardápio. '
          'As avaliações já publicadas serão preservadas.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmed == true) await _deleteDish(dish);
  }

  Future<void> _deleteDish(Dish dish) async {
    final session = AppSessionScope.read(context);
    final establishmentId = session.user?.establishmentId;
    if (session.token == null || establishmentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Entre como restaurante para excluir o prato.'),
        ),
      );
      return;
    }
    setState(() => _deletingDishId = dish.id);
    try {
      await RestaurantRepository(
        session.apiClient,
        session.token!,
      ).deleteDish(establishmentId, dish.id);
      if (!mounted) return;
      setState(() => _dishes.removeWhere((item) => item.id == dish.id));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('"${dish.name}" foi excluído.')),
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _deletingDishId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu cardápio'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        actions: [
          IconButton(
            tooltip: 'Atualizar cardápio',
            onPressed: _loading ? null : _loadDishes,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _loading && _dishes.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDishes,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [
                  if (_error != null)
                    Card(
                      color: Theme.of(context).colorScheme.errorContainer,
                      child: ListTile(
                        leading: const Icon(Icons.error_outline),
                        title: Text(_error!),
                        trailing: IconButton(
                          tooltip: 'Tentar novamente',
                          onPressed: _loadDishes,
                          icon: const Icon(Icons.refresh),
                        ),
                      ),
                    ),
                  if (_dishes.isEmpty && _error == null)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 64),
                      child: Column(
                        children: [
                          Icon(Icons.restaurant_menu, size: 56),
                          SizedBox(height: 12),
                          Text('Nenhum prato cadastrado.'),
                        ],
                      ),
                    )
                  else
                    for (var index = 0;
                        index < _dishes.length;
                        index++)
                      _DishCard(
                        dish: _dishes[index],
                        deleting: _deletingDishId == _dishes[index].id,
                        onEdit: () => _openForm(
                          dish: _dishes[index],
                          index: index,
                        ),
                        onDelete: () => _confirmDelete(_dishes[index]),
                      ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _loading ? null : _openForm,
        icon: const Icon(Icons.add),
        label: const Text('Novo prato'),
      ),
    );
  }
}

class _DishCard extends StatelessWidget {
  const _DishCard({
    required this.dish,
    required this.deleting,
    required this.onEdit,
    required this.onDelete,
  });

  final Dish dish;
  final bool deleting;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: deleting ? null : onEdit,
        leading: const CircleAvatar(child: Icon(Icons.lunch_dining)),
        title: Text(dish.name),
        subtitle: Text(
          '${dish.calories} kcal • R\$ '
          '${dish.price.toStringAsFixed(2).replaceAll('.', ',')}',
        ),
        trailing: deleting
            ? const SizedBox.square(
                dimension: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Wrap(
                spacing: 4,
                children: [
                  IconButton(
                    tooltip: 'Editar prato',
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined),
                  ),
                  IconButton(
                    tooltip: 'Excluir prato',
                    onPressed: onDelete,
                    icon: Icon(
                      Icons.delete_outline,
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
