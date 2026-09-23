import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:leafeat_mobile/core/theme/app_colors.dart';

class NutritionTrackingPage extends StatefulWidget {
  const NutritionTrackingPage({super.key});

  @override
  State<NutritionTrackingPage> createState() => _NutritionTrackingPageState();
}

class _NutritionTrackingPageState extends State<NutritionTrackingPage> {
  static const _initialCalories = 1280.0;
  static const _initialProteins = 72.0;
  static const _initialCarbohydrates = 145.0;
  static const _initialFats = 44.0;

  final List<_ExternalMeal> _externalMeals = [];

  double get _calories => _initialCalories + _externalMeals.fold<double>(0, (total, meal) => total + meal.calories);
  double get _proteins => _initialProteins + _externalMeals.fold<double>(0, (total, meal) => total + meal.proteins);
  double get _carbohydrates => _initialCarbohydrates + _externalMeals.fold<double>(0, (total, meal) => total + meal.carbohydrates);
  double get _fats => _initialFats + _externalMeals.fold<double>(0, (total, meal) => total + meal.fats);

  Future<void> _addExternalMeal() async {
    final meal = await showModalBottomSheet<_ExternalMeal>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const _ExternalMealForm(),
    );
    if (meal == null || !mounted) return;

    setState(() => _externalMeals.add(meal));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${meal.name} adicionada ao resumo de hoje.')),
    );
  }

  void _removeExternalMeal(_ExternalMeal meal) {
    setState(() => _externalMeals.remove(meal));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${meal.name} removida do resumo.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Macros e calorias'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Resumo de hoje', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          _ProgressCard(label: 'Calorias', current: _calories, goal: 2000, unit: 'kcal'),
          _ProgressCard(label: 'Proteínas', current: _proteins, goal: 110, unit: 'g'),
          _ProgressCard(label: 'Carboidratos', current: _carbohydrates, goal: 240, unit: 'g'),
          _ProgressCard(label: 'Gorduras', current: _fats, goal: 65, unit: 'g'),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _addExternalMeal,
            icon: const Icon(Icons.add),
            label: const Text('Adicionar refeição externa'),
          ),
          if (_externalMeals.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text('Refeições externas de hoje', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            ..._externalMeals.map(
              (meal) => Card(
                child: ListTile(
                  leading: const Icon(Icons.lunch_dining_outlined),
                  title: Text(meal.name),
                  subtitle: Text(
                    '${_format(meal.calories)} kcal • '
                    '${_format(meal.carbohydrates)} g carboidratos • '
                    '${_format(meal.proteins)} g proteínas • '
                    '${_format(meal.fats)} g gorduras',
                  ),
                  trailing: IconButton(
                    tooltip: 'Remover refeição',
                    onPressed: () => _removeExternalMeal(meal),
                    icon: const Icon(Icons.delete_outline),
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          const Text('Valores demonstrativos mantidos somente em memória.'),
        ],
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.label, required this.current, required this.goal, required this.unit});

  final String label;
  final double current;
  final double goal;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$label: ${_format(current)} de ${_format(goal)} $unit', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            LinearProgressIndicator(value: (current / goal).clamp(0, 1).toDouble()),
          ],
        ),
      ),
    );
  }
}

class _ExternalMealForm extends StatefulWidget {
  const _ExternalMealForm();

  @override
  State<_ExternalMealForm> createState() => _ExternalMealFormState();
}

class _ExternalMealFormState extends State<_ExternalMealForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _carbohydratesController = TextEditingController();
  final _proteinsController = TextEditingController();
  final _fatsController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _caloriesController.dispose();
    _carbohydratesController.dispose();
    _proteinsController.dispose();
    _fatsController.dispose();
    super.dispose();
  }

  double _numberOf(TextEditingController controller) => double.parse(controller.text.trim().replaceAll(',', '.'));

  String? _validateNumber(String? value) {
    final number = double.tryParse((value ?? '').trim().replaceAll(',', '.'));
    if (number == null || number < 0) return 'Informe um valor válido';
    return null;
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(
      _ExternalMeal(
        name: _nameController.text.trim(),
        calories: _numberOf(_caloriesController),
        carbohydrates: _numberOf(_carbohydratesController),
        proteins: _numberOf(_proteinsController),
        fats: _numberOf(_fatsController),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomPadding),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Adicionar refeição externa', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 6),
              const Text('Informe os valores aproximados da porção consumida.'),
              const SizedBox(height: 18),
              TextFormField(
                controller: _nameController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'Nome da refeição'),
                validator: (value) => (value ?? '').trim().isEmpty ? 'Informe o nome da refeição' : null,
              ),
              const SizedBox(height: 12),
              _NumberField(controller: _caloriesController, label: 'Calorias', suffix: 'kcal', validator: _validateNumber),
              const SizedBox(height: 12),
              _NumberField(controller: _carbohydratesController, label: 'Carboidratos', suffix: 'g', validator: _validateNumber),
              const SizedBox(height: 12),
              _NumberField(controller: _proteinsController, label: 'Proteínas', suffix: 'g', validator: _validateNumber),
              const SizedBox(height: 12),
              _NumberField(controller: _fatsController, label: 'Gorduras', suffix: 'g', validator: _validateNumber),
              const SizedBox(height: 20),
              FilledButton(onPressed: _save, child: const Text('Adicionar ao resumo')),
            ],
          ),
        ),
      ),
    );
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({required this.controller, required this.label, required this.suffix, required this.validator});

  final TextEditingController controller;
  final String label;
  final String suffix;
  final FormFieldValidator<String> validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]'))],
      decoration: InputDecoration(labelText: label, suffixText: suffix),
      validator: validator,
    );
  }
}

class _ExternalMeal {
  const _ExternalMeal({required this.name, required this.calories, required this.carbohydrates, required this.proteins, required this.fats});

  final String name;
  final double calories;
  final double carbohydrates;
  final double proteins;
  final double fats;
}

String _format(double value) => value == value.roundToDouble() ? value.toStringAsFixed(0) : value.toStringAsFixed(1).replaceAll('.', ',');
