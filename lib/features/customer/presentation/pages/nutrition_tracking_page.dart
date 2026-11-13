import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:leafeat_mobile/app/session/app_session.dart';
import 'package:leafeat_mobile/core/theme/app_colors.dart';
import 'package:leafeat_mobile/features/customer/data/customer_repository.dart';
import 'package:leafeat_mobile/features/customer/data/nutrition_entry.dart';

class NutritionTrackingPage extends StatefulWidget {
  const NutritionTrackingPage({super.key});
  @override
  State<NutritionTrackingPage> createState() => _NutritionTrackingPageState();
}

class _NutritionTrackingPageState extends State<NutritionTrackingPage> {
  NutritionDay _day = const NutritionDay(entries: []);
  bool _loading = true;
  String? _error;

  CustomerRepository? _repository() {
    final session = AppSessionScope.read(context);
    return session.token == null ? null : CustomerRepository(session.apiClient, session.token!);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loading && _error == null && _day.entries.isEmpty) _load();
  }

  Future<void> _load() async {
    final repository = _repository();
    if (repository == null) {
      setState(() { _loading = false; _error = 'Faça login como cliente para acompanhar sua alimentação.'; });
      return;
    }
    try {
      final day = await repository.nutritionFor(DateTime.now());
      if (mounted) setState(() { _day = day; _loading = false; _error = null; });
    } catch (error) {
      if (mounted) setState(() { _loading = false; _error = error.toString(); });
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
                    Text('Resumo de hoje', style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 16),
                    _ProgressCard(label: 'Calorias', current: _day.calories, goal: 2000, unit: 'kcal'),
                    _ProgressCard(label: 'Proteínas', current: _day.proteins, goal: 110, unit: 'g'),
                    _ProgressCard(label: 'Carboidratos', current: _day.carbohydrates, goal: 240, unit: 'g'),
                    _ProgressCard(label: 'Gorduras', current: _day.fats, goal: 65, unit: 'g'),
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
  final double goal;
  final String unit;
  @override
  Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('$label: ${_format(current)} de ${_format(goal)} $unit', style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        LinearProgressIndicator(value: (current / goal).clamp(0, 1).toDouble()),
      ])));
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
