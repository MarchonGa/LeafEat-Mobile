import 'package:flutter/material.dart';
import 'package:leafeat_mobile/app/session/app_session.dart';
import 'package:leafeat_mobile/core/theme/app_colors.dart';
import 'package:leafeat_mobile/features/restaurant/data/recipe_repository.dart';
import 'package:leafeat_mobile/features/restaurant/data/restaurant_recipe.dart';
import 'package:leafeat_mobile/features/restaurant/presentation/pages/recipe_form_page.dart';

class RestaurantRecipesPage extends StatefulWidget {
  const RestaurantRecipesPage({super.key});

  @override
  State<RestaurantRecipesPage> createState() =>
      _RestaurantRecipesPageState();
}

class _RestaurantRecipesPageState extends State<RestaurantRecipesPage> {
  final List<RestaurantRecipe> _recipes = [];
  bool _started = false;
  bool _loading = true;
  String? _error;
  String? _deletingId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    _load();
  }

  RecipeRepository? _repository() {
    final session = AppSessionScope.read(context);
    final token = session.token;
    return token == null
        ? null
        : RecipeRepository(session.apiClient, token);
  }

  Future<void> _load() async {
    final session = AppSessionScope.read(context);
    final establishmentId = session.user?.establishmentId;
    final repository = _repository();
    if (establishmentId == null || repository == null) {
      setState(() {
        _loading = false;
        _error = 'Entre como restaurante para consultar as receitas.';
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final items = await repository.list(establishmentId);
      if (!mounted) return;
      setState(() {
        _recipes
          ..clear()
          ..addAll(items);
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

  Future<void> _create() async {
    final recipe = await Navigator.of(context).push<RestaurantRecipe>(
      MaterialPageRoute(builder: (_) => const RecipeFormPage()),
    );
    if (recipe == null || !mounted) return;
    setState(() => _recipes.add(recipe));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Receita “${recipe.name}” salva.')),
    );
  }

  Future<void> _confirmDelete(RestaurantRecipe recipe) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Excluir receita?'),
        content: Text(
          'A receita “${recipe.name}” e seus ingredientes serão removidos.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final session = AppSessionScope.read(context);
    final establishmentId = session.user?.establishmentId;
    final repository = _repository();
    if (establishmentId == null || repository == null) return;

    setState(() => _deletingId = recipe.id);
    try {
      await repository.delete(
        establishmentId: establishmentId,
        recipeId: recipe.id,
      );
      if (!mounted) return;
      setState(() => _recipes.removeWhere((item) => item.id == recipe.id));
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _deletingId = null);
    }
  }

  void _showDetails(RestaurantRecipe recipe) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.7,
          maxChildSize: 0.92,
          builder: (context, controller) => ListView(
            controller: controller,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            children: [
              Text(
                recipe.name,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              if (recipe.description.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(recipe.description),
              ],
              const SizedBox(height: 14),
              Text(
                'Ingredientes: ${_format(recipe.rawIngredientsWeightGrams)} g '
                '• Peso pronto: ${_format(recipe.finalWeightGrams)} g',
              ),
              const SizedBox(height: 10),
              Text(
                'Por 100 g: ${_format(recipe.per100Grams.energyKcal)} kcal • '
                '${_format(recipe.per100Grams.proteinGrams)} g proteínas • '
                '${_format(recipe.per100Grams.carbohydrateGrams)} g carboidratos',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const Divider(height: 28),
              Text(
                'Composição',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              for (final ingredient in recipe.ingredients)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.rice_bowl_outlined),
                  title: Text(ingredient.description),
                  subtitle: Text(ingredient.category),
                  trailing: Text(
                    '${_format(ingredient.quantityGrams)} g',
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Receitas da casa'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        actions: [
          IconButton(
            tooltip: 'Atualizar receitas',
            onPressed: _loading ? null : _load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _loading && _recipes.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                children: [
                  Text(
                    'Monte preparos reutilizáveis com alimentos da TACO. '
                    'Depois eles poderão compor diferentes pratos.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 12),
                  if (_error != null)
                    Card(
                      color: Theme.of(context).colorScheme.errorContainer,
                      child: ListTile(
                        leading: const Icon(Icons.error_outline),
                        title: Text(_error!),
                        trailing: IconButton(
                          onPressed: _load,
                          icon: const Icon(Icons.refresh),
                        ),
                      ),
                    )
                  else if (_recipes.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Column(
                          children: [
                            Icon(Icons.menu_book_outlined, size: 48),
                            SizedBox(height: 10),
                            Text('Nenhuma receita cadastrada.'),
                          ],
                        ),
                      ),
                    )
                  else
                    for (final recipe in _recipes)
                      Card(
                        child: ListTile(
                          onTap: () => _showDetails(recipe),
                          leading: const CircleAvatar(
                            child: Icon(Icons.soup_kitchen_outlined),
                          ),
                          title: Text(recipe.name),
                          subtitle: Text(
                            '${recipe.ingredients.length} ingredientes • '
                            '${_format(recipe.finalWeightGrams)} g prontos • '
                            '${_format(recipe.per100Grams.energyKcal)} kcal/100 g',
                          ),
                          trailing: _deletingId == recipe.id
                              ? const SizedBox.square(
                                  dimension: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : IconButton(
                                  tooltip: 'Excluir receita',
                                  onPressed: () => _confirmDelete(recipe),
                                  icon: const Icon(Icons.delete_outline),
                                ),
                        ),
                      ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _loading ? null : _create,
        icon: const Icon(Icons.add),
        label: const Text('Nova receita'),
      ),
    );
  }
}

String _format(double? value) {
  if (value == null) return 'não informado';
  if (value.abs() <= 0.00001) return 'traço';
  return value
      .toStringAsFixed(2)
      .replaceFirst(RegExp(r'\.00$'), '')
      .replaceFirst(RegExp(r'(\.[0-9])0$'), r'$1')
      .replaceAll('.', ',');
}
