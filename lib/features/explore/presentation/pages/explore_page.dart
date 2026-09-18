import 'package:flutter/material.dart';
import 'package:leafeat_mobile/core/theme/app_colors.dart';
import 'package:leafeat_mobile/features/establishments/data/mock_establishments.dart';
import 'package:leafeat_mobile/features/establishments/domain/models/establishment.dart';
import 'package:leafeat_mobile/features/explore/presentation/pages/establishment_detail_page.dart';
import 'package:leafeat_mobile/features/explore/presentation/widgets/badge_chip.dart';

enum _SortOption { distance, rating }

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});
  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final _searchController = TextEditingController();
  String _query = '';
  bool _vegan = false;
  bool _lactoseFree = false;
  bool _metricMenu = false;
  double _maxCalories = 800;
  _SortOption _sort = _SortOption.distance;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Establishment> get _filtered {
    final search = _query.trim().toLowerCase();
    final result = mockEstablishments.where((establishment) {
      final matchesSearch = establishment.name.toLowerCase().contains(search) || establishment.category.toLowerCase().contains(search) || establishment.dishes.any((dish) => dish.name.toLowerCase().contains(search));
      final matchesVegan = !_vegan || establishment.dishes.any((dish) => dish.isVegan);
      final matchesLactose = !_lactoseFree || establishment.dishes.any((dish) => dish.isLactoseFree);
      final matchesMetric = !_metricMenu || establishment.badgePercentage >= 10;
      final matchesCalories = establishment.dishes.any((dish) => dish.calories <= _maxCalories);
      return matchesSearch && matchesVegan && matchesLactose && matchesMetric && matchesCalories;
    }).toList();
    result.sort((a, b) => _sort == _SortOption.distance ? a.distanceKm.compareTo(b.distanceKm) : b.averageRating.compareTo(a.averageRating));
    return result;
  }

  int get _activeFilters => [_vegan, _lactoseFree, _metricMenu, _maxCalories < 800].where((value) => value).length;

  Future<void> _showFilters() async {
    var vegan = _vegan;
    var lactoseFree = _lactoseFree;
    var metricMenu = _metricMenu;
    var maxCalories = _maxCalories;
    var sort = _sort;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) => SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(24, 8, 24, 24 + MediaQuery.viewInsetsOf(context).bottom),
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Filtros e ordenação', style: Theme.of(context).textTheme.headlineSmall),
              CheckboxListTile(contentPadding: EdgeInsets.zero, title: const Text('Com opção vegana'), value: vegan, onChanged: (value) => setSheetState(() => vegan = value!)),
              CheckboxListTile(contentPadding: EdgeInsets.zero, title: const Text('Com opção sem lactose'), value: lactoseFree, onChanged: (value) => setSheetState(() => lactoseFree = value!)),
              CheckboxListTile(contentPadding: EdgeInsets.zero, title: const Text('Cardápio com métricas'), value: metricMenu, onChanged: (value) => setSheetState(() => metricMenu = value!)),
              Text('Até ${maxCalories.round()} kcal por prato'),
              Slider(value: maxCalories, min: 300, max: 800, divisions: 10, label: maxCalories.round().toString(), onChanged: (value) => setSheetState(() => maxCalories = value)),
              DropdownButtonFormField<_SortOption>(
                initialValue: sort,
                decoration: const InputDecoration(labelText: 'Ordenar por', border: OutlineInputBorder()),
                items: const [DropdownMenuItem(value: _SortOption.distance, child: Text('Mais próximos')), DropdownMenuItem(value: _SortOption.rating, child: Text('Melhor avaliados'))],
                onChanged: (value) => setSheetState(() => sort = value!),
              ),
              const SizedBox(height: 18),
              Row(children: [
                Expanded(child: OutlinedButton(onPressed: () => setSheetState(() { vegan = false; lactoseFree = false; metricMenu = false; maxCalories = 800; sort = _SortOption.distance; }), child: const Text('Limpar'))),
                const SizedBox(width: 12),
                Expanded(child: FilledButton(onPressed: () { setState(() { _vegan = vegan; _lactoseFree = lactoseFree; _metricMenu = metricMenu; _maxCalories = maxCalories; _sort = sort; }); Navigator.of(sheetContext).pop(); }, child: const Text('Aplicar'))),
              ]),
            ]),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final establishments = _filtered;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explorar locais'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        actions: [Badge(label: Text('$_activeFilters'), isLabelVisible: _activeFilters > 0, child: IconButton(tooltip: 'Filtros', onPressed: _showFilters, icon: const Icon(Icons.tune)))],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text('O que você procura?', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Consulte restaurantes e pratos mesmo sem criar uma conta.'),
            const SizedBox(height: 20),
            SearchBar(controller: _searchController, hintText: 'Buscar restaurante, categoria ou prato', leading: const Icon(Icons.search), trailing: [if (_query.isNotEmpty) IconButton(tooltip: 'Limpar busca', onPressed: () { _searchController.clear(); setState(() => _query = ''); }, icon: const Icon(Icons.close))], onChanged: (value) => setState(() => _query = value)),
            const SizedBox(height: 16),
            if (_activeFilters > 0) Wrap(spacing: 8, children: [if (_vegan) const Chip(label: Text('Vegano')), if (_lactoseFree) const Chip(label: Text('Sem lactose')), if (_metricMenu) const Chip(label: Text('Com métricas')), if (_maxCalories < 800) Chip(label: Text('Até ${_maxCalories.round()} kcal'))]),
            const SizedBox(height: 8),
            Text('${establishments.length} estabelecimentos encontrados', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            if (establishments.isEmpty)
              const Padding(padding: EdgeInsets.symmetric(vertical: 48), child: Column(children: [Icon(Icons.search_off, size: 56), SizedBox(height: 12), Text('Nenhum estabelecimento encontrado.')] ))
            else
              ...establishments.map((establishment) => _EstablishmentCard(establishment: establishment)),
          ],
        ),
      ),
    );
  }
}

class _EstablishmentCard extends StatelessWidget {
  const _EstablishmentCard({required this.establishment});
  final Establishment establishment;
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => EstablishmentDetailPage(establishment: establishment))),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [const CircleAvatar(backgroundColor: AppColors.primary, foregroundColor: AppColors.onPrimary, child: Icon(Icons.restaurant)), const SizedBox(width: 12), Expanded(child: Text(establishment.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17))), const Icon(Icons.chevron_right)]),
            const SizedBox(height: 10),
            Text('${establishment.category} • ${_formatDistance(establishment.distanceKm)}'),
            const SizedBox(height: 10),
            Row(children: [const Icon(Icons.star, color: Colors.amber, size: 20), const SizedBox(width: 4), Text(establishment.averageRating.toStringAsFixed(1)), const Spacer(), BadgeChip(badge: establishment.badge)]),
          ]),
        ),
      ),
    );
  }
  String _formatDistance(double distanceKm) => distanceKm < 1 ? '${(distanceKm * 1000).round()} m' : '${distanceKm.toStringAsFixed(1)} km';
}
