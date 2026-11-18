import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:leafeat_mobile/app/session/app_session.dart';
import 'package:leafeat_mobile/core/network/api_exception.dart';
import 'package:leafeat_mobile/core/theme/app_colors.dart';
import 'package:leafeat_mobile/features/establishments/domain/models/dish.dart';
import 'package:leafeat_mobile/features/restaurant/data/nutritional_food.dart';
import 'package:leafeat_mobile/features/restaurant/data/restaurant_recipe.dart';
import 'package:leafeat_mobile/features/restaurant/data/restaurant_repository.dart';
import 'package:leafeat_mobile/features/restaurant/presentation/pages/nutritional_catalog_page.dart';
import 'package:leafeat_mobile/features/restaurant/presentation/pages/restaurant_recipes_page.dart';

class DishFormPage extends StatefulWidget {
  const DishFormPage({this.dish, super.key});

  final Dish? dish;

  @override
  State<DishFormPage> createState() => _DishFormPageState();
}

class _DishFormPageState extends State<DishFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _description;
  late final TextEditingController _price;
  late final TextEditingController _protein;
  late final TextEditingController _carbohydrate;
  late final TextEditingController _fat;
  late final TextEditingController _fiber;
  final List<DishRecipeSelection> _recipeComponents = [];
  final List<DishFoodSelection> _foodComponents = [];
  late bool _automaticFromRecipes;
  late bool _isVegan;
  late bool _isLactoseFree;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final dish = widget.dish;
    _name = TextEditingController(text: dish?.name);
    _description = TextEditingController(text: dish?.description);
    _price = TextEditingController(
      text: dish?.price.toStringAsFixed(2),
    );
    _protein = TextEditingController(
      text: dish == null ? null : _format(dish.proteinGrams),
    );
    _carbohydrate = TextEditingController(
      text: dish == null
          ? null
          : _format(dish.carbohydrateGrams),
    );
    _fat = TextEditingController(
      text: dish == null ? null : _format(dish.fatGrams),
    );
    _fiber = TextEditingController(
      text: dish == null ? null : _format(dish.fiberGrams),
    );
    _automaticFromRecipes = dish != null &&
        (dish.recipeComponents.isNotEmpty ||
            dish.foodComponents.isNotEmpty);
    _isVegan = dish?.isVegan ?? false;
    _isLactoseFree = dish?.isLactoseFree ?? false;

    if (dish != null) {
      for (final component in dish.recipeComponents) {
        _recipeComponents.add(
          DishRecipeSelection(
            recipeId: component.recipeId,
            recipeName: component.recipeName,
            quantityGrams: component.quantityGrams,
            per100Grams: Nutrients(
              energyKcal: component.energyKcal,
              proteinGrams: component.proteinGrams,
              carbohydrateGrams: component.carbohydrateGrams,
              fatGrams: component.fatGrams,
              fiberGrams: component.fiberGrams,
              sodiumMilligrams: component.sodiumMilligrams,
            ),
          ),
        );
      }
      for (final component in dish.foodComponents) {
        _foodComponents.add(
          DishFoodSelection(
            nutritionalFoodId: component.nutritionalFoodId,
            foodName: component.foodName,
            preparation: component.preparation,
            quantityGrams: component.quantityGrams,
            per100Grams: Nutrients(
              energyKcal: component.energyKcal,
              proteinGrams: component.proteinGrams,
              carbohydrateGrams: component.carbohydrateGrams,
              fatGrams: component.fatGrams,
              fiberGrams: component.fiberGrams,
              sodiumMilligrams: component.sodiumMilligrams,
            ),
          ),
        );
      }
    }

    for (final controller in [_protein, _carbohydrate, _fat]) {
      controller.addListener(_updateCalories);
    }
  }

  @override
  void dispose() {
    for (final controller in [
      _name,
      _description,
      _price,
      _protein,
      _carbohydrate,
      _fat,
      _fiber,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  double _number(TextEditingController controller) =>
      double.parse(controller.text.replaceAll(',', '.'));

  double _numberOrZero(TextEditingController controller) =>
      double.tryParse(controller.text.replaceAll(',', '.')) ?? 0;

  int get _calculatedCalories => Dish.calculateCalories(
        proteinGrams: _numberOrZero(_protein),
        carbohydrateGrams: _numberOrZero(_carbohydrate),
        fatGrams: _numberOrZero(_fat),
      );

  Nutrients get _componentTotal => Nutrients(
        energyKcal: _sumComponents((item) => item.energyKcal),
        proteinGrams: _sumComponents((item) => item.proteinGrams),
        carbohydrateGrams:
            _sumComponents((item) => item.carbohydrateGrams),
        fatGrams: _sumComponents((item) => item.fatGrams),
        fiberGrams: _sumComponents((item) => item.fiberGrams),
        sodiumMilligrams:
            _sumComponents((item) => item.sodiumMilligrams),
      );

  double? _sumComponents(double? Function(Nutrients) selector) {
    var hasKnownValue = false;
    var total = 0.0;
    for (final component in _recipeComponents) {
      final value = selector(component.per100Grams);
      if (value == null) continue;
      hasKnownValue = true;
      total += value * component.quantityGrams / 100;
    }
    for (final component in _foodComponents) {
      final value = selector(component.per100Grams);
      if (value == null) continue;
      hasKnownValue = true;
      total += value * component.quantityGrams / 100;
    }
    return hasKnownValue ? total : null;
  }

  void _updateCalories() {
    if (mounted) setState(() {});
  }

  void _syncRecipeNutrition() {
    final total = _componentTotal;
    _protein.text = _requestNumber(total.proteinGrams);
    _carbohydrate.text = _requestNumber(total.carbohydrateGrams);
    _fat.text = _requestNumber(total.fatGrams);
    _fiber.text = _requestNumber(total.fiberGrams);
  }

  Future<void> _addRecipe() async {
    final selection = await Navigator.of(context)
        .push<DishRecipeSelection>(
      MaterialPageRoute(
        builder: (_) => const RestaurantRecipesPage(
          selectionMode: true,
        ),
      ),
    );
    if (selection == null || !mounted) return;

    final index = _recipeComponents.indexWhere(
      (item) => item.recipeId == selection.recipeId,
    );
    setState(() {
      if (index < 0) {
        _recipeComponents.add(selection);
      } else {
        final existing = _recipeComponents[index];
        _recipeComponents[index] = existing.copyWith(
          quantityGrams:
              existing.quantityGrams + selection.quantityGrams,
        );
      }
    });
    _syncRecipeNutrition();
  }


  Future<void> _addFood() async {
    final catalogSelection = await Navigator.of(context)
        .push<NutritionalFoodSelection>(
      MaterialPageRoute(
        builder: (_) => const NutritionalCatalogPage(
          selectionMode: true,
        ),
      ),
    );
    if (catalogSelection == null || !mounted) return;
    final selection = DishFoodSelection.fromCatalog(
      catalogSelection,
    );
    final index = _foodComponents.indexWhere(
      (item) =>
          item.nutritionalFoodId == selection.nutritionalFoodId,
    );
    setState(() {
      if (index < 0) {
        _foodComponents.add(selection);
      } else {
        final existing = _foodComponents[index];
        _foodComponents[index] = existing.copyWith(
          quantityGrams:
              existing.quantityGrams + selection.quantityGrams,
        );
      }
    });
    _syncRecipeNutrition();
  }

  Future<void> _editFoodQuantity(int index) async {
    final component = _foodComponents[index];
    final controller = TextEditingController(
      text: _format(component.quantityGrams),
    );
    final quantity = await showDialog<double>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(component.foodName),
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
            labelText: 'Quantidade usada no prato',
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
              final parsed = double.tryParse(
                controller.text.replaceAll(',', '.'),
              );
              Navigator.of(dialogContext).pop(
                parsed != null && parsed > 0 ? parsed : null,
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
      _foodComponents[index] = component.copyWith(
        quantityGrams: quantity,
      );
    });
    _syncRecipeNutrition();
  }

  Future<void> _editRecipeQuantity(int index) async {
    final component = _recipeComponents[index];
    final controller = TextEditingController(
      text: _format(component.quantityGrams),
    );
    final quantity = await showDialog<double>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(component.recipeName),
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
            labelText: 'Quantidade usada no prato',
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
              final parsed = double.tryParse(
                controller.text.replaceAll(',', '.'),
              );
              Navigator.of(dialogContext).pop(
                parsed != null && parsed > 0 ? parsed : null,
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
      _recipeComponents[index] = component.copyWith(
        quantityGrams: quantity,
      );
    });
    _syncRecipeNutrition();
  }

  void _removeRecipe(int index) {
    setState(() => _recipeComponents.removeAt(index));
    _syncRecipeNutrition();
  }

  void _removeFood(int index) {
    setState(() => _foodComponents.removeAt(index));
    _syncRecipeNutrition();
  }

  Map<String, dynamic> _requestBody() => {
        'name': _name.text.trim(),
        'description': _description.text.trim(),
        'price': _number(_price),
        'proteinGrams': _number(_protein),
        'carbohydrateGrams': _number(_carbohydrate),
        'fatGrams': _number(_fat),
        'fiberGrams': _number(_fiber),
        'isVegan': _isVegan,
        'isLactoseFree': _isLactoseFree,
        'hasNutritionInformation': true,
        'recipeComponents': _automaticFromRecipes
            ? _recipeComponents
                .map((item) => item.toRequestJson())
                .toList()
            : <Map<String, dynamic>>[],
        'foodComponents': _automaticFromRecipes
            ? _foodComponents
                .map((item) => item.toRequestJson())
                .toList()
            : <Map<String, dynamic>>[],
      };

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_automaticFromRecipes &&
        _recipeComponents.isEmpty &&
        _foodComponents.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Adicione um item personalizado ou um alimento ao prato.',
          ),
        ),
      );
      return;
    }

    final session = AppSessionScope.read(context);
    final establishmentId = session.user?.establishmentId;
    if (session.token == null || establishmentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Entre como restaurante para salvar o prato.',
          ),
        ),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final repository = RestaurantRepository(
        session.apiClient,
        session.token!,
      );
      final existing = widget.dish;
      final dish = existing == null
          ? await repository.createDish(
              establishmentId,
              _requestBody(),
            )
          : await repository.updateDish(
              establishmentId,
              existing.id,
              _requestBody(),
            );
      if (mounted) Navigator.of(context).pop(dish);
    } on ApiException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message)),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String? _required(String? value) =>
      value == null || value.trim().isEmpty
          ? 'Campo obrigatório.'
          : null;

  String? _numeric(String? value) {
    if (_required(value) != null) return 'Campo obrigatório.';
    final number = double.tryParse(value!.replaceAll(',', '.'));
    if (number == null) return 'Informe um número válido.';
    if (number < 0) return 'O valor não pode ser negativo.';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.dish != null;
    final componentTotal = _componentTotal;
    return Scaffold(
      appBar: AppBar(
        title: Text(editing ? 'Editar prato' : 'Novo prato'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _field(
              _name,
              'Nome do prato',
              validator: _required,
            ),
            _field(
              _description,
              'Descrição',
              validator: _required,
              maxLines: 3,
            ),
            _field(
              _price,
              'Preço (R\$)',
              validator: _numeric,
              numeric: true,
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const SizedBox.square(
                      dimension: 64,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Color(0xFFE7EEE5),
                          borderRadius: BorderRadius.all(
                            Radius.circular(12),
                          ),
                        ),
                        child: Icon(
                          Icons.add_photo_alternate_outlined,
                          size: 30,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Foto do prato',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Envio de imagens será disponibilizado '
                            'em uma próxima etapa.',
                          ),
                        ],
                      ),
                    ),
                    OutlinedButton(
                      onPressed: null,
                      child: Text('Em breve'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Informações por porção',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Calcular usando componentes',
              ),
              subtitle: const Text(
                'Use itens personalizados e/ou alimentos prontos da '
                'TACO, informando a quantidade em gramas.',
              ),
              value: _automaticFromRecipes,
              onChanged: _saving
                  ? null
                  : (value) {
                      setState(
                        () => _automaticFromRecipes = value,
                      );
                      if (value) _syncRecipeNutrition();
                    },
            ),
            if (_automaticFromRecipes) ...[
              Text(
                'Composição do prato',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton.icon(
                    onPressed: _saving ? null : _addRecipe,
                    icon: const Icon(Icons.menu_book_outlined),
                    label: const Text('Item personalizado'),
                  ),
                  OutlinedButton.icon(
                    onPressed: _saving ? null : _addFood,
                    icon: const Icon(Icons.egg_alt_outlined),
                    label: const Text('Alimento da TACO'),
                  ),
                ],
              ),
              if (_recipeComponents.isEmpty &&
                  _foodComponents.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(
                      child: Text(
                        'Nenhum componente adicionado.',
                      ),
                    ),
                  ),
                )
              else
                for (var index = 0;
                    index < _recipeComponents.length;
                    index++)
                  Card(
                    child: ListTile(
                      onTap: () => _editRecipeQuantity(index),
                      leading: const CircleAvatar(
                        child: Icon(
                          Icons.soup_kitchen_outlined,
                        ),
                      ),
                      title: Text(
                        _recipeComponents[index].recipeName,
                      ),
                      subtitle: Text(
                        '${_format(_recipeComponents[index].quantityGrams)} g '
                        'usados no prato',
                      ),
                      trailing: IconButton(
                        tooltip: 'Remover item',
                        onPressed: () => _removeRecipe(index),
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ),
                  ),
              for (var index = 0;
                  index < _foodComponents.length;
                  index++)
                Card(
                  child: ListTile(
                    onTap: () => _editFoodQuantity(index),
                    leading: const CircleAvatar(
                      child: Icon(Icons.egg_alt_outlined),
                    ),
                    title: Text(_foodComponents[index].foodName),
                    subtitle: Text(
                      '${_format(_foodComponents[index].quantityGrams)} g '
                      'usados no prato • TACO',
                    ),
                    trailing: IconButton(
                      tooltip: 'Remover alimento',
                      onPressed: () => _removeFood(index),
                      icon: const Icon(Icons.delete_outline),
                    ),
                  ),
                ),
              _NutritionSummary(nutrients: componentTotal),
            ] else ...[
              Card(
                child: ListTile(
                  leading: const Icon(
                    Icons.local_fire_department_outlined,
                  ),
                  title: const Text(
                    'Calorias calculadas automaticamente',
                  ),
                  subtitle: const Text(
                    'Proteínas e carboidratos: 4 kcal/g • '
                    'Gorduras: 9 kcal/g',
                  ),
                  trailing: Text(
                    '$_calculatedCalories kcal',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              _field(
                _protein,
                'Proteínas (g)',
                validator: _numeric,
                numeric: true,
              ),
              _field(
                _carbohydrate,
                'Carboidratos (g)',
                validator: _numeric,
                numeric: true,
              ),
              _field(
                _fat,
                'Gorduras (g)',
                validator: _numeric,
                numeric: true,
              ),
              _field(
                _fiber,
                'Fibras (g)',
                validator: _numeric,
                numeric: true,
              ),
            ],
            SwitchListTile(
              title: const Text('Prato vegano'),
              value: _isVegan,
              onChanged: (value) =>
                  setState(() => _isVegan = value),
            ),
            SwitchListTile(
              title: const Text('Sem lactose'),
              value: _isLactoseFree,
              onChanged: (value) =>
                  setState(() => _isLactoseFree = value),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: const Icon(Icons.save),
              label: Text(
                _saving
                    ? 'Salvando...'
                    : editing
                        ? 'Salvar alterações'
                        : 'Cadastrar prato',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    required FormFieldValidator<String> validator,
    bool numeric = false,
    int maxLines = 1,
  }) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
          ),
          keyboardType: numeric
              ? const TextInputType.numberWithOptions(
                  decimal: true,
                )
              : TextInputType.text,
          maxLines: maxLines,
          validator: validator,
        ),
      );
}

class _NutritionSummary extends StatelessWidget {
  const _NutritionSummary({required this.nutrients});

  final Nutrients nutrients;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Wrap(
          spacing: 14,
          runSpacing: 8,
          children: [
            Text('${_format(nutrients.energyKcal)} kcal'),
            Text(
              '${_format(nutrients.proteinGrams)} g proteínas',
            ),
            Text(
              '${_format(nutrients.carbohydrateGrams)} g carboidratos',
            ),
            Text('${_format(nutrients.fatGrams)} g lipídios'),
            Text('${_format(nutrients.fiberGrams)} g fibras'),
          ],
        ),
      ),
    );
  }
}

String _requestNumber(double? value) =>
    (value ?? 0).toStringAsFixed(2);

String _format(double? value) {
  if (value == null) return 'não informado';
  return value
      .toStringAsFixed(2)
      .replaceFirst(RegExp(r'\.00$'), '')
      .replaceFirst(RegExp(r'(\.[0-9])0$'), r'$1')
      .replaceAll('.', ',');
}
