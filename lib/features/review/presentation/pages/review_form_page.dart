import 'package:flutter/material.dart';
import 'package:leafeat_mobile/core/theme/app_colors.dart';
import 'package:leafeat_mobile/features/establishments/data/mock_establishments.dart';
import 'package:leafeat_mobile/features/establishments/domain/models/dish.dart';

class ReviewFormPage extends StatefulWidget {
  const ReviewFormPage({super.key});
  @override
  State<ReviewFormPage> createState() => _ReviewFormPageState();
}

class _ReviewFormPageState extends State<ReviewFormPage> {
  final _formKey = GlobalKey<FormState>();
  late Dish _dish = mockEstablishments.first.dishes.first;
  double _dishRating = 5;
  double _environmentRating = 5;
  double _serviceRating = 5;

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Avaliação registrada'),
        content: const Text('A avaliação foi mantida somente em memória nesta demonstração.'),
        actions: [TextButton(onPressed: () { Navigator.of(context).pop(); Navigator.of(context).pop(); }, child: const Text('Concluir'))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dishes = mockEstablishments.first.dishes;
    return Scaffold(
      appBar: AppBar(title: const Text('Avaliar visita'), backgroundColor: AppColors.primary, foregroundColor: AppColors.onPrimary),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const ListTile(contentPadding: EdgeInsets.zero, leading: Icon(Icons.store, color: AppColors.primary), title: Text('Sabor Natural'), subtitle: Text('Visita demonstrativa validada')),
            const SizedBox(height: 12),
            DropdownButtonFormField<Dish>(
              initialValue: _dish,
              decoration: const InputDecoration(labelText: 'Prato avaliado', border: OutlineInputBorder()),
              items: dishes.map((dish) => DropdownMenuItem(value: dish, child: Text(dish.name))).toList(),
              onChanged: (dish) => setState(() => _dish = dish!),
            ),
            const SizedBox(height: 20),
            _RatingField(label: 'Nota do prato', value: _dishRating, onChanged: (value) => setState(() => _dishRating = value)),
            _RatingField(label: 'Nota do ambiente', value: _environmentRating, onChanged: (value) => setState(() => _environmentRating = value)),
            _RatingField(label: 'Nota do atendimento', value: _serviceRating, onChanged: (value) => setState(() => _serviceRating = value)),
            const SizedBox(height: 10),
            TextFormField(
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Comentário', hintText: 'Conte como foi sua experiência', border: OutlineInputBorder()),
              validator: (value) => value == null || value.trim().length < 5 ? 'Escreva um comentário com pelo menos 5 caracteres.' : null,
            ),
            const SizedBox(height: 22),
            FilledButton.icon(onPressed: _submit, icon: const Icon(Icons.send), label: const Text('Enviar avaliação')),
          ],
        ),
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
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('$label: ${value.round()} ★', style: const TextStyle(fontWeight: FontWeight.bold)),
      Slider(value: value, min: 1, max: 5, divisions: 4, label: value.round().toString(), onChanged: onChanged),
    ]);
  }
}
