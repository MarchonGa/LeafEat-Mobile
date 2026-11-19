import 'package:flutter/material.dart';
import 'package:leafeat_mobile/app/session/app_session.dart';
import 'package:leafeat_mobile/core/theme/app_colors.dart';
import 'package:leafeat_mobile/features/customer/data/customer_repository.dart';
import 'package:leafeat_mobile/features/establishments/data/establishments_repository.dart';
import 'package:leafeat_mobile/features/establishments/domain/models/dish.dart';
import 'package:leafeat_mobile/features/establishments/domain/models/establishment.dart';
import 'package:leafeat_mobile/features/explore/presentation/pages/dish_detail_page.dart';
import 'package:leafeat_mobile/features/explore/presentation/widgets/badge_chip.dart';

class EstablishmentDetailPage extends StatefulWidget {
  const EstablishmentDetailPage({
    required this.establishment,
    super.key,
  });

  final Establishment establishment;

  @override
  State<EstablishmentDetailPage> createState() =>
      _EstablishmentDetailPageState();
}

class _EstablishmentDetailPageState
    extends State<EstablishmentDetailPage> {
  bool? _favorite;
  bool _changingFavorite = false;
  bool _detailsRequested = false;
  bool _loadingDetails = false;
  String? _detailsError;
  late Establishment _establishment;

  Establishment get establishment => _establishment;

  @override
  void initState() {
    super.initState();
    _establishment = widget.establishment;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_favorite == null) _loadFavorite();
    if (!_detailsRequested) {
      _detailsRequested = true;
      _loadDetails();
    }
  }

  Future<void> _loadDetails() async {
    final session = AppSessionScope.maybeRead(context);
    if (session == null) return;

    setState(() {
      _loadingDetails = true;
      _detailsError = null;
    });
    try {
      final completeEstablishment = await EstablishmentsRepository(
        session.apiClient,
      ).detail(widget.establishment.id);
      if (!mounted) return;
      setState(() {
        _establishment = completeEstablishment;
        _loadingDetails = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadingDetails = false;
        _detailsError =
            'Não foi possível atualizar o cardápio deste estabelecimento.';
      });
    }
  }

  Future<void> _loadFavorite() async {
    final session = AppSessionScope.maybeRead(context);
    if (session == null ||
        session.mode != UserMode.customer ||
        session.token == null) {
      if (mounted) {
        setState(() {
          _favorite = false;
        });
      }
      return;
    }

    try {
      final items = await CustomerRepository(
        session.apiClient,
        session.token!,
      ).favorites();
      if (!mounted) return;
      setState(() {
        _favorite = items.any(
          (item) => item.id == establishment.id,
        );
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _favorite = false;
        });
      }
    }
  }

  Future<void> _toggleFavorite() async {
    final session = AppSessionScope.read(context);
    if (session.mode != UserMode.customer ||
        session.token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Entre como cliente para salvar favoritos.',
          ),
        ),
      );
      return;
    }

    setState(() {
      _changingFavorite = true;
    });
    try {
      final repository = CustomerRepository(
        session.apiClient,
        session.token!,
      );
      if (_favorite == true) {
        await repository.removeFavorite(establishment.id);
      } else {
        await repository.addFavorite(establishment.id);
      }
      if (mounted) {
        setState(() {
          _favorite = !(_favorite ?? false);
        });
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString())),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _changingFavorite = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final environmentRating = establishment.averageRating
        .toStringAsFixed(1)
        .replaceAll('.', ',');

    return Scaffold(
      appBar: AppBar(
        title: Text(establishment.name),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        actions: [
          IconButton(
            tooltip: _favorite == true
                ? 'Remover dos favoritos'
                : 'Adicionar aos favoritos',
            onPressed:
                _changingFavorite ? null : _toggleFavorite,
            icon: Icon(
              _favorite == true
                  ? Icons.favorite
                  : Icons.favorite_border,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (_loadingDetails) ...[
            const LinearProgressIndicator(),
            const SizedBox(height: 16),
          ],
          if (_detailsError != null) ...[
            Card(
              color:
                  Theme.of(context).colorScheme.errorContainer,
              child: ListTile(
                leading: const Icon(Icons.cloud_off_outlined),
                title: Text(_detailsError!),
                trailing: IconButton(
                  tooltip: 'Tentar novamente',
                  onPressed: _loadDetails,
                  icon: const Icon(Icons.refresh),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
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
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      establishment.category,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.storefront_outlined,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Nota do ambiente: $environmentRating',
                        ),
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
              const Icon(
                Icons.location_on_outlined,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(establishment.address)),
            ],
          ),
          const SizedBox(height: 26),
          Text(
            'Pratos',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          const Text(
            'As notas e avaliações são apresentadas separadamente em cada prato.',
          ),
          const SizedBox(height: 12),
          if (!_loadingDetails &&
              establishment.dishes.isEmpty)
            const Card(
              child: ListTile(
                leading:
                    Icon(Icons.restaurant_menu_outlined),
                title: Text(
                  'Este estabelecimento ainda não cadastrou pratos.',
                ),
              ),
            )
          else
            ...establishment.dishes.map(
              (dish) => _DishCard(
                dish: dish,
                establishmentId: establishment.id,
              ),
            ),
        ],
      ),
    );
  }
}

class _DishCard extends StatelessWidget {
  const _DishCard({
    required this.dish,
    required this.establishmentId,
  });

  final Dish dish;
  final String establishmentId;

  @override
  Widget build(BuildContext context) {
    final rating = dish.averageRating
        .toStringAsFixed(1)
        .replaceAll('.', ',');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading:
            const CircleAvatar(child: Icon(Icons.lunch_dining)),
        title: Text(
          dish.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${dish.calories} kcal • R\$ ${dish.price.toStringAsFixed(2).replaceAll('.', ',')}',
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  const Icon(
                    Icons.star,
                    color: Colors.amber,
                    size: 18,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    dish.totalReviews == 0
                        ? 'Ainda sem avaliações'
                        : '$rating (${dish.totalReviews})',
                  ),
                ],
              ),
            ],
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.of(context).push<void>(
          MaterialPageRoute(
            builder: (_) => DishDetailPage(
              dish: dish,
              establishmentId: establishmentId,
            ),
          ),
        ),
      ),
    );
  }
}
