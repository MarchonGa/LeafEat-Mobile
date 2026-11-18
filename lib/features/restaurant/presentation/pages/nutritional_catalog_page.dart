import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:leafeat_mobile/app/session/app_session.dart';
import 'package:leafeat_mobile/core/theme/app_colors.dart';
import 'package:leafeat_mobile/features/restaurant/data/nutritional_catalog_repository.dart';
import 'package:leafeat_mobile/features/restaurant/data/nutritional_food.dart';
import 'package:leafeat_mobile/features/restaurant/data/restaurant_recipe.dart';

class NutritionalCatalogPage extends StatefulWidget {
  const NutritionalCatalogPage({
    this.selectionMode = false,
    super.key,
  });

  final bool selectionMode;

  @override
  State<NutritionalCatalogPage> createState() => _NutritionalCatalogPageState();
}

class _NutritionalCatalogPageState extends State<NutritionalCatalogPage> {
  final _searchController = TextEditingController();
  final List<NutritionalFood> _foods = [];
  bool _loading = true;
  bool _loadingMore = false;
  String? _error;
  int _page = 0;
  int _totalPages = 0;
  int _total = 0;
  String _source = '';
  String _sourceVersion = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_page == 0 && _loading) _load(reset: true);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load({required bool reset}) async {
    if (reset) {
      setState(() {
        _loading = true;
        _error = null;
      });
    } else {
      if (_loadingMore || _page >= _totalPages) return;
      setState(() => _loadingMore = true);
    }

    try {
      final session = AppSessionScope.read(context);
      final result = await NutritionalCatalogRepository(
        session.apiClient,
      ).search(
        search: _searchController.text,
        page: reset ? 1 : _page + 1,
      );
      if (!mounted) return;
      setState(() {
        if (reset) _foods.clear();
        _foods.addAll(result.items);
        _page = result.page;
        _totalPages = result.totalPages;
        _total = result.total;
        _source = result.source;
        _sourceVersion = result.sourceVersion;
        _loading = false;
        _loadingMore = false;
        _error = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadingMore = false;
        _error = error.toString();
      });
    }
  }

  void _clearSearch() {
    if (_searchController.text.isEmpty) return;
    _searchController.clear();
    _load(reset: true);
  }

  Future<void> _showCalculation(NutritionalFood food) async {
    final controller = TextEditingController(text: '100');
    var grams = 100.0;
    final selection = await showModalBottomSheet<NutritionalFoodSelection>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) {
          final calculated = food.per100Grams.scaledTo(grams);
          return SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                20,
                0,
                20,
                20 + MediaQuery.viewInsetsOf(context).bottom,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        food.description,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Fonte: ${food.source} ${food.sourceVersion}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 18),
                      TextField(
                        controller: controller,
                        autofocus: true,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[0-9,.]'),
                          ),
                        ],
                        decoration: const InputDecoration(
                          labelText: 'Quantidade usada',
                          suffixText: 'g',
                          border: OutlineInputBorder(),
                          helperText:
                              'Os valores são proporcionais à quantidade.',
                        ),
                        onChanged: (value) {
                          final parsed = double.tryParse(
                            value.replaceAll(',', '.'),
                          );
                          setSheetState(() => grams = parsed ?? 0);
                        },
                      ),
                      const SizedBox(height: 18),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _NutrientCard(
                            label: 'Calorias',
                            value: _format(calculated.energyKcal),
                            unit: 'kcal',
                          ),
                          _NutrientCard(
                            label: 'Proteínas',
                            value: _format(calculated.proteinGrams),
                            unit: 'g',
                          ),
                          _NutrientCard(
                            label: 'Carboidratos',
                            value: _format(calculated.carbohydrateGrams),
                            unit: 'g',
                          ),
                          _NutrientCard(
                            label: 'Lipídios',
                            value: _format(calculated.fatGrams),
                            unit: 'g',
                          ),
                          _NutrientCard(
                            label: 'Fibras',
                            value: _format(calculated.fiberGrams),
                            unit: 'g',
                          ),
                          _NutrientCard(
                            label: 'Sódio',
                            value: _format(calculated.sodiumMilligrams),
                            unit: 'mg',
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Referência original: valores por 100 g. '
                        '“Traço” indica quantidade presente abaixo do limite '
                        'de quantificação da tabela, não ausência comprovada.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      if (widget.selectionMode) ...[
                        const SizedBox(height: 18),
                        FilledButton.icon(
                          onPressed: grams > 0
                              ? () => Navigator.of(sheetContext).pop(
                                    NutritionalFoodSelection(
                                      food: food,
                                      quantityGrams: grams,
                                    ),
                                  )
                              : null,
                          icon: const Icon(Icons.add),
                          label: const Text('Adicionar à receita'),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
    controller.dispose();
    if (selection != null && widget.selectionMode && mounted) {
      Navigator.of(context).pop(selection);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.selectionMode ? 'Escolher ingrediente' : 'Catálogo nutricional'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
      ),
      body: RefreshIndicator(
        onRefresh: () => _load(reset: true),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              widget.selectionMode
                  ? 'Pesquise um alimento, informe a quantidade usada e '
                      'adicione-o à receita.'
                  : 'Consulte alimentos da TACO e calcule os nutrientes para '
                      'a quantidade realmente usada na receita.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _load(reset: true),
              decoration: InputDecoration(
                labelText: 'Buscar alimento',
                hintText: 'Ex.: arroz integral cozido',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Limpar busca',
                        onPressed: _clearSearch,
                        icon: const Icon(Icons.clear),
                      ),
                border: const OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 10),
            FilledButton.icon(
              onPressed: _loading ? null : () => _load(reset: true),
              icon: const Icon(Icons.search),
              label: const Text('Pesquisar'),
            ),
            if (_source.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                '$_total alimentos encontrados • Fonte: '
                '$_source $_sourceVersion',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            if (_loading) ...[
              const SizedBox(height: 64),
              const Center(child: CircularProgressIndicator()),
            ] else if (_error != null) ...[
              const SizedBox(height: 16),
              Card(
                color: Theme.of(context).colorScheme.errorContainer,
                child: ListTile(
                  leading: const Icon(Icons.error_outline),
                  title: Text(_error!),
                  subtitle: const Text(
                    'Confirme se o backend está rodando na porta 5000.',
                  ),
                  trailing: IconButton(
                    tooltip: 'Tentar novamente',
                    onPressed: () => _load(reset: true),
                    icon: const Icon(Icons.refresh),
                  ),
                ),
              ),
            ] else if (_foods.isEmpty) ...[
              const SizedBox(height: 64),
              const Center(child: Text('Nenhum alimento encontrado.')),
            ] else ...[
              const SizedBox(height: 10),
              for (final food in _foods)
                Card(
                  child: ListTile(
                    onTap: () => _showCalculation(food),
                    leading: const CircleAvatar(
                      child: Icon(Icons.science_outlined),
                    ),
                    title: Text(food.description),
                    subtitle: Text(
                      [
                        food.category,
                        if (food.preparation != null) food.preparation!,
                        '100 g: ${_format(food.per100Grams.energyKcal)} kcal',
                      ].join(' • '),
                    ),
                    trailing: const Icon(Icons.calculate_outlined),
                  ),
                ),
              if (_page < _totalPages)
                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 64),
                  child: OutlinedButton.icon(
                    onPressed:
                        _loadingMore ? null : () => _load(reset: false),
                    icon: _loadingMore
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.expand_more),
                    label: Text(
                      _loadingMore ? 'Carregando...' : 'Carregar mais',
                    ),
                  ),
                )
              else
                const SizedBox(height: 64),
            ],
          ],
        ),
      ),
    );
  }
}

class _NutrientCard extends StatelessWidget {
  const _NutrientCard({
    required this.label,
    required this.value,
    required this.unit,
  });

  final String label;
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 145,
      child: Card(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.labelMedium),
              const SizedBox(height: 4),
              Text(
                value == 'Não informado' || value == 'Traço'
                    ? value
                    : '$value $unit',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _format(double? value) {
  if (value == null) return 'Não informado';
  if (value.abs() <= 0.00001) return 'Traço';
  final text = value.toStringAsFixed(2);
  return text
      .replaceFirst(RegExp(r'\.00$'), '')
      .replaceFirst(RegExp(r'(\.[0-9])0$'), r'$1')
      .replaceAll('.', ',');
}
