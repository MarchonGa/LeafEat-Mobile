import 'package:flutter/material.dart';
import 'package:leafeat_mobile/app/session/app_session.dart';
import 'package:leafeat_mobile/core/theme/app_colors.dart';
import 'package:leafeat_mobile/features/profile/presentation/pages/public_customer_profile_page.dart';
import 'package:leafeat_mobile/features/restaurant/data/restaurant_repository.dart';
import 'package:leafeat_mobile/features/restaurant/data/restaurant_review.dart';

class RestaurantReviewsPage extends StatefulWidget {
  const RestaurantReviewsPage({super.key});

  @override
  State<RestaurantReviewsPage> createState() =>
      _RestaurantReviewsPageState();
}

class _RestaurantReviewsPageState extends State<RestaurantReviewsPage> {
  List<RestaurantReview> _reviews = const [];
  bool _initialized = false;
  bool _loading = true;
  String? _error;

  RestaurantRepository _repository() {
    final session = AppSessionScope.read(context);
    return RestaurantRepository(session.apiClient, session.token!);
  }

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
      final reviews = await _repository().reviews();
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

  Future<String?> _textDialog({
    required String title,
    required String label,
    required String? initialValue,
    required int maxLength,
    required bool allowEmpty,
  }) async {
    final controller = TextEditingController(text: initialValue);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          maxLines: 5,
          maxLength: maxLength,
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              final value = controller.text.trim();
              if (!allowEmpty && value.isEmpty) return;
              Navigator.of(context).pop(value);
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
    controller.dispose();
    return result;
  }

  Future<void> _editResponse(RestaurantReview review) async {
    final response = await _textDialog(
      title: review.restaurantResponse == null
          ? 'Responder avaliação'
          : 'Editar resposta pública',
      label: 'Resposta oficial do restaurante',
      initialValue: review.restaurantResponse,
      maxLength: 1000,
      allowEmpty: false,
    );
    if (response == null || !mounted) return;
    try {
      await _repository().respondToReview(review.id, response);
      if (mounted) _load();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString())),
        );
      }
    }
  }

  Future<void> _editNote(RestaurantReview review) async {
    final note = await _textDialog(
      title: 'Anotação interna',
      label: 'Registro privado para acompanhamento',
      initialValue: review.internalNote,
      maxLength: 2000,
      allowEmpty: true,
    );
    if (note == null || !mounted) return;
    try {
      await _repository().saveReviewInternalNote(
        review.id,
        note.isEmpty ? null : note,
      );
      if (mounted) _load();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString())),
        );
      }
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
                          onPressed: _load,
                          icon: const Icon(Icons.refresh),
                        ),
                      ),
                    ),
                  if (_reviews.isEmpty && _error == null)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 64),
                      child: Center(
                        child: Text('Nenhuma avaliação recebida.'),
                      ),
                    )
                  else
                    ..._reviews.map(
                      (review) => _ReviewCard(
                        review: review,
                        onRespond: () => _editResponse(review),
                        onNote: () => _editNote(review),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.review,
    required this.onRespond,
    required this.onNote,
  });

  final RestaurantReview review;
  final VoidCallback onRespond;
  final VoidCallback onNote;

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
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text('Avaliação em ${_date(review.createdAt)}'),
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
            const SizedBox(height: 10),
            Card(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: ListTile(
                leading: const Icon(Icons.verified_user_outlined),
                title: const Text('Presença confirmada'),
                subtitle: Text(
                  'Visita marcada para ${_date(review.visitScheduledAt)}'
                  '${review.visitConfirmedAt == null ? '' : '\nConfirmada em ${_date(review.visitConfirmedAt!)}'}',
                ),
              ),
            ),
            if (review.dishName != null)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.lunch_dining_outlined),
                title: Text(review.dishName!),
              ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(label: Text('Prato: ${review.dishRating}')),
                Chip(label: Text('Ambiente: ${review.environmentRating}')),
                Chip(label: Text('Útil: ${review.helpfulCount}')),
                Chip(label: Text('Não útil: ${review.notHelpfulCount}')),
              ],
            ),
            if (review.comment.trim().isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(review.comment),
            ],
            if (review.restaurantResponse != null) ...[
              const Divider(height: 28),
              const Text(
                'Resposta pública do restaurante',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(review.restaurantResponse!),
              if (review.responseUpdatedAt != null)
                Text(
                  'Editada em ${_date(review.responseUpdatedAt!)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
            ],
            if (review.internalNote != null) ...[
              const SizedBox(height: 12),
              Card(
                color: Theme.of(context).colorScheme.secondaryContainer,
                child: ListTile(
                  leading: const Icon(Icons.lock_outline),
                  title: const Text('Anotação interna'),
                  subtitle: Text(review.internalNote!),
                ),
              ),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                FilledButton.tonalIcon(
                  onPressed: onRespond,
                  icon: const Icon(Icons.reply),
                  label: Text(
                    review.restaurantResponse == null
                        ? 'Responder'
                        : 'Editar resposta',
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: onNote,
                  icon: const Icon(Icons.lock_outline),
                  label: const Text('Anotação interna'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _date(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$day/$month/${value.year} às $hour:$minute';
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
