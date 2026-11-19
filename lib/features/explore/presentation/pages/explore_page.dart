import 'package:flutter/material.dart';
import 'package:leafeat_mobile/app/session/app_session.dart';
import 'package:leafeat_mobile/core/theme/app_colors.dart';
import 'package:leafeat_mobile/features/customer/data/food_preferences.dart';
import 'package:leafeat_mobile/features/establishments/data/dish_search_result.dart';
import 'package:leafeat_mobile/features/establishments/data/establishments_repository.dart';
import 'package:leafeat_mobile/features/explore/presentation/pages/establishment_detail_page.dart';
import 'package:leafeat_mobile/features/explore/presentation/widgets/badge_chip.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final _formKey = GlobalKey<FormState>();
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbohydrateController = TextEditingController();
  final _fatController = TextEditingController();

  List<DishSearchResult>? _results;
  FoodPreferences? _appliedPreferences;
  bool _vegan = false;
  bool _lactoseFree = false;
  bool _loading = false;
  String? _error;
  _NutritionTarget? _lastTarget;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final session = AppSessionScope.maybeRead(context);
    final preferences = session?.foodPreferences;
    if (preferences == null || preferences == _appliedPreferences) return;
    _appliedPreferences = preferences;
    _vegan = preferences.vegan;
    _lactoseFree = preferences.lactoseFree;
  }

  @override
  void dispose() {
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbohydrateController.dispose();
    _fatController.dispose();
    super.dispose();
  }

  double? _numberOf(TextEditingController controller) {
    final value = controller.text.trim().replaceAll(',', '.');
    return value.isEmpty ? null : double.tryParse(value);
  }

  String? _validateNumber(String? value) {
    final normalized = value?.trim().replaceAll(',', '.') ?? '';
    if (normalized.isEmpty) return null;
    final number = double.tryParse(normalized);
    if (number == null || number <= 0) return 'Use um valor maior que zero';
    return null;
  }

  Future<void> _search() async {
    if (!_formKey.currentState!.validate()) return;
    final target = _NutritionTarget(
      calories: _numberOf(_caloriesController)?.round(),
      proteinGrams: _numberOf(_proteinController),
      carbohydrateGrams: _numberOf(_carbohydrateController),
      fatGrams: _numberOf(_fatController),
    );
    if (!target.hasAnyValue) {
      setState(() => _error =
          'Informe ao menos uma meta: calorias, proteínas, carboidratos ou lipídios.');
      return;
    }

    final session = AppSessionScope.maybeRead(context);
    if (session == null) {
      setState(() => _error = 'Não foi possível acessar a configuração da API.');
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
      _error = null;
      _lastTarget = target;
    });
    try {
      final results = await EstablishmentsRepository(session.apiClient)
          .searchDishes(
        calories: target.calories,
        proteinGrams: target.proteinGrams,
        carbohydrateGrams: target.carbohydrateGrams,
        fatGrams: target.fatGrams,
        vegan: _vegan,
        lactoseFree: _lactoseFree,
      );
      if (mounted) setState(() => _results = results);
    } catch (_) {
      if (mounted) {
        setState(() => _error =
            'Não foi possível buscar os pratos. Confirme se a API está em execução.');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _clear() {
    _formKey.currentState?.reset();
    _caloriesController.clear();
    _proteinController.clear();
    _carbohydrateController.clear();
    _fatController.clear();
    setState(() {
      _results = null;
      _lastTarget = null;
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar pratos'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Qual meta você quer atingir?',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Preencha apenas o que importa para você. Os restaurantes serão '
              'ordenados pelo prato mais próximo da sua meta.',
            ),
            const SizedBox(height: 20),
            Form(
              key: _formKey,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final fieldWidth = constraints.maxWidth >= 520
                      ? (constraints.maxWidth - 12) / 2
                      : constraints.maxWidth;
                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _TargetField(
                        width: fieldWidth,
                        controller: _caloriesController,
                        label: 'Calorias',
                        suffix: 'kcal',
                        icon: Icons.local_fire_department_outlined,
                        validator: _validateNumber,
                        decimal: false,
                        onSubmitted: (_) => _search(),
                      ),
                      _TargetField(
                        width: fieldWidth,
                        controller: _proteinController,
                        label: 'Proteínas',
                        suffix: 'g',
                        icon: Icons.fitness_center,
                        validator: _validateNumber,
                        onSubmitted: (_) => _search(),
                      ),
                      _TargetField(
                        width: fieldWidth,
                        controller: _carbohydrateController,
                        label: 'Carboidratos',
                        suffix: 'g',
                        icon: Icons.grain,
                        validator: _validateNumber,
                        onSubmitted: (_) => _search(),
                      ),
                      _TargetField(
                        width: fieldWidth,
                        controller: _fatController,
                        label: 'Lipídios',
                        suffix: 'g',
                        icon: Icons.opacity_outlined,
                        validator: _validateNumber,
                        onSubmitted: (_) => _search(),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Card(
              margin: EdgeInsets.zero,
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Somente pratos veganos'),
                    value: _vegan,
                    onChanged: (value) => setState(() => _vegan = value),
                  ),
                  SwitchListTile(
                    title: const Text('Somente pratos sem lactose'),
                    value: _lactoseFree,
                    onChanged: (value) => setState(() => _lactoseFree = value),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _loading ? null : _clear,
                    child: const Text('Limpar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: FilledButton.icon(
                    onPressed: _loading ? null : _search,
                    icon: const Icon(Icons.search),
                    label: const Text('Buscar melhores pratos'),
                  ),
                ),
              ],
            ),
            if (_loading) ...[
              const SizedBox(height: 20),
              const LinearProgressIndicator(),
            ],
            if (_error != null) ...[
              const SizedBox(height: 16),
              Card(
                color: Theme.of(context).colorScheme.errorContainer,
                child: ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: Text(_error!),
                ),
              ),
            ],
            const SizedBox(height: 24),
            _buildResults(context),
          ],
        ),
      ),
    );
  }

  Widget _buildResults(BuildContext context) {
    final results = _results;
    if (results == null) return const _SearchEmptyState();
    if (results.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 28),
        child: Column(
          children: [
            Icon(Icons.search_off, size: 56),
            SizedBox(height: 12),
            Text('Nenhum prato com informações nutricionais foi encontrado.'),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${results.length} restaurantes com os pratos mais próximos',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 6),
        const Text('O primeiro resultado é o que mais se aproxima da meta.'),
        const SizedBox(height: 14),
        ...results.map(
          (result) => _ResultCard(
            result: result,
            target: _lastTarget!,
          ),
        ),
      ],
    );
  }
}

class _TargetField extends StatelessWidget {
  const _TargetField({
    required this.width,
    required this.controller,
    required this.label,
    required this.suffix,
    required this.icon,
    required this.validator,
    required this.onSubmitted,
    this.decimal = true,
  });

  final double width;
  final TextEditingController controller;
  final String label;
  final String suffix;
  final IconData icon;
  final FormFieldValidator<String> validator;
  final ValueChanged<String> onSubmitted;
  final bool decimal;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.numberWithOptions(decimal: decimal),
        textInputAction: TextInputAction.next,
        validator: validator,
        onFieldSubmitted: onSubmitted,
        decoration: InputDecoration(
          labelText: label,
          suffixText: suffix,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}

class _SearchEmptyState extends StatelessWidget {
  const _SearchEmptyState();

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: const Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(Icons.restaurant_menu, size: 52),
            SizedBox(height: 12),
            Text(
              'Os restaurantes aparecerão depois da busca',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 6),
            Text(
              'Exemplo: preencha somente 30 g em proteínas para encontrar o '
              'prato que mais se aproxima desse valor.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.result, required this.target});

  final DishSearchResult result;
  final _NutritionTarget target;

  @override
  Widget build(BuildContext context) {
    final establishment = result.establishment;
    final dish = result.dish;
    final exactColor = Colors.green.shade600;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: result.isExactMatch
            ? [
                BoxShadow(
                  color: exactColor.withValues(alpha: 0.36),
                  blurRadius: 20,
                  spreadRadius: 3,
                ),
              ]
            : const [],
      ),
      child: Card(
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: result.isExactMatch
                ? exactColor
                : Theme.of(context).colorScheme.outlineVariant,
            width: result.isExactMatch ? 2.5 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) =>
                  EstablishmentDetailPage(establishment: establishment),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                      child: Icon(Icons.restaurant),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            establishment.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            ),
                          ),
                          Text(
                            '${establishment.category} • '
                            '${_formatDistance(establishment.distanceKm)}',
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        dish.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    BadgeChip(badge: establishment.badge),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (target.calories != null)
                      _NutrientChip(
                        label: 'Calorias',
                        value: '${dish.calories} kcal',
                        exact: dish.calories == target.calories,
                      ),
                    if (target.proteinGrams != null)
                      _NutrientChip(
                        label: 'Proteínas',
                        value: '${_formatNumber(dish.proteinGrams)} g',
                        exact: _same(dish.proteinGrams, target.proteinGrams!),
                      ),
                    if (target.carbohydrateGrams != null)
                      _NutrientChip(
                        label: 'Carboidratos',
                        value: '${_formatNumber(dish.carbohydrateGrams)} g',
                        exact: _same(
                          dish.carbohydrateGrams,
                          target.carbohydrateGrams!,
                        ),
                      ),
                    if (target.fatGrams != null)
                      _NutrientChip(
                        label: 'Lipídios',
                        value: '${_formatNumber(dish.fatGrams)} g',
                        exact: _same(dish.fatGrams, target.fatGrams!),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      result.isExactMatch
                          ? Icons.check_circle
                          : Icons.near_me_outlined,
                      color: result.isExactMatch ? exactColor : null,
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        result.isExactMatch
                            ? 'Este prato bate exatamente a sua meta'
                            : '${(result.matchScore * 100).toStringAsFixed(0)}% '
                                'de diferença média',
                        style: TextStyle(
                          color: result.isExactMatch ? exactColor : null,
                          fontWeight: result.isExactMatch
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static bool _same(double first, double second) =>
      (first - second).abs() <= 0.01;

  static String _formatNumber(double value) =>
      value == value.roundToDouble()
          ? value.toStringAsFixed(0)
          : value.toStringAsFixed(1);

  static String _formatDistance(double distanceKm) => distanceKm < 1
      ? '${(distanceKm * 1000).round()} m'
      : '${distanceKm.toStringAsFixed(1)} km';
}

class _NutrientChip extends StatelessWidget {
  const _NutrientChip({
    required this.label,
    required this.value,
    required this.exact,
  });

  final String label;
  final String value;
  final bool exact;

  @override
  Widget build(BuildContext context) {
    final color = exact ? Colors.green.shade700 : null;
    return Chip(
      avatar: exact ? Icon(Icons.check, size: 17, color: color) : null,
      label: Text('$label: $value'),
      side: exact ? BorderSide(color: color!) : null,
    );
  }
}

class _NutritionTarget {
  const _NutritionTarget({
    this.calories,
    this.proteinGrams,
    this.carbohydrateGrams,
    this.fatGrams,
  });

  final int? calories;
  final double? proteinGrams;
  final double? carbohydrateGrams;
  final double? fatGrams;

  bool get hasAnyValue =>
      calories != null ||
      proteinGrams != null ||
      carbohydrateGrams != null ||
      fatGrams != null;
}
