import 'package:flutter/material.dart';
import 'package:leafeat_mobile/app/session/app_session.dart';
import 'package:leafeat_mobile/core/theme/app_colors.dart';
import 'package:leafeat_mobile/features/customer/data/customer_repository.dart';
import 'package:leafeat_mobile/features/customer/data/customer_review.dart';
import 'package:leafeat_mobile/features/customer/data/customer_visit.dart';
import 'package:leafeat_mobile/features/review/presentation/pages/review_form_page.dart';

class MyReviewsPage extends StatefulWidget {
  const MyReviewsPage({super.key});

  @override
  State<MyReviewsPage> createState() => _MyReviewsPageState();
}

class _MyReviewsPageState extends State<MyReviewsPage> {
  Future<_MyReviewsData>? _data;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _data ??= _load();
  }

  Future<_MyReviewsData> _load() async {
    final session = AppSessionScope.read(context);
    if (session.token == null) {
      throw 'Faça login como cliente para consultar suas avaliações.';
    }

    final repository = CustomerRepository(
      session.apiClient,
      session.token!,
    );
    final visitsFuture = repository.visits();
    final reviewsFuture = repository.reviews();
    final visits = await visitsFuture;
    final reviews = await reviewsFuture;

    return _MyReviewsData(
      pending: visits.where((visit) => visit.canReview).toList(),
      completed: reviews,
    );
  }

  Future<void> _refresh() async {
    final next = _load();
    setState(() {
      _data = next;
    });
    await next;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Minhas avaliações'),
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          actions: [
            IconButton(
              tooltip: 'Atualizar avaliações',
              onPressed: _refresh,
              icon: const Icon(Icons.refresh),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(
                icon: Icon(Icons.pending_actions_outlined),
                text: 'Pendentes',
              ),
              Tab(
                icon: Icon(Icons.rate_review_outlined),
                text: 'Realizadas',
              ),
            ],
          ),
        ),
        body: FutureBuilder<_MyReviewsData>(
          future: _data,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done &&
                !snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return _ErrorView(
                message: snapshot.error.toString(),
                onRetry: _refresh,
              );
            }

            final data = snapshot.data ?? const _MyReviewsData();
            return TabBarView(
              children: [
                _PendingReviewsTab(
                  visits: data.pending,
                  onRefresh: _refresh,
                ),
                _CompletedReviewsTab(
                  reviews: data.completed,
                  onRefresh: _refresh,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _PendingReviewsTab extends StatelessWidget {
  const _PendingReviewsTab({
    required this.visits,
    required this.onRefresh,
  });

  final List<CustomerVisit> visits;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    if (visits.isEmpty) {
      return _EmptyList(
        icon: Icons.task_alt,
        message: 'Nenhuma avaliação pendente. Quando o restaurante confirmar sua presença, a visita aparecerá aqui.',
        onRefresh: onRefresh,
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: visits.length,
        itemBuilder: (context, index) {
          final visit = visits[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.verified_user_outlined,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          visit.establishmentName,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(visit.dishName),
                  Text(
                    'Visita em ${_date(visit.scheduledAt)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Presença confirmada. Conte como foi sua experiência.',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: () async {
                      await Navigator.of(context).push<void>(
                        MaterialPageRoute(
                          builder: (_) => ReviewFormPage(
                            initialVisit: visit,
                          ),
                        ),
                      );
                      await onRefresh();
                    },
                    icon: const Icon(Icons.rate_review),
                    label: const Text('Avaliar agora'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CompletedReviewsTab extends StatelessWidget {
  const _CompletedReviewsTab({
    required this.reviews,
    required this.onRefresh,
  });

  final List<CustomerReview> reviews;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    if (reviews.isEmpty) {
      return _EmptyList(
        icon: Icons.reviews_outlined,
        message: 'Você ainda não publicou avaliações.',
        onRefresh: onRefresh,
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: reviews.length,
        itemBuilder: (context, index) {
          final review = reviews[index];
          final grade = review.averageRating
              .toStringAsFixed(1)
              .replaceAll('.', ',');
          final hasResponse =
              review.restaurantResponse?.trim().isNotEmpty ?? false;

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          review.establishmentName,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      Text(
                        grade,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(review.dishName ?? 'Avaliação geral'),
                  Text(
                    'Publicada em ${_date(review.createdAt)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Chip(label: Text('Prato: ${review.dishRating}')),
                      Chip(
                        label: Text(
                          'Ambiente: ${review.environmentRating}',
                        ),
                      ),
                      Chip(
                        avatar: const Icon(Icons.thumb_up_outlined, size: 18),
                        label: Text('Útil: ${review.helpfulCount}'),
                      ),
                      Chip(
                        avatar: const Icon(
                          Icons.thumb_down_outlined,
                          size: 18,
                        ),
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
                  const Divider(height: 28),
                  if (hasResponse)
                    Card(
                      margin: EdgeInsets.zero,
                      color: Theme.of(context)
                          .colorScheme
                          .secondaryContainer,
                      child: ListTile(
                        leading: const Icon(Icons.storefront_outlined),
                        title: const Text('Resposta do restaurante'),
                        subtitle: Text(review.restaurantResponse!),
                      ),
                    )
                  else
                    const ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.hourglass_empty),
                      title: Text('Aguardando resposta do restaurante'),
                      subtitle: Text(
                        'Sua avaliação já está publicada e pode receber votos.',
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _EmptyList extends StatelessWidget {
  const _EmptyList({
    required this.icon,
    required this.message,
    required this.onRefresh,
  });

  final IconData icon;
  final String message;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(
          horizontal: 32,
          vertical: 80,
        ),
        children: [
          Icon(icon, size: 72, color: AppColors.primary),
          const SizedBox(height: 16),
          Text(message, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 56),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MyReviewsData {
  const _MyReviewsData({
    this.pending = const <CustomerVisit>[],
    this.completed = const <CustomerReview>[],
  });

  final List<CustomerVisit> pending;
  final List<CustomerReview> completed;
}

String _date(DateTime value) {
  final day = value.day.toString().padLeft(2, '0');
  final month = value.month.toString().padLeft(2, '0');
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return '$day/$month/${value.year} às $hour:$minute';
}
