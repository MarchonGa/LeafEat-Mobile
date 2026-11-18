import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:leafeat_mobile/app/session/app_session.dart';
import 'package:leafeat_mobile/core/theme/app_colors.dart';
import 'package:leafeat_mobile/features/restaurant/data/nutritional_food.dart';
import 'package:leafeat_mobile/features/restaurant/data/recipe_repository.dart';
import 'package:leafeat_mobile/features/restaurant/data/restaurant_recipe.dart';
import 'package:leafeat_mobile/features/restaurant/presentation/pages/nutritional_catalog_page.dart';

class RecipeFormPage extends StatefulWidget {
  const RecipeFormPage({super.key});

  @override
  State<RecipeFormPage> createState() => _RecipeFormPageState();
}

class _RecipeFormPageState extends State<RecipeFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _finalWeightController = TextEditingController();
  final List<NutritionalFoodSelection> _ingredients = [];
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _finalWeightController.dispose();
    super.dispose();
  }

  double? get _finalWeight => double.tryParse(
        _finalWeightController.text.replaceAll(',', '.'),
      );

  double get _rawWeight => _ingredients.fold(
        0,
        (total, item) => total + item.quantityGrams,
      );

  bool get _hasIncompleteNutrition => _ingredients.any((item) {
        final nutrients = item.food.per100Grams;
        return nutrients.energyKcal == null ||
            nutrients.proteinGrams == null ||
            nutrients.carbohydrateGrams == null ||
            nutrients.fatGrams == null ||
            nutrients.fiberGrams == null ||
            nutrients.sodiumMilligrams == null;
      });

  Nutrients get _total => Nutrients(
        energyKcal: _sum((item) => item.energyKcal),
        proteinGrams: _sum((item) => item.proteinGrams),
        carbohydrateGrams: _sum((item) => item.carbohydrateGrams),
        fatGrams: _sum((item) => item.fatGrams),
        fiberGrams: _sum((item) => item.fiberGrams),
        sodiumMilligrams: _sum((item) => item.sodiumMilligrams),
      );

  Nutrients? get _per100Prepared {
    final weight = _finalWeight;
    if (weight == null || weight <= 0) return null;
    final total = _total;
    final factor = 100 / weight;
    return Nutrients(
      energyKcal: _multiply(total.energyKcal, factor),
      proteinGrams: _multiply(total.proteinGrams, factor),
      carbohydrateGrams: _multiply(total.carbohydrateGrams, factor),
      fatGrams: _multiply(total.fatGrams, factor),
      fiberGrams: _multiply(total.fiberGrams, factor),
      sodiumMilligrams: _multiply(total.sodiumMilligrams, factor),
    );
  }

  double? _sum(double? Function(Nutrients) selector) {
    final known = _ingredients
        .where((item) => selector(item.food.per100Grams) != null)
        .toList();
    if (known.isEmpty) return null;
    return known.fold<double>(
      0,
      (total, item) =>
          total +
          selector(item.food.per100Grams)! * item.quantityGrams / 100,
    );
  }

  Future<void> _addIngredient() async {
    final selection = await Navigator.of(context)
        .push<NutritionalFoodSelection>(
      MaterialPageRoute(
        builder: (_) => const NutritionalCatalogPage(
          selectionMode: true,
        ),
      ),
    );
    if (selection == null || !mounted) return;

    final existingIndex = _ingredients.indexWhere(
      (item) => item.food.id == selection.food.id,
    );
    setState(() {
      if (existingIndex < 0) {
        _ingredients.add(selection);
      } else {
        final existing = _ingredients[existingIndex];
        _ingredients[existingIndex] = existing.copyWith(
          quantityGrams:
              existing.quantityGrams + selection.quantityGrams,
        );
      }
    });
  }

  Future<void> _editQuantity(int index) async {
    final ingredient = _ingredients[index];
    final controller = TextEditingController(
      text: _formatInput(ingredient.quantityGrams),
    );
    final quantity = await showDialog<double>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(ingredient.food.description),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(
            decimal: true,
          ),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
          ],
          decoration: const InputDecoration(
            labelText: 'Quantidade',
            suffixText: 'g',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              final value = double.tryParse(
                controller.text.replaceAll(',', '.'),
              );
              Navigator.of(dialogContext).pop(
                value != null && value > 0 ? value : null,
              );
            },
            child: const Text('Atualizar'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (quantity == null || !mounted) return;
    setState(() {
      _ingredients[index] = ingredient.copyWith(
        quantityGrams: quantity,
      );
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_ingredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Adicione pelo menos um ingrediente.'),
        ),
      );
      return;
    }

    final session = AppSessionScope.read(context);
    final token = session.token;
    final establishmentId = session.user?.establishmentId;
    if (token == null || establishmentId == null) return;

    setState(() => _saving = true);
    try {
      final recipe = await RecipeRepository(
        session.apiClient,
        token,
      ).create(
        establishmentId: establishmentId,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        finalWeightGrams: _finalWeight!,
        ingredients: _ingredients,
      );
      if (mounted) Navigator.of(context).pop(recipe);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = _total;
    final per100 = _per100Prepared;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo item personalizado'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nome do item',
                hintText: 'Ex.: Risoto de cenoura ou molho da casa',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Informe o nome do item.'
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Descrição (opcional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Ingredientes',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                FilledButton.icon(
                  onPressed: _saving ? null : _addIngredient,
                  icon: const Icon(Icons.add),
                  label: const Text('Adicionar'),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Pesquise na TACO, escolha o alimento exato e informe '
              'quantos gramas entram no preparo.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (_ingredients.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(
                    child: Text('Nenhum ingrediente adicionado.'),
                  ),
                ),
              )
            else
              for (var index = 0;
                  index < _ingredients.length;
                  index++)
                Card(
                  child: ListTile(
                    onTap: () => _editQuantity(index),
                    leading: const CircleAvatar(
                      child: Icon(Icons.rice_bowl_outlined),
                    ),
                    title: Text(_ingredients[index].food.description),
                    subtitle: Text(
                      '${_format(_ingredients[index].quantityGrams)} g • '
                      '${_format(_ingredients[index].food.per100Grams.energyKcal)} '
                      'kcal/100 g',
                    ),
                    trailing: IconButton(
                      tooltip: 'Remover ingrediente',
                      onPressed: () => setState(
                        () => _ingredients.removeAt(index),
                      ),
                      icon: Icon(
                        Icons.delete_outline,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                ),
            const SizedBox(height: 18),
            Text(
              'Peso dos ingredientes: ${_format(_rawWeight)} g',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _finalWeightController,
              enabled: !_saving,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
              ],
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                labelText: 'Peso final após o preparo',
                suffixText: 'g',
                border: OutlineInputBorder(),
                helperText:
                    'Pese o item pronto, considerando água absorvida '
                    'ou perdida no cozimento.',
              ),
              validator: (value) {
                final parsed = double.tryParse(
                  value?.replaceAll(',', '.') ?? '',
                );
                return parsed == null || parsed <= 0
                    ? 'Informe o peso final preparado.'
                    : null;
              },
            ),
            const SizedBox(height: 20),
            if (_hasIncompleteNutrition) ...[
              Card(
                color: Theme.of(context).colorScheme.tertiaryContainer,
                child: const ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('Estimativa nutricional parcial'),
                  subtitle: Text(
                    'Alguns ingredientes não possuem todos os nutrientes '
                    'informados na TACO. Os valores conhecidos foram somados, '
                    'mas o total real pode ser maior.',
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
            _NutritionSummary(
              title: 'Total do item',
              nutrients: total,
            ),
            const SizedBox(height: 12),
            if (per100 == null)
              const Card(
                child: ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text(
                    'Informe o peso final para calcular os valores '
                    'por 100 g do item pronto.',
                  ),
                ),
              )
            else
              _NutritionSummary(
                title: 'Item pronto — por 100 g',
                nutrients: per100,
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saving ? null : _save,
        icon: _saving
            ? const SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.save_outlined),
        label: Text(_saving ? 'Salvando...' : 'Salvar item'),
      ),
    );
  }
}

class _NutritionSummary extends StatelessWidget {
  const _NutritionSummary({
    required this.title,
    required this.nutrients,
  });

  final String title;
  final Nutrients nutrients;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 14,
              runSpacing: 8,
              children: [
                Text('${_format(nutrients.energyKcal)} kcal'),
                Text('${_format(nutrients.proteinGrams)} g proteínas'),
                Text(
                  '${_format(nutrients.carbohydrateGrams)} g carboidratos',
                ),
                Text('${_format(nutrients.fatGrams)} g lipídios'),
                Text('${_format(nutrients.fiberGrams)} g fibras'),
                Text('${_format(nutrients.sodiumMilligrams)} mg sódio'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

double? _multiply(double? value, double factor) =>
    value == null ? null : value * factor;

String _formatInput(double value) => value
    .toStringAsFixed(2)
    .replaceFirst(RegExp(r'\.00$'), '')
    .replaceFirst(RegExp(r'(\.[0-9])0$'), r'$1')
    .replaceAll('.', ',');

String _format(double? value) {
  if (value == null) return 'não informado';
  if (value != 0 && value.abs() <= 0.0001) return 'traço';
  return _formatInput(value);
}
