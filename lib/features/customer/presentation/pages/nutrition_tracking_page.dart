import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:leafeat_mobile/app/session/app_session.dart';
import 'package:leafeat_mobile/core/theme/app_colors.dart';
import 'package:leafeat_mobile/features/customer/data/customer_repository.dart';
import 'package:leafeat_mobile/features/customer/data/nutrition_entry.dart';
import 'package:leafeat_mobile/features/customer/data/nutrition_goals.dart';

class NutritionTrackingPage extends StatefulWidget {
  const NutritionTrackingPage({super.key});
  @override
  State<NutritionTrackingPage> createState() => _NutritionTrackingPageState();
}

class _NutritionTrackingPageState extends State<NutritionTrackingPage> {
  NutritionDay _day = const NutritionDay(entries: []);
  NutritionGoals _goals = const NutritionGoals();
  bool _initialized = false;
  bool _loading = true;
  String? _error;

  CustomerRepository? _repository() {
    final session = AppSessionScope.read(context);
    return session.token == null ? null : CustomerRepository(session.apiClient, session.token!);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    _load();
  }

  Future<void> _load() async {
    final repository = _repository();
    if (repository == null) {
      setState(() { _loading = false; _error = 'Faça login como cliente para acompanhar sua alimentação.'; });
      return;
    }
    try {
      final day = await repository.nutritionFor(DateTime.now());
      final goals = await repository.nutritionGoals();
      if (mounted) setState(() { _day = day; _goals = goals; _loading = false; _error = null; });
    } catch (error) {
      if (mounted) setState(() { _loading = false; _error = error.toString(); });
    }
  }

  Future<void> _editGoals() async {
    final goals = await showModalBottomSheet<NutritionGoals>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _NutritionGoalsForm(initial: _goals),
    );
    if (goals == null || !mounted) return;
    try {
      final saved = await _repository()!.updateNutritionGoals(goals);
      if (!mounted) return;
      setState(() => _goals = saved);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(saved.isConfigured
            ? 'Metas nutricionais atualizadas.'
            : 'Metas nutricionais removidas.')),
      );
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    }
  }

  Future<void> _addExternalMeal() async {
    final meal = await showModalBottomSheet<_MealInput>(context: context, isScrollControlled: true, useSafeArea: true, builder: (_) => const _ExternalMealForm());
    if (meal == null || !mounted) return;
    try {
      await _repository()!.addNutrition({
        'name': meal.name,
        'consumedAt': DateTime.now().toUtc().toIso8601String(),
        'calories': meal.calories.round(),
        'proteinGrams': meal.proteins,
        'carbohydrateGrams': meal.carbohydrates,
        'fatGrams': meal.fats,
        'fiberGrams': meal.fibers,
        'isExternal': true,
      });
      await _load();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${meal.name} adicionada ao resumo de hoje.')));
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  Future<void> _remove(NutritionEntry meal) async {
    try {
      await _repository()!.removeNutrition(meal.id);
      await _load();
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Macros e calorias'), backgroundColor: AppColors.primary, foregroundColor: AppColors.onPrimary),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Padding(padding: const EdgeInsets.all(32), child: Text(_error!, textAlign: TextAlign.center)))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(padding: const EdgeInsets.all(20), children: [
                    Row(children: [
                      Expanded(child: Text('Resumo de hoje', style: Theme.of(context).textTheme.headlineSmall)),
                      TextButton.icon(
                        onPressed: _editGoals,
                        icon: const Icon(Icons.flag_outlined),
                        label: Text(_goals.isConfigured ? 'Editar metas' : 'Definir metas'),
                      ),
                    ]),
                    const SizedBox(height: 16),
                    if (!_goals.isConfigured)
                      const Card(child: ListTile(
                        leading: Icon(Icons.info_outline),
                        title: Text('Nenhuma meta definida'),
                        subtitle: Text('Seus totais são exibidos sem comparação com valores genéricos.'),
                      )),
                    _ProgressCard(label: 'Calorias', current: _day.calories, goal: _goals.calories, unit: 'kcal'),
                    _ProgressCard(label: 'Proteínas', current: _day.proteins, goal: _goals.proteinGrams, unit: 'g'),
                    _ProgressCard(label: 'Carboidratos', current: _day.carbohydrates, goal: _goals.carbohydrateGrams, unit: 'g'),
                    _ProgressCard(label: 'Gorduras', current: _day.fats, goal: _goals.fatGrams, unit: 'g'),
                    _ProgressCard(label: 'Fibras', current: _day.fibers, goal: _goals.fiberGrams, unit: 'g'),
                    const SizedBox(height: 12),
                    FilledButton.icon(onPressed: _addExternalMeal, icon: const Icon(Icons.add), label: const Text('Adicionar refeição externa')),
                    const SizedBox(height: 24),
                    Text('Refeições de hoje', style: Theme.of(context).textTheme.titleLarge),
                    if (_day.entries.isEmpty) const Padding(padding: EdgeInsets.only(top: 16), child: Text('Nenhuma refeição registrada hoje.')),
                    ..._day.entries.map((meal) => Card(child: ListTile(
                      leading: Icon(meal.isExternal ? Icons.lunch_dining_outlined : Icons.restaurant),
                      title: Text(meal.name),
                      subtitle: Text('${_format(meal.calories)} kcal • ${_format(meal.carbohydrateGrams)} g carboidratos • ${_format(meal.proteinGrams)} g proteínas • ${_format(meal.fatGrams)} g gorduras'),
                      trailing: IconButton(tooltip: 'Remover refeição', onPressed: () => _remove(meal), icon: const Icon(Icons.delete_outline)),
                    ))),
                  ]),
                ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.label, required this.current, required this.goal, required this.unit});
  final String label;
  final double current;
  final double? goal;
  final String unit;
  @override
  Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(goal == null
            ? '$label consumidos: ${_format(current)} $unit'
            : '$label: ${_format(current)} de ${_format(goal!)} $unit',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        if (goal != null) ...[
          const SizedBox(height: 10),
          LinearProgressIndicator(value: (current / goal!).clamp(0, 1).toDouble()),
        ],
      ])));
}

class _NutritionGoalsForm extends StatefulWidget {
  const _NutritionGoalsForm({required this.initial});

  final NutritionGoals initial;

  @override
  State<_NutritionGoalsForm> createState() => _NutritionGoalsFormState();
}

class _NutritionGoalsFormState extends State<_NutritionGoalsForm> {
  final _formKey = GlobalKey<FormState>();
  late final List<TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = [
      TextEditingController(text: _initialValue(widget.initial.calories)),
      TextEditingController(text: _initialValue(widget.initial.proteinGrams)),
      TextEditingController(text: _initialValue(widget.initial.carbohydrateGrams)),
      TextEditingController(text: _initialValue(widget.initial.fatGrams)),
      TextEditingController(text: _initialValue(widget.initial.fiberGrams)),
    ];
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  String _initialValue(double? value) =>
      value == null ? '' : _format(value);

  double? _number(int index) => double.tryParse(
        _controllers[index].text.trim().replaceAll(',', '.'),
      );

  String? _requiredPositive(String? value) {
    final number = double.tryParse((value ?? '').trim().replaceAll(',', '.'));
    return number == null || number <= 0
        ? 'Informe um valor maior que zero.'
        : null;
  }

  String? _optionalPositive(String? value) {
    if ((value ?? '').trim().isEmpty) return null;
    return _requiredPositive(value);
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(NutritionGoals(
      calories: _number(0),
      proteinGrams: _number(1),
      carbohydrateGrams: _number(2),
      fatGrams: _number(3),
      fiberGrams: _number(4),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final fields = <(String, String, FormFieldValidator<String>)>[
      ('Calorias diárias', 'kcal', _requiredPositive),
      ('Proteínas diárias', 'g', _requiredPositive),
      ('Carboidratos diários', 'g', _requiredPositive),
      ('Gorduras diárias', 'g', _requiredPositive),
      ('Fibras diárias (opcional)', 'g', _optionalPositive),
    ];
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        20 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.initial.isConfigured
                    ? 'Editar metas nutricionais'
                    : 'Definir metas nutricionais',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 6),
              const Text(
                'Informe seus próprios valores. O LeafEat não calcula nem prescreve metas.',
              ),
              const SizedBox(height: 18),
              for (var index = 0; index < fields.length; index++) ...[
                TextFormField(
                  controller: _controllers[index],
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
                  ],
                  decoration: InputDecoration(
                    labelText: fields[index].$1,
                    suffixText: fields[index].$2,
                  ),
                  validator: fields[index].$3,
                ),
                const SizedBox(height: 12),
              ],
              FilledButton(
                onPressed: _save,
                child: const Text('Salvar metas'),
              ),
              if (widget.initial.isConfigured)
                TextButton(
                  onPressed: () => Navigator.of(context).pop(
                    const NutritionGoals(),
                  ),
                  child: const Text('Prefiro não informar minhas metas'),
                ),
            ],
          ),
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
  final _controllers = List.generate(6, (_) => TextEditingController());
  @override
  void dispose() { for (final controller in _controllers) { controller.dispose(); } super.dispose(); }
  double _number(int index) => double.parse(_controllers[index].text.trim().replaceAll(',', '.'));
  String? _validateNumber(String? value) {
    final number = double.tryParse((value ?? '').trim().replaceAll(',', '.'));
    return number == null || number < 0 ? 'Informe um valor válido' : null;
  }
  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(_MealInput(name: _controllers[0].text.trim(), calories: _number(1), carbohydrates: _number(2), proteins: _number(3), fats: _number(4), fibers: _number(5)));
  }
  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.viewInsetsOf(context).bottom),
        child: SingleChildScrollView(child: Form(key: _formKey, child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text('Adicionar refeição externa', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 18),
          TextFormField(controller: _controllers[0], decoration: const InputDecoration(labelText: 'Nome da refeição'), validator: (value) => (value ?? '').trim().isEmpty ? 'Informe o nome da refeição' : null),
          const SizedBox(height: 12),
          for (final field in [(1, 'Calorias', 'kcal'), (2, 'Carboidratos', 'g'), (3, 'Proteínas', 'g'), (4, 'Gorduras', 'g'), (5, 'Fibras', 'g')]) ...[
            TextFormField(controller: _controllers[field.$1], keyboardType: const TextInputType.numberWithOptions(decimal: true), inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]'))], decoration: InputDecoration(labelText: field.$2, suffixText: field.$3), validator: _validateNumber),
            const SizedBox(height: 12),
          ],
          FilledButton(onPressed: _save, child: const Text('Adicionar ao resumo')),
        ]))),
      );
}

class _MealInput {
  const _MealInput({required this.name, required this.calories, required this.carbohydrates, required this.proteins, required this.fats, required this.fibers});
  final String name;
  final double calories;
  final double carbohydrates;
  final double proteins;
  final double fats;
  final double fibers;
}

String _format(double value) => value == value.roundToDouble() ? value.toStringAsFixed(0) : value.toStringAsFixed(1).replaceAll('.', ',');
