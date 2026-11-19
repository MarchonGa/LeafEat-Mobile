import 'package:flutter/material.dart';
import 'package:leafeat_mobile/app/session/app_session.dart';
import 'package:leafeat_mobile/core/theme/app_colors.dart';
import 'package:leafeat_mobile/features/customer/data/customer_repository.dart';
import 'package:leafeat_mobile/features/customer/data/customer_visit.dart';
import 'package:leafeat_mobile/features/review/presentation/pages/review_form_page.dart';

class MyVisitsPage extends StatefulWidget {
  const MyVisitsPage({super.key});

  @override
  State<MyVisitsPage> createState() => _MyVisitsPageState();
}

class _MyVisitsPageState extends State<MyVisitsPage> {
  Future<List<CustomerVisit>>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= _load();
  }

  Future<List<CustomerVisit>> _load() {
    final session = AppSessionScope.read(context);
    return CustomerRepository(session.apiClient, session.token!).visits();
  }

  void _reload() => setState(() => _future = _load());

  Future<void> _cancel(CustomerVisit visit) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar visita?'),
        content: Text(
          'O restaurante deixará de esperar sua visita para o prato ${visit.dishName}.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Manter'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Cancelar visita'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final session = AppSessionScope.read(context);
    try {
      await CustomerRepository(
        session.apiClient,
        session.token!,
      ).cancelVisit(visit.id);
      if (mounted) _reload();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString())),
        );
      }
    }
  }

  String _date(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$day/$month/${value.year} às $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas visitas'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        actions: [
          IconButton(
            onPressed: _reload,
            tooltip: 'Atualizar',
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder<List<CustomerVisit>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      snapshot.error.toString(),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: _reload,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              ),
            );
          }
          final visits = snapshot.data ?? const <CustomerVisit>[];
          if (visits.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'Você ainda não avisou que irá a um restaurante. Abra um prato para agendar uma visita.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: visits.length,
            itemBuilder: (context, index) {
              final visit = visits[index];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        visit.establishmentName,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(visit.dishName),
                      Text(_date(visit.scheduledAt)),
                      const SizedBox(height: 10),
                      Chip(
                        avatar: Icon(
                          visit.status == 'Confirmed' ||
                                  visit.status == 'Evaluated'
                              ? Icons.verified
                              : Icons.schedule,
                          size: 18,
                        ),
                        label: Text(visit.statusLabel),
                      ),
                      if (visit.status == 'Scheduled') ...[
                        const SizedBox(height: 8),
                        const Text('Código para apresentar ao restaurante'),
                        SelectableText(
                          visit.confirmationCode,
                          style:
                              Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ],
                      if (visit.canReview) ...[
                        const SizedBox(height: 8),
                        const Text(
                          'O restaurante confirmou sua presença. Esta visita já pode ser avaliada.',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          if (visit.status == 'Scheduled')
                            OutlinedButton(
                              onPressed: () => _cancel(visit),
                              child: const Text('Cancelar'),
                            ),
                          if (visit.canReview)
                            FilledButton.icon(
                              onPressed: () async {
                                await Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) =>
                                        ReviewFormPage(initialVisit: visit),
                                  ),
                                );
                                if (mounted) _reload();
                              },
                              icon: const Icon(Icons.rate_review),
                              label: const Text('Avaliar visita'),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
