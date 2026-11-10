import 'package:flutter/material.dart';
import 'package:leafeat_mobile/core/theme/app_colors.dart';
import 'package:leafeat_mobile/features/establishments/domain/models/dish.dart';

class DishFormPage extends StatefulWidget {
  const DishFormPage({this.dish, super.key});
  final Dish? dish;

  @override
  State<DishFormPage> createState() => _DishFormPageState();
}

class _DishFormPageState extends State<DishFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _description;
  late final TextEditingController _price;
  late final TextEditingController _protein;
  late final TextEditingController _carbohydrate;
  late final TextEditingController _fat;
  late final TextEditingController _fiber;
  late bool _isVegan;
  late bool _isLactoseFree;

  @override
  void initState() {
    super.initState();
    final dish = widget.dish;
    _name = TextEditingController(text: dish?.name);
    _description = TextEditingController(text: dish?.description);
    _price = TextEditingController(text: dish?.price.toStringAsFixed(2));
    _protein = TextEditingController(text: dish?.proteinGrams.toString());
    _carbohydrate = TextEditingController(text: dish?.carbohydrateGrams.toString());
    _fat = TextEditingController(text: dish?.fatGrams.toString());
    _fiber = TextEditingController(text: dish?.fiberGrams.toString());
    _isVegan = dish?.isVegan ?? false;
    _isLactoseFree = dish?.isLactoseFree ?? false;

    for (final controller in [_protein, _carbohydrate, _fat]) {
      controller.addListener(_updateCalories);
    }
  }

  @override
  void dispose() {
    for (final controller in [_name, _description, _price, _protein, _carbohydrate, _fat, _fiber]) {
      controller.dispose();
    }
    super.dispose();
  }

  double _number(TextEditingController controller) => double.parse(controller.text.replaceAll(',', '.'));

  double _numberOrZero(TextEditingController controller) {
    return double.tryParse(controller.text.replaceAll(',', '.')) ?? 0;
  }

  int get _calculatedCalories {
    return Dish.calculateCalories(
      proteinGrams: _numberOrZero(_protein),
      carbohydrateGrams: _numberOrZero(_carbohydrate),
      fatGrams: _numberOrZero(_fat),
    );
  }

  void _updateCalories() {
    if (mounted) setState(() {});
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(
      Dish(
        id: widget.dish?.id ?? 'dish-${DateTime.now().millisecondsSinceEpoch}',
        name: _name.text.trim(),
        description: _description.text.trim(),
        price: _number(_price),
        calories: _calculatedCalories,
        proteinGrams: _number(_protein),
        carbohydrateGrams: _number(_carbohydrate),
        fatGrams: _number(_fat),
        fiberGrams: _number(_fiber),
        isVegan: _isVegan,
        isLactoseFree: _isLactoseFree,
        reviews: widget.dish?.reviews ?? const [],
      ),
    );
  }

  String? _required(String? value) => value == null || value.trim().isEmpty ? 'Campo obrigatório.' : null;

  String? _numeric(String? value) {
    if (_required(value) != null) return 'Campo obrigatório.';
    final number = double.tryParse(value!.replaceAll(',', '.'));
    if (number == null) return 'Informe um número válido.';
    if (number < 0) return 'O valor não pode ser negativo.';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.dish != null;
    return Scaffold(
      appBar: AppBar(title: Text(editing ? 'Editar prato' : 'Novo prato'), backgroundColor: AppColors.primary, foregroundColor: AppColors.onPrimary),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _field(_name, 'Nome do prato', validator: _required),
            _field(_description, 'Descrição', validator: _required, maxLines: 3),
            _field(_price, 'Preço (R\$)', validator: _numeric, numeric: true),
            const SizedBox(height: 8),
            Text('Informações por porção', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const Icon(Icons.local_fire_department_outlined),
                title: const Text('Calorias calculadas automaticamente'),
                subtitle: const Text('Proteínas e carboidratos: 4 kcal/g • Gorduras: 9 kcal/g'),
                trailing: Text(
                  '$_calculatedCalories kcal',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 14),
            _field(_protein, 'Proteínas (g)', validator: _numeric, numeric: true),
            _field(_carbohydrate, 'Carboidratos (g)', validator: _numeric, numeric: true),
            _field(_fat, 'Gorduras (g)', validator: _numeric, numeric: true),
            _field(_fiber, 'Fibras (g)', validator: _numeric, numeric: true),
            SwitchListTile(title: const Text('Prato vegano'), value: _isVegan, onChanged: (value) => setState(() => _isVegan = value)),
            SwitchListTile(title: const Text('Sem lactose'), value: _isLactoseFree, onChanged: (value) => setState(() => _isLactoseFree = value)),
            const SizedBox(height: 18),
            FilledButton.icon(onPressed: _save, icon: const Icon(Icons.save), label: Text(editing ? 'Salvar alterações' : 'Cadastrar prato')),
          ],
        ),
      ),
    );
  }

  Widget _field(TextEditingController controller, String label, {required FormFieldValidator<String> validator, bool numeric = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(controller: controller, decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()), keyboardType: numeric ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text, maxLines: maxLines, validator: validator),
    );
  }
}
