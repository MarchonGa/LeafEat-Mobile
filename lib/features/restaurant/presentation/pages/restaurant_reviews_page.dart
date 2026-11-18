import 'package:flutter/material.dart';
import 'package:leafeat_mobile/app/session/app_session.dart';
import 'package:leafeat_mobile/core/theme/app_colors.dart';
import 'package:leafeat_mobile/features/restaurant/data/restaurant_repository.dart';
import 'package:leafeat_mobile/features/profile/presentation/pages/public_customer_profile_page.dart';
import 'package:leafeat_mobile/features/restaurant/data/restaurant_review.dart';

class RestaurantReviewsPage extends StatefulWidget {
  const RestaurantReviewsPage({super.key});

  @override
  State<RestaurantReviewsPage> createState() =>
      _RestaurantReviewsPageState();
}

class _RestaurantReviewsPageState
    extends State<RestaurantReviewsPage> {
  List<RestaurantReview> _reviews = const [];
  bool _initialized = false;
  bool _loading = true;
  String? _error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    _load();
  }

  Future<void> _load() async {
    final session = AppSessionScope.read(context);
    if (session.token == null) {
      setState(() {
        _loading = false;
        _error = 'Entre como restaurante para consultar as avaliações.';
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final reviews = await RestaurantRepository(
        session.apiClient,
        session.token!,
      ).reviews();
      if (!mounted) return;
      setState(() {
        _reviews = reviews;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Avaliações recebidas'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        actions: [
          IconButton(
            tooltip: 'Atualizar avaliações',
            onPressed: _loading ? null : _load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _loading && _reviews.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [
                  if (_error != null)
                    Card(
                      color: Theme.of(context).colorScheme.errorContainer,
                      child: ListTile(
                        leading: const Icon(Icons.error_outline),
                        title: Text(_error!),
                        trailing: IconButton(
                          tooltip: 'Tentar novamente',
                          onPressed: _load,
                          icon: const Icon(Icons.refresh),
                        ),
                      ),
                    ),
                  if (_reviews.isEmpty && _error == null)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 64),
                      child: Column(
                        children: [
                          Icon(Icons.rate_review_outlined, size: 56),
                          SizedBox(height: 12),
                          Text(
                            'Nenhuma avaliação recebida até o momento.',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  else
                    ..._reviews.map(
                      (review) => _ReviewCard(review: review),
                    ),
                ],
              ),
            ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review});

  final RestaurantReview review;

  @override
  Widget build(BuildContext context) {
    final initial = review.customerName.trim().isEmpty
        ? '?'
        : review.customerName.trim()[0].toUpperCase();
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(child: Text(initial)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.customerName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(_formatDate(review.createdAt)),
                    ],
                  ),
                ),
                _Rating(value: review.averageRating),
                IconButton(
                  tooltip: 'Abrir perfil público',
                  onPressed: () => Navigator.of(context).push<void>(
                    MaterialPageRoute(
                      builder: (_) => PublicCustomerProfilePage(
                        userId: review.customerId,
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.person_search_outlined),
                ),
              ],
            ),
            if (review.dishName != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.lunch_dining_outlined, size: 18),
                  const SizedBox(width: 6),
                  Expanded(child: Text(review.dishName!)),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(
                  avatar: const Icon(Icons.restaurant, size: 18),
                  label: Text('Prato: ${review.dishRating}'),
                ),
                Chip(
                  avatar: const Icon(Icons.storefront, size: 18),
                  label: Text(
                    'Ambiente: ${review.environmentRating}',
                  ),
                ),
                Chip(
                  avatar: const Icon(Icons.thumb_up_outlined, size: 18),
                  label: Text('Útil: ${review.helpfulCount}'),
                ),
                Chip(
                  avatar: const Icon(Icons.thumb_down_outlined, size: 18),
                  label: Text(
                    'Não útil: ${review.notHelpfulCount}',
                  ),
                ),
              ],
            ),
            if (review.comment.trim().isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(review.comment),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final local = date.toLocal();
    return '${local.day.toString().padLeft(2, '0')}/'
        '${local.month.toString().padLeft(2, '0')}/'
        '${local.year}';
  }
}

class _Rating extends StatelessWidget {
  const _Rating({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.star, color: Colors.amber, size: 20),
        const SizedBox(width: 4),
        Text(value.toStringAsFixed(1).replaceAll('.', ',')),
      ],
    );
  }
}
