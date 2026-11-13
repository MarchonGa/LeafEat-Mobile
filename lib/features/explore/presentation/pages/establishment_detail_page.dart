import 'package:flutter/material.dart';
import 'package:leafeat_mobile/app/session/app_session.dart';
import 'package:leafeat_mobile/core/theme/app_colors.dart';
import 'package:leafeat_mobile/features/customer/data/customer_repository.dart';
import 'package:leafeat_mobile/features/establishments/domain/models/dish.dart';
import 'package:leafeat_mobile/features/establishments/domain/models/establishment.dart';
import 'package:leafeat_mobile/features/explore/presentation/pages/dish_detail_page.dart';
import 'package:leafeat_mobile/features/explore/presentation/widgets/badge_chip.dart';

class EstablishmentDetailPage extends StatefulWidget {
  const EstablishmentDetailPage({required this.establishment, super.key});

  final Establishment establishment;

  @override
  State<EstablishmentDetailPage> createState() => _EstablishmentDetailPageState();
}

class _EstablishmentDetailPageState extends State<EstablishmentDetailPage> {
  bool? _favorite;
  bool _changingFavorite = false;

  Establishment get establishment => widget.establishment;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_favorite == null) _loadFavorite();
  }

  Future<void> _loadFavorite() async {
    final session = AppSessionScope.read(context);
    if (session.mode != UserMode.customer || session.token == null) {
      if (mounted) setState(() => _favorite = false);
      return;
    }
    try {
      final items = await CustomerRepository(session.apiClient, session.token!).favorites();
      if (mounted) setState(() => _favorite = items.any((item) => item.id == establishment.id));
    } catch (_) {
      if (mounted) setState(() => _favorite = false);
    }
  }

  Future<void> _toggleFavorite() async {
    final session = AppSessionScope.read(context);
    if (session.mode != UserMode.customer || session.token == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Entre como cliente para salvar favoritos.')));
      return;
    }
    setState(() => _changingFavorite = true);
    try {
      final repository = CustomerRepository(session.apiClient, session.token!);
      if (_favorite == true) {
        await repository.removeFavorite(establishment.id);
      } else {
        await repository.addFavorite(establishment.id);
      }
      if (mounted) setState(() => _favorite = !(_favorite ?? false));
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) setState(() => _changingFavorite = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(establishment.name),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        actions: [
          IconButton(
            tooltip: _favorite == true ? 'Remover dos favoritos' : 'Adicionar aos favoritos',
            onPressed: _changingFavorite ? null : _toggleFavorite,
            icon: Icon(_favorite == true ? Icons.favorite : Icons.favorite_border),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(
                radius: 32,
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                child: Icon(Icons.restaurant, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(establishment.category, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 20),
                        const SizedBox(width: 4),
                        Text('${establishment.averageRating.toStringAsFixed(1)} (${establishment.reviews.length})'),
                      ],
                    ),
                    if (establishment.badge.isVisible) ...[
                      const SizedBox(height: 8),
                      BadgeChip(badge: establishment.badge),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(establishment.description),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on_outlined, size: 20),
              const SizedBox(width: 8),
              Expanded(child: Text(establishment.address)),
            ],
          ),
          const SizedBox(height: 26),
          Text('Pratos', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          ...establishment.dishes.map((dish) => _DishCard(dish: dish)),
        ],
      ),
    );
  }
}

class _DishCard extends StatelessWidget {
  const _DishCard({required this.dish});

  final Dish dish;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: const CircleAvatar(child: Icon(Icons.lunch_dining)),
        title: Text(dish.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text('${dish.calories} kcal • R\$ ${dish.price.toStringAsFixed(2).replaceAll('.', ',')}'),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => DishDetailPage(dish: dish))),
      ),
    );
  }
}
