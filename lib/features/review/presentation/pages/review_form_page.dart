import 'package:flutter/material.dart';
import 'package:leafeat_mobile/app/session/app_session.dart';
import 'package:leafeat_mobile/core/theme/app_colors.dart';
import 'package:leafeat_mobile/features/customer/data/customer_repository.dart';
import 'package:leafeat_mobile/features/establishments/data/mock_establishments.dart';
import 'package:leafeat_mobile/features/establishments/data/establishments_repository.dart';
import 'package:leafeat_mobile/features/establishments/domain/models/dish.dart';
import 'package:leafeat_mobile/features/establishments/domain/models/establishment.dart';

class ReviewFormPage extends StatefulWidget {
  const ReviewFormPage({super.key});
  @override
  State<ReviewFormPage> createState() => _ReviewFormPageState();
}

class _ReviewFormPageState extends State<ReviewFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _commentController = TextEditingController();
  Future<List<Establishment>>? _establishments;
  Establishment? _establishment;
  Dish? _dish;
  double _dishRating = 5;
  double _environmentRating = 5;
  bool _submitting = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final session = AppSessionScope.maybeRead(context);
    _establishments ??= session == null
        ? Future.value(mockEstablishments)
        : EstablishmentsRepository(session.apiClient).list();
  }

  @override
  void dispose() { _commentController.dispose(); super.dispose(); }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _establishment == null) return;
    final session = AppSessionScope.maybeRead(context);
    if (session?.token == null) return;
    setState(() => _submitting = true);
    try {
      await CustomerRepository(session!.apiClient, session.token!).createReview({
        'establishmentId': _establishment!.id,
        'dishId': _dish?.id,
        'dishRating': _dishRating.round(),
        'environmentRating': _environmentRating.round(),
        'comment': _commentController.text.trim(),
      });
      if (!mounted) return;
      await showDialog<void>(context: context, builder: (context) => AlertDialog(
        title: const Text('Avaliação registrada'),
        content: const Text('Sua avaliação foi salva no seu histórico.'),
        actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Concluir'))],
      ));
      if (mounted) Navigator.of(context).pop();
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Avaliar experiência'), backgroundColor: AppColors.primary, foregroundColor: AppColors.onPrimary),
      body: FutureBuilder<List<Establishment>>(
        future: _establishments,
        builder: (context, snapshot) {
          final establishments = snapshot.data ?? mockEstablishments;
          return Form(key: _formKey, child: ListView(padding: const EdgeInsets.all(20), children: [
            DropdownButtonFormField<Establishment>(
              initialValue: _establishment,
              decoration: const InputDecoration(labelText: 'Estabelecimento', border: OutlineInputBorder()),
              items: establishments.map((item) => DropdownMenuItem(value: item, child: Text(item.name))).toList(),
              onChanged: (item) => setState(() { _establishment = item; _dish = null; }),
              validator: (value) => value == null ? 'Escolha o estabelecimento.' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<Dish>(
              initialValue: _dish,
              decoration: const InputDecoration(labelText: 'Prato avaliado (opcional)', border: OutlineInputBorder()),
              items: (_establishment?.dishes ?? const <Dish>[]).map((dish) => DropdownMenuItem(value: dish, child: Text(dish.name))).toList(),
              onChanged: _establishment == null ? null : (dish) => setState(() => _dish = dish),
            ),
            const SizedBox(height: 20),
            _RatingField(label: 'Nota do prato', value: _dishRating, onChanged: (value) => setState(() => _dishRating = value)),
            _RatingField(label: 'Nota do ambiente', value: _environmentRating, onChanged: (value) => setState(() => _environmentRating = value)),
            const SizedBox(height: 10),
            TextFormField(controller: _commentController, maxLines: 4, decoration: const InputDecoration(labelText: 'Comentário', hintText: 'Conte como foi sua experiência', border: OutlineInputBorder()), validator: (value) => value == null || value.trim().length < 5 ? 'Escreva um comentário com pelo menos 5 caracteres.' : null),
            const SizedBox(height: 22),
            FilledButton.icon(onPressed: _submitting ? null : _submit, icon: const Icon(Icons.send), label: Text(_submitting ? 'Enviando...' : 'Enviar avaliação')),
          ]));
        },
      ),
    );
  }
}

class _RatingField extends StatelessWidget {
  const _RatingField({required this.label, required this.value, required this.onChanged});
  final String label;
  final double value;
  final ValueChanged<double> onChanged;
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text('$label: ${value.round()} ★', style: const TextStyle(fontWeight: FontWeight.bold)),
    Slider(value: value, min: 1, max: 5, divisions: 4, label: value.round().toString(), onChanged: onChanged),
  ]);
}
