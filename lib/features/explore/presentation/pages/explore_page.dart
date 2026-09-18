import 'package:flutter/material.dart';
import 'package:leafeat_mobile/core/theme/app_colors.dart';
import 'package:leafeat_mobile/features/establishments/data/mock_establishments.dart';
import 'package:leafeat_mobile/features/establishments/domain/models/establishment.dart';
import 'package:leafeat_mobile/features/explore/presentation/pages/establishment_detail_page.dart';
import 'package:leafeat_mobile/features/explore/presentation/widgets/badge_chip.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final search = _query.trim().toLowerCase();
    final establishments = mockEstablishments.where((establishment) {
      return establishment.name.toLowerCase().contains(search) ||
          establishment.category.toLowerCase().contains(search) ||
          establishment.dishes.any((dish) => dish.name.toLowerCase().contains(search));
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Explorar locais'), backgroundColor: AppColors.primary, foregroundColor: AppColors.onPrimary),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text('O que você procura?', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Consulte restaurantes e pratos mesmo sem criar uma conta.'),
            const SizedBox(height: 20),
            SearchBar(
              controller: _searchController,
              hintText: 'Buscar restaurante, categoria ou prato',
              leading: const Icon(Icons.search),
              trailing: [
                if (_query.isNotEmpty)
                  IconButton(
                    tooltip: 'Limpar busca',
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _query = '');
                    },
                    icon: const Icon(Icons.close),
                  ),
              ],
              onChanged: (value) => setState(() => _query = value),
            ),
            const SizedBox(height: 24),
            Text('${establishments.length} estabelecimentos encontrados', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            if (establishments.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 48),
                child: Column(children: [Icon(Icons.search_off, size: 56), SizedBox(height: 12), Text('Nenhum estabelecimento encontrado.')]),
              )
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const CircleAvatar(backgroundColor: AppColors.primary, foregroundColor: AppColors.onPrimary, child: Icon(Icons.restaurant)),
                  const SizedBox(width: 12),
                  Expanded(child: Text(establishment.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17))),
                  const Icon(Icons.chevron_right),
                ],
              ),
              const SizedBox(height: 10),
              Text('${establishment.category} • ${_formatDistance(establishment.distanceKm)}'),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 20),
                  const SizedBox(width: 4),
                  Text(establishment.averageRating.toStringAsFixed(1)),
                  const Spacer(),
                  BadgeChip(badge: establishment.badge),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDistance(double distanceKm) => distanceKm < 1 ? '${(distanceKm * 1000).round()} m' : '${distanceKm.toStringAsFixed(1)} km';
}
