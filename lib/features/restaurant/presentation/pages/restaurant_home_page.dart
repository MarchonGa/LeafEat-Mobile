import 'package:flutter/material.dart';
import 'package:leafeat_mobile/app/session/app_session.dart';
import 'package:leafeat_mobile/core/theme/app_colors.dart';
import 'package:leafeat_mobile/features/restaurant/data/restaurant_dashboard.dart';
import 'package:leafeat_mobile/features/restaurant/data/restaurant_repository.dart';
import 'package:leafeat_mobile/features/restaurant/presentation/pages/restaurant_visits_page.dart';

class RestaurantHomePage extends StatefulWidget {
  const RestaurantHomePage({super.key});

  @override
  State<RestaurantHomePage> createState() => _RestaurantHomePageState();
}

class _RestaurantHomePageState extends State<RestaurantHomePage> {
  RestaurantDashboard? _dashboard;
  bool _initialized = false;
  bool _loading = true;
  String? _error;
  int _pendingVisits = 0;

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
        _error = 'Entre como restaurante para consultar o painel.';
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final repository = RestaurantRepository(
        session.apiClient,
        session.token!,
      );
      final results = await Future.wait([
        repository.dashboard(),
        repository.visits(),
      ]);
      final dashboard = results[0] as RestaurantDashboard;
      final visits = results[1] as List;
      if (!mounted) return;
      setState(() {
        _dashboard = dashboard;
        _pendingVisits = visits.where((item) => item.status == 'Scheduled').length;
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
    final dashboard = _dashboard;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Painel do restaurante'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        actions: [
          IconButton(
            tooltip: 'Atualizar painel',
            onPressed: _loading ? null : _load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _loading && dashboard == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
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
                  if (dashboard != null) ...[
                    Text(
                      'Olá, ${dashboard.establishmentName}!',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Acompanhe os dados reais do seu cardápio e das '
                      'avaliações recebidas.',
                    ),
                    const SizedBox(height: 20),
                    Card(
                      color: _pendingVisits > 0
                          ? Theme.of(context).colorScheme.primaryContainer
                          : null,
                      child: ListTile(
                        leading: const Icon(Icons.notifications_active_outlined),
                        title: Text(
                          _pendingVisits == 1
                              ? '1 cliente pretende comparecer'
                              : '$_pendingVisits clientes pretendem comparecer',
                        ),
                        subtitle: const Text(
                          'Consulte os horários e confirme a presença com o código do cliente.',
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const RestaurantVisitsPage(),
                            ),
                          );
                          if (mounted) _load();
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _SummaryCard(
                            icon: Icons.restaurant_menu,
                            value: dashboard.totalDishes.toString(),
                            label: 'Pratos',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _SummaryCard(
                            icon: Icons.star,
                            value: _rating(dashboard.averageRating),
                            label: 'Nota geral',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _SummaryCard(
                            icon: Icons.monitor_heart_outlined,
                            value:
                                '${_percentage(dashboard.coveragePercentage)}%',
                            label: 'Cobertura',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _SummaryCard(
                            icon: Icons.rate_review_outlined,
                            value: dashboard.reviewCount.toString(),
                            label: 'Avaliações',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Cobertura nutricional',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 10),
                    _CoverageCard(dashboard: dashboard),
                  ] else if (_error != null)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 48),
                      child: Center(
                        child: Text(
                          'Não foi possível carregar os indicadores.',
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  String _rating(double value) =>
      value.toStringAsFixed(1).replaceAll('.', ',');

  String _percentage(double value) =>
      value == value.roundToDouble()
          ? value.toStringAsFixed(0)
          : value.toStringAsFixed(1).replaceAll('.', ',');
}

class _CoverageCard extends StatelessWidget {
  const _CoverageCard({required this.dashboard});

  final RestaurantDashboard dashboard;

  @override
  Widget build(BuildContext context) {
    final level = dashboard.badgeLevel;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  level == null
                      ? Icons.info_outline
                      : Icons.workspace_premium,
                  color: _badgeColor(level),
                ),
                const SizedBox(width: 8),
                Text(
                  level == null ? 'Sem selo' : 'Selo $level',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: (dashboard.coveragePercentage / 100)
                  .clamp(0, 1)
                  .toDouble(),
            ),
            const SizedBox(height: 8),
            Text(
              '${dashboard.dishesWithNutrition} de '
              '${dashboard.totalDishes} pratos possuem informações '
              'nutricionais.',
            ),
            const SizedBox(height: 6),
            const Text(
              'O selo indica cobertura, não verificação por visita técnica.',
            ),
          ],
        ),
      ),
    );
  }

  Color _badgeColor(String? level) => switch (level) {
        'Bronze' => const Color(0xFF9C6B30),
        'Prata' => const Color(0xFF757575),
        'Ouro' => const Color(0xFFC28B00),
        _ => Colors.grey,
      };
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(label),
          ],
        ),
      ),
    );
  }
}
