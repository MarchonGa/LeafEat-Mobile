import 'package:flutter/material.dart';
import 'package:leafeat_mobile/app/session/app_session.dart';
import 'package:leafeat_mobile/core/theme/app_colors.dart';
import 'package:leafeat_mobile/features/customer/data/customer_repository.dart';
import 'package:leafeat_mobile/features/establishments/domain/models/establishment.dart';
import 'package:leafeat_mobile/features/explore/presentation/pages/establishment_detail_page.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  Future<List<Establishment>>? _favorites;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _favorites ??= _load();
  }

  Future<List<Establishment>> _load() {
    final session = AppSessionScope.read(context);
    final token = session.token;
    if (token == null) return Future.error('Faça login como cliente para acessar seus favoritos.');
    return CustomerRepository(session.apiClient, token).favorites();
  }

  Future<void> _remove(Establishment establishment) async {
    final session = AppSessionScope.read(context);
    await CustomerRepository(session.apiClient, session.token!).removeFavorite(establishment.id);
    if (!mounted) return;
    setState(() => _favorites = _load());
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${establishment.name} removido dos favoritos.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Locais favoritos'), backgroundColor: AppColors.primary, foregroundColor: AppColors.onPrimary),
      body: FutureBuilder<List<Establishment>>(
        future: _favorites,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return _Message(icon: Icons.cloud_off_outlined, text: snapshot.error.toString());
          final favorites = snapshot.data ?? const [];
          if (favorites.isEmpty) return const _Message(icon: Icons.favorite_border, text: 'Você ainda não salvou nenhum estabelecimento.');
          return RefreshIndicator(
            onRefresh: () async => setState(() => _favorites = _load()),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final establishment = favorites[index];
                return Card(child: ListTile(
                  leading: const Icon(Icons.favorite, color: Colors.red),
                  title: Text(establishment.name),
                  subtitle: Text(establishment.category),
                  trailing: IconButton(tooltip: 'Remover dos favoritos', onPressed: () => _remove(establishment), icon: const Icon(Icons.delete_outline)),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => EstablishmentDetailPage(establishment: establishment))),
                ));
              },
            ),
          );
        },
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.icon, required this.text});
  final IconData icon;
  final String text;
  @override
  Widget build(BuildContext context) => Center(child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 56, color: AppColors.primary),
          const SizedBox(height: 16),
          Text(text, textAlign: TextAlign.center),
        ]),
      ));
}
