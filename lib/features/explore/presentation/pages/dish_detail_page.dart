import 'package:flutter/material.dart';
import 'package:leafeat_mobile/app/session/app_session.dart';
import 'package:leafeat_mobile/core/theme/app_colors.dart';
import 'package:leafeat_mobile/features/customer/data/customer_repository.dart';
import 'package:leafeat_mobile/features/establishments/domain/models/dish.dart';
import 'package:leafeat_mobile/features/profile/presentation/pages/public_customer_profile_page.dart';
import 'package:leafeat_mobile/features/review/data/public_review.dart';
import 'package:leafeat_mobile/features/review/data/review_repository.dart';

class DishDetailPage extends StatefulWidget {
  const DishDetailPage({
    required this.dish,
    this.establishmentId,
    super.key,
  });

  final Dish dish;
  final String? establishmentId;

  @override
  State<DishDetailPage> createState() => _DishDetailPageState();
}

class _DishDetailPageState extends State<DishDetailPage> {
  bool _scheduling = false;
  bool _reviewsRequested = false;
  bool _loadingReviews = false;
  String? _reviewsError;
  String? _votingReviewId;
  List<PublicReview> _reviews = const [];

  Dish get dish => widget.dish;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_reviewsRequested) return;
    _reviewsRequested = true;
    _loadReviews();
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
      ).dishReviews(
        dish.id,
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
            'Não foi possível carregar as avaliações deste prato.';
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

    setState(() {
      _votingReviewId = review.id;
    });
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
      if (mounted) {
        setState(() {
          _votingReviewId = null;
        });
      }
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

  Future<void> _scheduleVisit() async {
    final session = AppSessionScope.read(context);
    final token = session.token;
    if (token == null || session.mode != UserMode.customer) {
      return;
    }

    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 180)),
      initialDate: now.add(const Duration(days: 1)),
      helpText: 'Escolha o dia da visita',
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 12, minute: 0),
      helpText: 'Escolha o horário aproximado',
    );
    if (time == null || !mounted) return;

    final scheduledAt = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    if (scheduledAt.isBefore(
      now.add(const Duration(minutes: 15)),
    )) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Escolha um horário com pelo menos 15 minutos de antecedência.',
          ),
        ),
      );
      return;
    }

    setState(() {
      _scheduling = true;
    });
    try {
      final visit = await CustomerRepository(
        session.apiClient,
        token,
      ).scheduleVisit(
        establishmentId: widget.establishmentId!,
        dishId: dish.id,
        scheduledAt: scheduledAt,
      );
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title:
              const Text('Visita avisada ao restaurante'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Apresente este código ao chegar para o restaurante confirmar sua presença:',
              ),
              const SizedBox(height: 16),
              SelectableText(
                visit.confirmationCode,
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              const Text(
                'O código também ficará disponível em Minhas visitas. A avaliação será liberada após a confirmação.',
              ),
            ],
          ),
          actions: [
            FilledButton(
              onPressed: () =>
                  Navigator.of(context).pop(),
              child: const Text('Entendi'),
            ),
          ],
        ),
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString())),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _scheduling = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = AppSessionScope.maybeRead(context);
    final canSchedule = session?.token != null &&
        session?.mode == UserMode.customer &&
        widget.establishmentId != null &&
        widget.establishmentId!.isNotEmpty;
    final rating = dish.averageRating
        .toStringAsFixed(1)
        .replaceAll('.', ',');

    return Scaffold(
      appBar: AppBar(
        title: Text(dish.name),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Icon(
            Icons.lunch_dining,
            size: 80,
            color: AppColors.primary,
          ),
          const SizedBox(height: 16),
          Text(
            dish.name,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(dish.description, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                dish.totalReviews == 0
                    ? Icons.star_border
                    : Icons.star,
                color: dish.totalReviews == 0
                    ? Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant
                    : Colors.amber,
              ),
              const SizedBox(width: 5),
              Text(
                dish.totalReviews == 0
                    ? '–'
                    : '$rating (${dish.totalReviews} avaliações)',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'R\$ ${dish.price.toStringAsFixed(2).replaceAll('.', ',')}',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          if (canSchedule) ...[
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed:
                  _scheduling ? null : _scheduleVisit,
              icon: const Icon(Icons.event_available),
              label: Text(
                _scheduling
                    ? 'Enviando aviso...'
                    : 'Vou comparecer ao local',
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Informe uma data e um horário. Ao chegar, apresente o código ao restaurante.',
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 24),
          Text(
            'Informações nutricionais',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 6),
          const Text(
            'Valores informados por porção do prato.',
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                _NutritionTile(
                  label: 'Valor energético',
                  value: '${dish.calories} kcal',
                ),
                const Divider(height: 1),
                _NutritionTile(
                  label: 'Proteínas',
                  value:
                      '${dish.proteinGrams.toStringAsFixed(1)} g',
                ),
                const Divider(height: 1),
                _NutritionTile(
                  label: 'Carboidratos',
                  value:
                      '${dish.carbohydrateGrams.toStringAsFixed(1)} g',
                ),
                const Divider(height: 1),
                _NutritionTile(
                  label: 'Gorduras',
                  value:
                      '${dish.fatGrams.toStringAsFixed(1)} g',
                ),
                const Divider(height: 1),
                _NutritionTile(
                  label: 'Fibras',
                  value:
                      '${dish.fiberGrams.toStringAsFixed(1)} g',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (dish.isVegan)
                const Chip(
                  avatar: Icon(Icons.eco, size: 18),
                  label: Text('Vegano'),
                ),
              if (dish.isLactoseFree)
                const Chip(
                  avatar: Icon(Icons.no_food, size: 18),
                  label: Text('Sem lactose'),
                ),
            ],
          ),
          const SizedBox(height: 26),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Avaliações deste prato',
                  style:
                      Theme.of(context).textTheme.titleLarge,
                ),
              ),
              IconButton(
                tooltip: 'Atualizar avaliações',
                onPressed:
                    _loadingReviews ? null : _loadReviews,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'A nota do prato considera somente a avaliação dada ao prato. A nota do ambiente é exibida separadamente.',
          ),
          const SizedBox(height: 12),
          if (_loadingReviews && _reviews.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_reviewsError != null &&
              dish.reviews.isEmpty)
            Card(
              color:
                  Theme.of(context).colorScheme.errorContainer,
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
          else if (_reviews.isNotEmpty)
            for (final review in _reviews)
              _DishReviewCard(
                review: review,
                voting: _votingReviewId == review.id,
                onAuthorTap: () =>
                    _openPublicProfile(review),
                onVote: (value) => _vote(review, value),
              )
          else if (dish.reviews.isNotEmpty)
            for (final review in dish.reviews)
              Card(
                child: ListTile(
                  leading:
                      const Icon(Icons.person_outline),
                  title: Text(
                    '${review.authorName} • ${review.rating.toStringAsFixed(1)} ★',
                  ),
                  subtitle: Text(review.comment),
                ),
              )
          else
            const Card(
              child: ListTile(
                leading: Icon(Icons.rate_review_outlined),
                title: Text(
                  'Este prato ainda não recebeu avaliações.',
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DishReviewCard extends StatelessWidget {
  const _DishReviewCard({
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
                padding:
                    const EdgeInsets.symmetric(vertical: 4),
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
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(
                  avatar: const Icon(
                    Icons.star,
                    color: Colors.amber,
                    size: 18,
                  ),
                  label:
                      Text('Prato: ${review.dishRating}'),
                ),
                Chip(
                  avatar: const Icon(
                    Icons.storefront_outlined,
                    size: 18,
                  ),
                  label: Text(
                    'Ambiente: ${review.environmentRating}',
                  ),
                ),
                if (review.presenceConfirmed)
                  const Chip(
                    avatar: Icon(
                      Icons.verified_user_outlined,
                      size: 18,
                    ),
                    label: Text('Presença confirmada'),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(review.comment),
            if (review.restaurantResponse != null) ...[
              const SizedBox(height: 12),
              Card(
                color: Theme.of(context)
                    .colorScheme
                    .primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Resposta oficial do restaurante',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(review.restaurantResponse!),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 10),
            if (voting)
              const LinearProgressIndicator()
            else
              Wrap(
                spacing: 8,
                crossAxisAlignment:
                    WrapCrossAlignment.center,
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

class _NutritionTile extends StatelessWidget {
  const _NutritionTile({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      trailing: Text(
        value,
        style:
            const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}
