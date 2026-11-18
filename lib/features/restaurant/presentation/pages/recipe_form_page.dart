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
  final _name = TextEditingController();
  final _description = TextEditingController();
  final _finalWeight = TextEditingController();
  final _referenceServing = TextEditingController();
  final _energy = TextEditingController();
  final _protein = TextEditingController();
  final _carbohydrate = TextEditingController();
  final _fat = TextEditingController();
  final _fiber = TextEditingController();
  final _sodium = TextEditingController();
  final List<NutritionalFoodSelection> _ingredients = [];

  String _mode = 'Taco';
  bool _saving = false;

  bool get _isLabel => _mode == 'Label';

  @override
  void initState() {
    super.initState();
    for (final controller in [
      _referenceServing,
      _energy,
      _protein,
      _carbohydrate,
      _fat,
      _fiber,
      _sodium,
    ]) {
      controller.addListener(_refresh);
    }
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    for (final controller in [
      _name,
      _description,
      _finalWeight,
      _referenceServing,
      _energy,
      _protein,
      _carbohydrate,
      _fat,
      _fiber,
      _sodium,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  double? _number(TextEditingController controller) =>
      double.tryParse(controller.text.replaceAll(',', '.'));

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

  Nutrients get _tacoTotal => Nutrients(
        energyKcal: _sumTaco((item) => item.energyKcal),
        proteinGrams: _sumTaco((item) => item.proteinGrams),
        carbohydrateGrams:
            _sumTaco((item) => item.carbohydrateGrams),
        fatGrams: _sumTaco((item) => item.fatGrams),
        fiberGrams: _sumTaco((item) => item.fiberGrams),
        sodiumMilligrams:
            _sumTaco((item) => item.sodiumMilligrams),
      );

  Nutrients? get _tacoPer100 {
    final weight = _number(_finalWeight);
    if (weight == null || weight <= 0) return null;
    return _scale(_tacoTotal, 100 / weight);
  }

  Nutrients? get _labelPer100 {
    final serving = _number(_referenceServing);
    if (serving == null || serving <= 0) return null;
    return _scale(
      Nutrients(
        energyKcal: _number(_energy),
        proteinGrams: _number(_protein),
        carbohydrateGrams: _number(_carbohydrate),
        fatGrams: _number(_fat),
        fiberGrams: _number(_fiber),
        sodiumMilligrams: _number(_sodium),
      ),
      100 / serving,
    );
  }

  double? _sumTaco(
    double? Function(Nutrients) selector,
  ) {
    final known = _ingredients
        .where(
          (item) =>
              selector(item.food.per100Grams) != null,
        )
        .toList();
    if (known.isEmpty) return null;
    return known.fold<double>(
      0,
      (total, item) =>
          total +
          selector(item.food.per100Grams)! *
              item.quantityGrams /
              100,
    );
  }

  Nutrients _scale(Nutrients values, double factor) =>
      Nutrients(
        energyKcal: _multiply(values.energyKcal, factor),
        proteinGrams:
            _multiply(values.proteinGrams, factor),
        carbohydrateGrams:
            _multiply(values.carbohydrateGrams, factor),
        fatGrams: _multiply(values.fatGrams, factor),
        fiberGrams: _multiply(values.fiberGrams, factor),
        sodiumMilligrams:
            _multiply(values.sodiumMilligrams, factor),
      );

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

    final index = _ingredients.indexWhere(
      (item) => item.food.id == selection.food.id,
    );
    setState(() {
      if (index < 0) {
        _ingredients.add(selection);
      } else {
        final existing = _ingredients[index];
        _ingredients[index] = existing.copyWith(
          quantityGrams:
              existing.quantityGrams +
              selection.quantityGrams,
        );
      }
    });
  }

  Future<void> _editQuantity(int index) async {
    final ingredient = _ingredients[index];
    final controller = TextEditingController(
      text: _format(ingredient.quantityGrams),
    );
    final quantity = await showDialog<double>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(ingredient.food.description),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType:
              const TextInputType.numberWithOptions(
            decimal: true,
          ),
          inputFormatters: [
            FilteringTextInputFormatter.allow(
              RegExp(r'[0-9,.]'),
            ),
          ],
          decoration: const InputDecoration(
            labelText: 'Quantidade',
            suffixText: 'g',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              final value = double.tryParse(
                controller.text.replaceAll(',', '.'),
              );
              Navigator.of(dialogContext).pop(
                value != null && value > 0
                    ? value
                    : null,
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
    if (!_isLabel && _ingredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Adicione pelo menos um ingrediente.',
          ),
        ),
      );
      return;
    }

    final session = AppSessionScope.read(context);
    final token = session.token;
    final establishmentId =
        session.user?.establishmentId;
    if (token == null || establishmentId == null) return;

    setState(() => _saving = true);
    try {
      final item = await RecipeRepository(
        session.apiClient,
        token,
      ).create(
        establishmentId: establishmentId,
        name: _name.text.trim(),
        description: _description.text.trim(),
        calculationMode: _mode,
        finalWeightGrams:
            _isLabel ? 0 : _number(_finalWeight)!,
        ingredients: _isLabel ? [] : _ingredients,
        manualNutrition: _isLabel
            ? {
                'referenceServingGrams':
                    _number(_referenceServing),
                'energyKcal': _number(_energy),
                'proteinGrams': _number(_protein),
                'carbohydrateGrams':
                    _number(_carbohydrate),
                'fatGrams': _number(_fat),
                'fiberGrams': _number(_fiber),
                'sodiumMilligrams': _number(_sodium),
              }
            : null,
      );
      if (mounted) Navigator.of(context).pop(item);
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

  String? _required(String? value) =>
      value == null || value.trim().isEmpty
          ? 'Campo obrigatório.'
          : null;

  String? _requiredNumber(String? value) {
    final number = double.tryParse(
      value?.replaceAll(',', '.') ?? '',
    );
    if (number == null) return 'Informe um número.';
    if (number < 0) {
      return 'O valor não pode ser negativo.';
    }
    return null;
  }

  String? _positiveNumber(String? value) {
    final number = double.tryParse(
      value?.replaceAll(',', '.') ?? '',
    );
    return number == null || number <= 0
        ? 'Informe um valor maior que zero.'
        : null;
  }

  @override
  Widget build(BuildContext context) {
    final tacoPer100 = _tacoPer100;
    final labelPer100 = _labelPer100;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo item personalizado'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding:
              const EdgeInsets.fromLTRB(16, 16, 16, 96),
          children: [
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(
                labelText: 'Nome do item',
                hintText:
                    'Ex.: Risoto de cenoura ou mel',
                border: OutlineInputBorder(),
              ),
              validator: _required,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _description,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Descrição (opcional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _mode,
              decoration: const InputDecoration(
                labelText: 'Como informar os nutrientes?',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'Taco',
                  child: Text(
                    'Montar com alimentos da TACO',
                  ),
                ),
                DropdownMenuItem(
                  value: 'Label',
                  child: Text(
                    'Informar dados do rótulo',
                  ),
                ),
              ],
              onChanged: _saving
                  ? null
                  : (value) => setState(
                        () => _mode = value ?? 'Taco',
                      ),
            ),
            const SizedBox(height: 20),
            if (_isLabel)
              ..._labelFields(labelPer100)
            else
              ..._tacoFields(tacoPer100),
          ],
        ),
      ),
      floatingActionButton:
          FloatingActionButton.extended(
        onPressed: _saving ? null : _save,
        icon: _saving
            ? const SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              )
            : const Icon(Icons.save_outlined),
        label: Text(
          _saving ? 'Salvando...' : 'Salvar item',
        ),
      ),
    );
  }

  List<Widget> _labelFields(Nutrients? per100) => [
        const Card(
          child: ListTile(
            leading: Icon(Icons.inventory_2_outlined),
            title: Text('Valores da embalagem'),
            subtitle: Text(
              'Informe a porção usada no rótulo. O LeafEat '
              'converterá os valores automaticamente para 100 g.',
            ),
          ),
        ),
        const SizedBox(height: 12),
        _numberField(
          _referenceServing,
          'Porção de referência',
          suffix: 'g',
          validator: _positiveNumber,
        ),
        _numberField(
          _energy,
          'Calorias na porção',
          suffix: 'kcal',
          validator: _requiredNumber,
        ),
        _numberField(
          _protein,
          'Proteínas na porção',
          suffix: 'g',
          validator: _requiredNumber,
        ),
        _numberField(
          _carbohydrate,
          'Carboidratos na porção',
          suffix: 'g',
          validator: _requiredNumber,
        ),
        _numberField(
          _fat,
          'Gorduras na porção',
          suffix: 'g',
          validator: _requiredNumber,
        ),
        _numberField(
          _fiber,
          'Fibras na porção (opcional)',
          suffix: 'g',
        ),
        _numberField(
          _sodium,
          'Sódio na porção (opcional)',
          suffix: 'mg',
        ),
        if (per100 != null) ...[
          const SizedBox(height: 6),
          _NutritionSummary(
            title: 'Conversão automática — por 100 g',
            nutrients: per100,
          ),
        ],
      ];

  List<Widget> _tacoFields(Nutrients? per100) => [
        Row(
          children: [
            Expanded(
              child: Text(
                'Ingredientes',
                style:
                    Theme.of(context).textTheme.titleLarge,
              ),
            ),
            FilledButton.icon(
              onPressed:
                  _saving ? null : _addIngredient,
              icon: const Icon(Icons.add),
              label: const Text('Adicionar'),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Pesquise na TACO e informe quantos gramas '
          'entram no preparo.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        if (_ingredients.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child:
                    Text('Nenhum ingrediente adicionado.'),
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
                title: Text(
                  _ingredients[index].food.description,
                ),
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
                    color:
                        Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
            ),
        const SizedBox(height: 14),
        Text(
          'Peso dos ingredientes: ${_format(_rawWeight)} g',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        _numberField(
          _finalWeight,
          'Peso final após o preparo',
          suffix: 'g',
          validator: _positiveNumber,
          helper:
              'Pese o item pronto considerando água '
              'absorvida ou perdida.',
        ),
        if (_hasIncompleteNutrition)
          Card(
            color:
                Theme.of(context).colorScheme.tertiaryContainer,
            child: const ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('Estimativa nutricional parcial'),
              subtitle: Text(
                'Alguns alimentos da TACO não possuem '
                'todos os nutrientes analisados.',
              ),
            ),
          ),
        _NutritionSummary(
          title: 'Total do item',
          nutrients: _tacoTotal,
        ),
        if (per100 != null) ...[
          const SizedBox(height: 12),
          _NutritionSummary(
            title: 'Item pronto — por 100 g',
            nutrients: per100,
          ),
        ],
      ];

  Widget _numberField(
    TextEditingController controller,
    String label, {
    String? suffix,
    String? helper,
    FormFieldValidator<String>? validator,
  }) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextFormField(
          controller: controller,
          keyboardType:
              const TextInputType.numberWithOptions(
            decimal: true,
          ),
          inputFormatters: [
            FilteringTextInputFormatter.allow(
              RegExp(r'[0-9,.]'),
            ),
          ],
          decoration: InputDecoration(
            labelText: label,
            suffixText: suffix,
            helperText: helper,
            border: const OutlineInputBorder(),
          ),
          validator: validator,
        ),
      );
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
      color: Theme.of(context)
          .colorScheme
          .surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style:
                  Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 14,
              runSpacing: 8,
              children: [
                Text(
                  '${_format(nutrients.energyKcal)} kcal',
                ),
                Text(
                  '${_format(nutrients.proteinGrams)} g proteínas',
                ),
                Text(
                  '${_format(nutrients.carbohydrateGrams)} g '
                  'carboidratos',
                ),
                Text(
                  '${_format(nutrients.fatGrams)} g lipídios',
                ),
                Text(
                  '${_format(nutrients.fiberGrams)} g fibras',
                ),
                Text(
                  '${_format(nutrients.sodiumMilligrams)} mg sódio',
                ),
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

String _format(double? value) {
  if (value == null) return 'não informado';
  if (value != 0 && value.abs() <= 0.0001) {
    return 'traço';
  }
  return value
      .toStringAsFixed(2)
      .replaceFirst(RegExp(r'\.00$'), '')
      .replaceFirst(RegExp(r'(\.[0-9])0$'), r'$1')
      .replaceAll('.', ',');
}
