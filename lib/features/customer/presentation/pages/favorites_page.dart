import 'package:flutter/material.dart';
import 'package:leafeat_mobile/core/theme/app_colors.dart';
import 'package:leafeat_mobile/features/establishments/data/mock_establishments.dart';
import 'package:leafeat_mobile/features/explore/presentation/pages/establishment_detail_page.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});
  @override
  Widget build(BuildContext context) {
    final favorites = mockEstablishments.take(2).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Locais favoritos'), backgroundColor: AppColors.primary, foregroundColor: AppColors.onPrimary),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: favorites.length,
        itemBuilder: (context, index) {
          final establishment = favorites[index];
          return Card(
            child: ListTile(
              leading: const Icon(Icons.favorite, color: Colors.red),
              title: Text(establishment.name),
              subtitle: Text(establishment.category),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => EstablishmentDetailPage(establishment: establishment))),
            ),
          );
        },
      ),
    );
  }
}
