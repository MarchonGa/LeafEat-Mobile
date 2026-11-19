import 'package:flutter/material.dart';
import 'package:leafeat_mobile/app/session/app_session.dart';
import 'package:leafeat_mobile/core/theme/app_colors.dart';
import 'package:leafeat_mobile/features/restaurant/data/restaurant_repository.dart';
import 'package:leafeat_mobile/features/restaurant/data/restaurant_visit.dart';

class RestaurantVisitsPage extends StatefulWidget {
  const RestaurantVisitsPage({super.key});

  @override
  State<RestaurantVisitsPage> createState() => _RestaurantVisitsPageState();
}

class _RestaurantVisitsPageState extends State<RestaurantVisitsPage> {
  Future<List<RestaurantVisit>>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= _load();
  }

  RestaurantRepository _repository() {
    final session = AppSessionScope.read(context);
    return RestaurantRepository(session.apiClient, session.token!);
  }

  Future<List<RestaurantVisit>> _load() => _repository().visits();

  void _reload() => setState(() => _future = _load());

  Future<void> _confirm(RestaurantVisit visit) async {
    var typedCode = '';
    final code = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar comparecimento'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${visit.customerName} — ${visit.dishName}'),
            const SizedBox(height: 12),
            TextField(
              autofocus: true,
              textCapitalization: TextCapitalization.characters,
              onChanged: (value) => typedCode = value,
              decoration: const InputDecoration(
                labelText: 'Código apresentado pelo cliente',
                hintText: 'LF-123456',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Confirme somente após identificar o cliente e o prato pedido.',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Voltar'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(context).pop(typedCode.trim().toUpperCase()),
            child: const Text('Confirmar presença'),
          ),
        ],
      ),
    );
    if (code == null || code.isEmpty || !mounted) return;
    try {
      await _repository().confirmVisit(visit.id, code);
      if (!mounted) return;
      _reload();
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'Presença confirmada. A visita foi movida para o histórico e a avaliação foi liberada para o cliente.',
            ),
          ),
        );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString())),
        );
      }
    }
  }

  Future<void> _noShow(RestaurantVisit visit) async {
    try {
      await _repository().markNoShow(visit.id);
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

  String _status(String value) => switch (value) {
        'Scheduled' => 'Cliente pretende comparecer',
        'Confirmed' => 'Presença confirmada',
        'Evaluated' => 'Presença confirmada e avaliada',
        'Cancelled' => 'Cancelada pelo cliente',
        'NoShow' => 'Não compareceu',
        _ => value,
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Visitas de clientes'),
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
      body: FutureBuilder<List<RestaurantVisit>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: FilledButton.icon(
                onPressed: _reload,
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar novamente'),
              ),
            );
          }
          final visits = snapshot.data ?? const <RestaurantVisit>[];
          if (visits.isEmpty) {
            return const Center(
              child: Text('Nenhum cliente avisou que irá ao local.'),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: visits.length,
            itemBuilder: (context, index) {
              final visit = visits[index];
              return Card(
                child: ListTile(
                  leading: Icon(
                    visit.status == 'Scheduled'
                        ? Icons.notifications_active_outlined
                        : Icons.verified_outlined,
                    color: AppColors.primary,
                  ),
                  title: Text(visit.customerName),
                  subtitle: Text(
                    '${visit.dishName}\n${_date(visit.scheduledAt)}\n${_status(visit.status)}',
                  ),
                  isThreeLine: true,
                  trailing: visit.status == 'Scheduled'
                      ? PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'confirm') _confirm(visit);
                            if (value == 'no-show') _noShow(visit);
                          },
                          itemBuilder: (_) => const [
                            PopupMenuItem(
                              value: 'confirm',
                              child: Text('Confirmar com código'),
                            ),
                            PopupMenuItem(
                              value: 'no-show',
                              child: Text('Marcar que não compareceu'),
                            ),
                          ],
                        )
                      : null,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
