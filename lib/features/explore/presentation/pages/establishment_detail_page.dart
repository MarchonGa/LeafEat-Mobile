import 'package:flutter/material.dart';
import 'package:leafeat_mobile/app/session/app_session.dart';
import 'package:leafeat_mobile/core/theme/app_colors.dart';
import 'package:leafeat_mobile/features/customer/data/customer_repository.dart';
import 'package:leafeat_mobile/features/establishments/domain/models/dish.dart';
import 'package:leafeat_mobile/features/establishments/data/establishments_repository.dart';
import 'package:leafeat_mobile/features/establishments/domain/models/establishment.dart';
import 'package:leafeat_mobile/features/explore/presentation/pages/dish_detail_page.dart';
import 'package:leafeat_mobile/features/explore/presentation/widgets/badge_chip.dart';
import 'package:leafeat_mobile/features/profile/presentation/pages/public_customer_profile_page.dart';
import 'package:leafeat_mobile/features/review/data/public_review.dart';
import 'package:leafeat_mobile/features/review/data/review_repository.dart';

class EstablishmentDetailPage extends StatefulWidget {
  const EstablishmentDetailPage({required this.establishment, super.key});

  final Establishment establishment;

  @override
  State<EstablishmentDetailPage> createState() => _EstablishmentDetailPageState();
}

class _EstablishmentDetailPageState extends State<EstablishmentDetailPage> {
  bool? _favorite;
  bool _changingFavorite = false;
  bool _detailsRequested = false;
  bool _loadingDetails = false;
  bool _reviewsRequested = false;
  bool _loadingReviews = false;
  String? _detailsError;
  String? _reviewsError;
  String? _votingReviewId;
  List<PublicReview> _reviews = const [];
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
    if (!_reviewsRequested) {
      _reviewsRequested = true;
      _loadReviews();
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


  Future<void> _loadReviews() async {
    final session = AppSessionScope.maybeRead(context);
    if (session == null) return;
    setState(() {
      _loadingReviews = true;
      _reviewsError = null;
    });
    try {
      final reviews = await ReviewRepository(
        session.apiClient,
      ).publicReviews(
        widget.establishment.id,
        token: session.token,
      );
      if (!mounted) return;
      setState(() {
        _reviews = reviews;
        _loadingReviews = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadingReviews = false;
        _reviewsError =
            'Não foi possível carregar as avaliações.';
      });
    }
  }

  Future<void> _vote(PublicReview review, int value) async {
    final session = AppSessionScope.read(context);
    if (session.mode != UserMode.customer ||
        session.token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Entre como cliente para avaliar a utilidade.',
          ),
        ),
      );
      return;
    }
    if (review.isOwnReview) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Você não pode votar na própria avaliação.',
          ),
        ),
      );
      return;
    }

    setState(() => _votingReviewId = review.id);
    try {
      final repository = ReviewRepository(session.apiClient);
      final summary = review.currentUserVote == value
          ? await repository.removeVote(
              reviewId: review.id,
              token: session.token!,
            )
          : await repository.vote(
              reviewId: review.id,
              value: value,
              token: session.token!,
            );
      if (!mounted) return;
      final index = _reviews.indexWhere(
        (item) => item.id == review.id,
      );
      if (index >= 0) {
        setState(() {
          _reviews = [..._reviews];
          _reviews[index] =
              _reviews[index].withVoteSummary(summary);
        });
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _votingReviewId = null);
    }
  }

  void _openPublicProfile(PublicReview review) {
    Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => PublicCustomerProfilePage(
          userId: review.authorId,
        ),
      ),
    );
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
          if (_loadingDetails) ...[
            const LinearProgressIndicator(),
            const SizedBox(height: 16),
          ],
          if (_detailsError != null) ...[
            Card(
              color: Theme.of(context).colorScheme.errorContainer,
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(establishment.category, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 20),
                        const SizedBox(width: 4),
                        Text('${establishment.averageRating.toStringAsFixed(1)} (${_reviews.length})'),
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
          if (!_loadingDetails && establishment.dishes.isEmpty)
            const Card(
              child: ListTile(
                leading: Icon(Icons.restaurant_menu_outlined),
                title: Text(
                  'Este estabelecimento ainda não cadastrou pratos.',
                ),
              ),
            )
          else
            ...establishment.dishes.map((dish) => _DishCard(dish: dish)),

          const SizedBox(height: 26),
          Text(
            'Avaliações',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 6),
          const Text(
            'Os votos de utilidade organizam os comentários, '
            'mas não alteram a nota em estrelas.',
          ),
          const SizedBox(height: 12),
          if (_loadingReviews && _reviews.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_reviewsError != null)
            Card(
              color: Theme.of(context).colorScheme.errorContainer,
              child: ListTile(
                leading: const Icon(Icons.error_outline),
                title: Text(_reviewsError!),
                trailing: IconButton(
                  tooltip: 'Tentar novamente',
                  onPressed: _loadReviews,
                  icon: const Icon(Icons.refresh),
                ),
              ),
            )
          else if (_reviews.isEmpty)
            const Card(
              child: ListTile(
                leading: Icon(Icons.rate_review_outlined),
                title: Text(
                  'Ainda não há avaliações publicadas.',
                ),
              ),
            )
          else
            for (final review in _reviews)
              _PublicReviewCard(
                review: review,
                voting: _votingReviewId == review.id,
                onAuthorTap: () => _openPublicProfile(review),
                onVote: (value) => _vote(review, value),
              ),
        ],
      ),
    );
  }
}


class _PublicReviewCard extends StatelessWidget {
  const _PublicReviewCard({
    required this.review,
    required this.voting,
    required this.onAuthorTap,
    required this.onVote,
  });

  final PublicReview review;
  final bool voting;
  final VoidCallback onAuthorTap;
  final ValueChanged<int> onVote;

  @override
  Widget build(BuildContext context) {
    final initial = review.authorDisplayName.isEmpty
        ? '?'
        : review.authorDisplayName[0].toUpperCase();
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: onAuthorTap,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    CircleAvatar(child: Text(initial)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        review.authorDisplayName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.person_search_outlined,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(
                  Icons.star,
                  color: Colors.amber,
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  review.averageRating
                      .toStringAsFixed(1)
                      .replaceAll('.', ','),
                ),
                if (review.dishName != null) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      review.dishName!,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Text(review.comment),
            const SizedBox(height: 10),
            if (voting)
              const LinearProgressIndicator()
            else
              Wrap(
                spacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  OutlinedButton.icon(
                    onPressed: review.isOwnReview
                        ? null
                        : () => onVote(1),
                    icon: Icon(
                      review.currentUserVote == 1
                          ? Icons.thumb_up
                          : Icons.thumb_up_outlined,
                    ),
                    label: Text(
                      'Útil ${review.helpfulCount}',
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: review.isOwnReview
                        ? null
                        : () => onVote(-1),
                    icon: Icon(
                      review.currentUserVote == -1
                          ? Icons.thumb_down
                          : Icons.thumb_down_outlined,
                    ),
                    label: Text(
                      'Não útil ${review.notHelpfulCount}',
                    ),
                  ),
                  if (review.isOwnReview)
                    const Text('Sua avaliação'),
                ],
              ),
          ],
        ),
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
