import 'package:flutter/material.dart';
import 'package:leafeat_mobile/app/session/app_session.dart';
import 'package:leafeat_mobile/core/theme/app_colors.dart';
import 'package:leafeat_mobile/features/customer/data/customer_repository.dart';
import 'package:leafeat_mobile/features/establishments/domain/models/dish.dart';

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

  Dish get dish => widget.dish;

  Future<void> _scheduleVisit() async {
    final session = AppSessionScope.read(context);
    final token = session.token;
    if (token == null || session.mode != UserMode.customer) return;

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
    if (scheduledAt.isBefore(now.add(const Duration(minutes: 15)))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Escolha um horário com pelo menos 15 minutos de antecedência.'),
        ),
      );
      return;
    }

    setState(() => _scheduling = true);
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
          title: const Text('Visita avisada ao restaurante'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Apresente este código ao chegar para o restaurante confirmar sua presença:',
              ),
              const SizedBox(height: 16),
              SelectableText(
                visit.confirmationCode,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
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
              onPressed: () => Navigator.of(context).pop(),
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
      if (mounted) setState(() => _scheduling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = AppSessionScope.maybeRead(context);
    final canSchedule = session?.token != null &&
        session?.mode == UserMode.customer &&
        widget.establishmentId != null &&
        widget.establishmentId!.isNotEmpty;

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
          Text(
            'R\$ ${dish.price.toStringAsFixed(2).replaceAll('.', ',')}',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          if (canSchedule) ...[
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _scheduling ? null : _scheduleVisit,
              icon: const Icon(Icons.event_available),
              label: Text(
                _scheduling ? 'Enviando aviso...' : 'Vou comparecer ao local',
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
          const Text('Valores informados por porção do prato.'),
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
                  value: '${dish.proteinGrams.toStringAsFixed(1)} g',
                ),
                const Divider(height: 1),
                _NutritionTile(
                  label: 'Carboidratos',
                  value: '${dish.carbohydrateGrams.toStringAsFixed(1)} g',
                ),
                const Divider(height: 1),
                _NutritionTile(
                  label: 'Gorduras',
                  value: '${dish.fatGrams.toStringAsFixed(1)} g',
                ),
                const Divider(height: 1),
                _NutritionTile(
                  label: 'Fibras',
                  value: '${dish.fiberGrams.toStringAsFixed(1)} g',
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
          if (dish.reviews.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text('Avaliações', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            ...dish.reviews.map(
              (review) => Card(
                child: ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: Text(
                    '${review.authorName} • ${review.rating.toStringAsFixed(1)} ★',
                  ),
                  subtitle: Text(review.comment),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _NutritionTile extends StatelessWidget {
  const _NutritionTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      trailing: Text(
        value,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}
