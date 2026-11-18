import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:leafeat_mobile/app/session/app_session.dart';
import 'package:leafeat_mobile/core/network/api_exception.dart';
import 'package:leafeat_mobile/core/theme/app_colors.dart';
import 'package:leafeat_mobile/features/establishments/domain/models/dish.dart';
import 'package:leafeat_mobile/features/restaurant/data/nutritional_food.dart';
import 'package:leafeat_mobile/features/restaurant/data/restaurant_recipe.dart';
import 'package:leafeat_mobile/features/restaurant/data/restaurant_repository.dart';
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
      text: dish?.proteinGrams.toString(),
    );
    _carbohydrate = TextEditingController(
      text: dish?.carbohydrateGrams.toString(),
    );
    _fat = TextEditingController(text: dish?.fatGrams.toString());
    _fiber = TextEditingController(text: dish?.fiberGrams.toString());
    _automaticFromRecipes = dish?.recipeComponents.isNotEmpty ?? false;
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

  Nutrients get _recipeTotal => Nutrients(
        energyKcal: _sumRecipe((item) => item.energyKcal),
        proteinGrams: _sumRecipe((item) => item.proteinGrams),
        carbohydrateGrams:
            _sumRecipe((item) => item.carbohydrateGrams),
        fatGrams: _sumRecipe((item) => item.fatGrams),
        fiberGrams: _sumRecipe((item) => item.fiberGrams),
        sodiumMilligrams:
            _sumRecipe((item) => item.sodiumMilligrams),
      );

  double? _sumRecipe(double? Function(Nutrients) selector) {
    final known = _recipeComponents
        .where((item) => selector(item.per100Grams) != null)
        .toList();
    if (known.isEmpty) return null;
    return known.fold<double>(
      0,
      (total, item) =>
          total +
          selector(item.per100Grams)! * item.quantityGrams / 100,
    );
  }

  void _updateCalories() {
    if (mounted) setState(() {});
  }

  void _syncRecipeNutrition() {
    final total = _recipeTotal;
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
      };

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_automaticFromRecipes && _recipeComponents.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Adicione pelo menos uma receita ao prato.',
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
    final recipeTotal = _recipeTotal;
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
            const SizedBox(height: 8),
            Text(
              'Informações por porção',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Calcular usando receitas da casa',
              ),
              subtitle: const Text(
                'Informe quantos gramas de cada receita entram '
                'neste prato.',
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
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Composição do prato',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium,
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: _saving ? null : _addRecipe,
                    icon: const Icon(Icons.add),
                    label: const Text('Receita'),
                  ),
                ],
              ),
              if (_recipeComponents.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(
                      child: Text(
                        'Nenhuma receita adicionada.',
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
                        tooltip: 'Remover receita',
                        onPressed: () => _removeRecipe(index),
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ),
                  ),
              _NutritionSummary(nutrients: recipeTotal),
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
    (value ?? 0).toStringAsFixed(6);

String _format(double? value) {
  if (value == null) return 'não informado';
  return value
      .toStringAsFixed(2)
      .replaceFirst(RegExp(r'\.00$'), '')
      .replaceFirst(RegExp(r'(\.[0-9])0$'), r'$1')
      .replaceAll('.', ',');
}
