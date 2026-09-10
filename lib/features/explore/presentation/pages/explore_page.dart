import 'package:flutter/material.dart';
import 'package:leafeat_mobile/core/theme/app_colors.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final _searchController = TextEditingController();
  String _query = '';

  static const _places = [
    (
      name: 'Sabor Natural',
      category: 'Refeições saudáveis',
      distance: '450 m',
      rating: '4,8',
      icon: Icons.restaurant,
    ),
    (
      name: 'Horta da Praça',
      category: 'Produtos frescos',
      distance: '1,2 km',
      rating: '4,6',
      icon: Icons.local_grocery_store,
    ),
    (
      name: 'Vida Leve',
      category: 'Lanches e sucos',
      distance: '2,0 km',
      rating: '4,5',
      icon: Icons.local_cafe,
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredPlaces = _places.where((place) {
      final search = _query.toLowerCase();
      return place.name.toLowerCase().contains(search) ||
          place.category.toLowerCase().contains(search);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Explorar locais'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'O que você procura?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Descubra opções de alimentação próximas de você.',
            ),
            const SizedBox(height: 20),
            SearchBar(
              controller: _searchController,
              hintText: 'Buscar local ou categoria',
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
            const SizedBox(height: 16),
            const Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(
                  avatar: Icon(Icons.near_me, size: 18),
                  label: Text('Mais próximos'),
                ),
                Chip(
                  avatar: Icon(Icons.eco, size: 18),
                  label: Text('Saudáveis'),
                ),
                Chip(
                  avatar: Icon(Icons.star, size: 18),
                  label: Text('Bem avaliados'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              '${filteredPlaces.length} locais encontrados',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            if (filteredPlaces.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 48),
                child: Column(
                  children: [
                    Icon(Icons.search_off, size: 56),
                    SizedBox(height: 12),
                    Text('Nenhum local encontrado.'),
                  ],
                ),
              )
            else
              ...filteredPlaces.map(
                (place) => Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                      child: Icon(place.icon),
                    ),
                    title: Text(
                      place.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        '${place.category} • ${place.distance}',
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 20),
                        const SizedBox(width: 4),
                        Text(place.rating),
                      ],
                    ),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Os detalhes de ${place.name} serão adicionados em breve.',
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
