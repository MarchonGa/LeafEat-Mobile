import 'package:flutter/material.dart';
import 'package:leafeat_mobile/app/session/app_session.dart';
import 'package:leafeat_mobile/core/theme/app_colors.dart';
import 'package:leafeat_mobile/features/customer/data/customer_repository.dart';
import 'package:leafeat_mobile/features/customer/data/customer_visit.dart';

class ReviewFormPage extends StatefulWidget {
  const ReviewFormPage({this.initialVisit, super.key});

  final CustomerVisit? initialVisit;

  @override
  State<ReviewFormPage> createState() => _ReviewFormPageState();
}

class _ReviewFormPageState extends State<ReviewFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _commentController = TextEditingController();
  Future<List<CustomerVisit>>? _visits;
  CustomerVisit? _visit;
  double _dishRating = 5;
  double _environmentRating = 5;
  bool _submitting = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _visit ??= widget.initialVisit;
    final session = AppSessionScope.maybeRead(context);
    _visits ??= session == null
        ? Future.value([
            CustomerVisit(
              id: 'preview-visit',
              establishmentId: 'preview-establishment',
              establishmentName: 'Estabelecimento',
              dishId: 'preview-dish',
              dishName: 'Prato',
              confirmationCode: 'LF-000000',
              status: 'Confirmed',
              scheduledAt: DateTime.now(),
              confirmedAt: DateTime.now(),
              canReview: true,
            ),
          ])
        : session.token == null
            ? Future.value(const <CustomerVisit>[])
            : CustomerRepository(
            session!.apiClient,
            session.token!,
          ).visits().then(
                (items) => items.where((item) => item.canReview).toList(),
              );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _visit == null) return;
    final session = AppSessionScope.maybeRead(context);
    if (session?.token == null) return;
    setState(() => _submitting = true);
    try {
      await CustomerRepository(
        session!.apiClient,
        session.token!,
      ).createReview({
        'establishmentId': _visit!.establishmentId,
        'dishId': _visit!.dishId,
        'visitId': _visit!.id,
        'dishRating': _dishRating.round(),
        'environmentRating': _environmentRating.round(),
        'comment': _commentController.text.trim(),
      });
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Avaliação registrada'),
          content: const Text(
            'Sua avaliação foi vinculada à presença confirmada e salva no histórico.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Concluir'),
            ),
          ],
        ),
      );
      if (mounted) Navigator.of(context).pop();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  String _visitLabel(CustomerVisit visit) =>
      '${visit.establishmentName} — ${visit.dishName}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Avaliar experiência'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
      ),
      body: FutureBuilder<List<CustomerVisit>>(
        future: _visits,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final eligible = snapshot.data ?? const <CustomerVisit>[];
          final choices = <CustomerVisit>[
            if (widget.initialVisit?.canReview ?? false) widget.initialVisit!,
            ...eligible.where((item) => item.id != widget.initialVisit?.id),
          ];
          if (choices.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'Nenhuma visita está liberada para avaliação. Escolha um prato, avise que irá ao local e peça ao restaurante para confirmar sua presença.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          _visit ??= choices.first;
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Card(
                  child: ListTile(
                    leading: Icon(Icons.verified_user_outlined),
                    title: Text('Avaliação com presença confirmada'),
                    subtitle: Text(
                      'Cada visita confirmada permite uma única avaliação.',
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<CustomerVisit>(
                  initialValue: choices.any((item) => item.id == _visit?.id)
                      ? _visit
                      : choices.first,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Visita confirmada',
                    border: OutlineInputBorder(),
                  ),
                  items: choices
                      .map(
                        (visit) => DropdownMenuItem(
                          value: visit,
                          child: Text(
                            _visitLabel(visit),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (visit) => setState(() => _visit = visit),
                ),
                const SizedBox(height: 20),
                _RatingField(
                  label: 'Nota do prato',
                  value: _dishRating,
                  onChanged: (value) =>
                      setState(() => _dishRating = value),
                ),
                _RatingField(
                  label: 'Nota do ambiente',
                  value: _environmentRating,
                  onChanged: (value) =>
                      setState(() => _environmentRating = value),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _commentController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Comentário',
                    hintText: 'Conte como foi sua experiência',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value == null || value.trim().length < 5
                          ? 'Escreva um comentário com pelo menos 5 caracteres.'
                          : null,
                ),
                const SizedBox(height: 22),
                FilledButton.icon(
                  onPressed: _submitting ? null : _submit,
                  icon: const Icon(Icons.send),
                  label: Text(
                    _submitting ? 'Enviando...' : 'Enviar avaliação',
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _RatingField extends StatelessWidget {
  const _RatingField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ${value.round()} ★',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Slider(
            value: value,
            min: 1,
            max: 5,
            divisions: 4,
            label: value.round().toString(),
            onChanged: onChanged,
          ),
        ],
      );
}
