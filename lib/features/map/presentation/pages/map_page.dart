import 'package:flutter/material.dart';
import 'package:leafeat_mobile/core/theme/app_colors.dart';

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        actions: [
          IconButton(
            tooltip: 'Filtros',
            onPressed: () => _showFilters(context),
            icon: const Icon(Icons.tune),
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            color: const Color(0xFFE1ECDD),
            child: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.map_outlined, size: 96, color: AppColors.primary),
                  SizedBox(height: 12),
                  Text(
                    'O mapa interativo será exibido aqui',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: SearchBar(
              hintText: 'Buscar restaurantes ou alimentos',
              leading: const Icon(Icons.search),
              trailing: [
                IconButton(
                  tooltip: 'Filtros',
                  onPressed: () => _showFilters(context),
                  icon: const Icon(Icons.tune),
                ),
              ],
            ),
          ),
          Positioned(
            right: 16,
            bottom: 20,
            child: FloatingActionButton(
              heroTag: 'my-location',
              tooltip: 'Minha localização',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('A localização será integrada em breve.'),
                  ),
                );
              },
              child: const Icon(Icons.my_location),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilters(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => const Padding(
        padding: EdgeInsets.fromLTRB(24, 8, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filtros de busca',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilterChip(
                  label: Text('Mais próximos'),
                  selected: true,
                  onSelected: null,
                ),
                FilterChip(
                  label: Text('Refeições saudáveis'),
                  selected: false,
                  onSelected: null,
                ),
                FilterChip(
                  label: Text('Melhor avaliados'),
                  selected: false,
                  onSelected: null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
