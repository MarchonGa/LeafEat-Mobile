import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:leafeat_mobile/app/session/app_session.dart';
import 'package:leafeat_mobile/core/input/date_input_formatter.dart';
import 'package:leafeat_mobile/core/theme/app_colors.dart';
import 'package:leafeat_mobile/core/network/api_exception.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _basicKey = GlobalKey<FormState>();
  final _detailsKey = GlobalKey<FormState>();
  final _securityKey = GlobalKey<FormState>();
  final _password = TextEditingController();
  final _confirmation = TextEditingController();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _birthDate = TextEditingController();
  final _cnpj = TextEditingController();
  final _zipCode = TextEditingController();
  final _addressNumber = TextEditingController();
  final _neighborhood = TextEditingController();
  final _category = TextEditingController();
  final _description = TextEditingController();
  final _otherRestrictions = TextEditingController();
  final _caloriesGoal = TextEditingController();
  final _proteinGoal = TextEditingController();
  final _carbohydrateGoal = TextEditingController();
  final _fatGoal = TextEditingController();
  final _fiberGoal = TextEditingController();
  UserMode _accountType = UserMode.customer;
  int _step = 0;
  bool _hidePassword = true;
  bool _acceptedTerms = false;
  bool _lactoseIntolerant = false;
  bool _vegan = false;
  bool _defineNutritionGoals = false;
  final Set<String> _allergies = {};
  bool _submitting = false;

  static const _commonAllergies = ['Camarão', 'Amendoim', 'Castanhas', 'Glúten', 'Leite', 'Ovo'];

  @override
  void dispose() {
    _password.dispose();
    _confirmation.dispose();
    _name.dispose();
    _email.dispose();
    _birthDate.dispose();
    _cnpj.dispose();
    _zipCode.dispose();
    _addressNumber.dispose();
    _neighborhood.dispose();
    _category.dispose();
    _description.dispose();
    _otherRestrictions.dispose();
    _caloriesGoal.dispose();
    _proteinGoal.dispose();
    _carbohydrateGoal.dispose();
    _fatGoal.dispose();
    _fiberGoal.dispose();
    super.dispose();
  }

  bool _validateStep() {
    final keys = [_basicKey, _detailsKey, _securityKey];
    return keys[_step].currentState?.validate() ?? false;
  }

  Future<void> _continue() async {
    if (!_validateStep()) return;
    if (_step < 2) {
      setState(() => _step++);
      return;
    }
    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Aceite os termos para continuar.')));
      return;
    }
    setState(() => _submitting = true);
    final session = AppSessionScope.read(context);
    try {
      final result = _accountType == UserMode.restaurant
          ? await session.authRepository.registerRestaurant({
              'businessName': _name.text.trim(),
              'email': _email.text.trim(),
              'cnpj': _cnpj.text,
              'password': _password.text,
              'confirmPassword': _confirmation.text,
              'zipCode': _zipCode.text,
              'addressNumber': _addressNumber.text.trim(),
              'neighborhood': _neighborhood.text.trim(),
              'category': _category.text.trim(),
              'description': _description.text.trim(),
            })
          : await session.authRepository.registerCustomer({
              'name': _name.text.trim(),
              'email': _email.text.trim(),
              'password': _password.text,
              'confirmPassword': _confirmation.text,
              'dietaryRestrictions': _customerRestrictions,
              'nutritionGoals': _nutritionGoals,
            });
      await session.authenticate(result);
      if (mounted) Navigator.of(context).pop();
    } on ApiException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message)));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  List<String> get _customerRestrictions {
    final restrictions = <String>{..._allergies};
    if (_lactoseIntolerant) restrictions.add('Intolerância à lactose');
    if (_vegan) restrictions.add('Alimentação vegana');
    restrictions.addAll(
      _otherRestrictions.text.split(',').map((item) => item.trim()).where((item) => item.isNotEmpty),
    );
    return restrictions.toList();
  }

  Map<String, dynamic>? get _nutritionGoals {
    if (!_defineNutritionGoals) return null;
    double? valueOf(TextEditingController controller) => double.tryParse(
          controller.text.trim().replaceAll(',', '.'),
        );
    return {
      'calories': valueOf(_caloriesGoal)?.round(),
      'proteinGrams': valueOf(_proteinGoal),
      'carbohydrateGrams': valueOf(_carbohydrateGoal),
      'fatGrams': valueOf(_fatGoal),
      'fiberGrams': valueOf(_fiberGoal),
    };
  }

  String? _required(String? value) => value == null || value.trim().isEmpty ? 'Campo obrigatório.' : null;
  String? _positiveGoal(String? value) {
    if (!_defineNutritionGoals) return null;
    final number = double.tryParse((value ?? '').trim().replaceAll(',', '.'));
    return number == null || number <= 0 ? 'Informe um valor maior que zero.' : null;
  }

  String? _optionalPositiveGoal(String? value) {
    if (!_defineNutritionGoals || (value ?? '').trim().isEmpty) return null;
    return _positiveGoal(value);
  }
  String? _birthDateRule(String? value) {
    if (value == null || value.trim().isEmpty) return 'Campo obrigatório.';
    return _parseBirthDate(value) == null ? 'Informe uma data válida.' : null;
  }

  DateTime? _parseBirthDate(String value) {
    final parts = value.split('/');
    if (parts.length != 3) return null;
    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null || year < 1900) return null;
    final date = DateTime(year, month, day);
    if (date.day != day || date.month != month || date.year != year) return null;
    if (date.isAfter(DateTime.now())) return null;
    return date;
  }

  Future<void> _selectBirthDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _parseBirthDate(_birthDate.text) ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      helpText: 'Selecione a data de nascimento',
      cancelText: 'Cancelar',
      confirmText: 'Confirmar',
    );
    if (selected == null || !mounted) return;
    setState(() {
      _birthDate.text =
          '${selected.day.toString().padLeft(2, '0')}/'
          '${selected.month.toString().padLeft(2, '0')}/'
          '${selected.year}';
    });
  }
  String? _emailRule(String? value) => value == null || !RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(value.trim()) ? 'Informe um e-mail válido.' : null;
  String? _passwordRule(String? value) {
    if (value == null || value.length < 8) return 'Use pelo menos 8 caracteres.';
    if (!RegExp(r'[A-Z]').hasMatch(value)) return 'Inclua uma letra maiúscula.';
    if (!RegExp(r'[a-z]').hasMatch(value)) return 'Inclua uma letra minúscula.';
    if (!RegExp(r'[0-9]').hasMatch(value)) return 'Inclua um número.';
    if (!RegExp(r'[^A-Za-z0-9]').hasMatch(value)) return 'Inclua um caractere especial.';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final restaurant = _accountType == UserMode.restaurant;
    return Scaffold(
      appBar: AppBar(title: const Text('Criar conta'), backgroundColor: AppColors.primary, foregroundColor: AppColors.onPrimary),
      body: Stepper(
        currentStep: _step,
        onStepTapped: (step) {
          if (step <= _step) setState(() => _step = step);
        },
        onStepContinue: _continue,
        onStepCancel: _step == 0 ? null : () => setState(() => _step--),
        controlsBuilder: (context, details) => Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Row(children: [
            Expanded(child: FilledButton(onPressed: _submitting ? null : details.onStepContinue, child: Text(_submitting ? 'Criando...' : (_step == 2 ? 'Criar conta' : 'Continuar')))),
            if (_step > 0) ...[const SizedBox(width: 10), Expanded(child: OutlinedButton(onPressed: details.onStepCancel, child: const Text('Voltar')))],
          ]),
        ),
        steps: [
          Step(title: const Text('Dados básicos'), isActive: _step >= 0, state: _step > 0 ? StepState.complete : StepState.indexed, content: Form(key: _basicKey, child: Column(children: [
            SegmentedButton<UserMode>(segments: const [ButtonSegment(value: UserMode.customer, label: Text('Cliente'), icon: Icon(Icons.person)), ButtonSegment(value: UserMode.restaurant, label: Text('Restaurante'), icon: Icon(Icons.store))], selected: {_accountType}, onSelectionChanged: (selection) => setState(() => _accountType = selection.first)),
            const SizedBox(height: 16),
            _field(restaurant ? 'Nome fantasia' : 'Nome completo', controller: _name, validator: _required),
            if (restaurant) _field('Razão social', validator: _required),
            if (restaurant) _field('CNPJ', controller: _cnpj, hint: '00.000.000/0000-00', keyboard: TextInputType.number, validator: (value) => value == null || value.replaceAll(RegExp(r'\D'), '').length != 14 ? 'Informe os 14 números do CNPJ.' : null),
            _field('E-mail', controller: _email, keyboard: TextInputType.emailAddress, validator: _emailRule),
            _field('Telefone', hint: '(00) 00000-0000', keyboard: TextInputType.phone, validator: _required),
            if (!restaurant)
              _field(
                'Data de nascimento',
                controller: _birthDate,
                hint: 'dd/mm/aaaa',
                keyboard: TextInputType.datetime,
                validator: _birthDateRule,
                inputFormatters: [DateInputFormatter()],
                suffixIcon: IconButton(
                  tooltip: 'Selecionar no calendário',
                  onPressed: _selectBirthDate,
                  icon: const Icon(Icons.calendar_month_outlined),
                ),
              ),
          ]))),
          Step(title: Text(restaurant ? 'Endereço' : 'Preferências'), isActive: _step >= 1, state: _step > 1 ? StepState.complete : StepState.indexed, content: Form(key: _detailsKey, child: restaurant ? _restaurantAddress() : _customerPreferences())),
          Step(title: const Text('Segurança'), isActive: _step >= 2, content: Form(key: _securityKey, child: Column(children: [
            _passwordField(controller: _password, label: 'Senha', validator: _passwordRule),
            _passwordField(controller: _confirmation, label: 'Confirmar senha', validator: (value) => value != _password.text ? 'As senhas não coincidem.' : _passwordRule(value)),
            const Align(alignment: Alignment.centerLeft, child: Text('A senha deve ter 8 caracteres, maiúscula, minúscula, número e caractere especial.', style: TextStyle(fontSize: 12))),
            const SizedBox(height: 12),
            CheckboxListTile(contentPadding: EdgeInsets.zero, controlAffinity: ListTileControlAffinity.leading, title: const Text('Li e aceito os termos de uso e a política de privacidade'), value: _acceptedTerms, onChanged: (value) => setState(() => _acceptedTerms = value!)),
            const Card(child: ListTile(leading: Icon(Icons.info_outline), title: Text('Cadastro conectado'), subtitle: Text('A conta será armazenada no banco local do LeafEat.'))),
          ]))),
        ],
      ),
    );
  }

  Widget _customerPreferences() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Essas informações serão usadas como pré-filtros nas buscas.'),
      SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Intolerância à lactose'), value: _lactoseIntolerant, onChanged: (value) => setState(() => _lactoseIntolerant = value)),
      SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Alimentação vegana'), value: _vegan, onChanged: (value) => setState(() => _vegan = value)),
      const SizedBox(height: 8),
      Text('Alergias alimentares', style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 8),
      Wrap(spacing: 8, runSpacing: 8, children: _commonAllergies.map((allergy) => FilterChip(label: Text(allergy), selected: _allergies.contains(allergy), onSelected: (selected) => setState(() { if (selected) { _allergies.add(allergy); } else { _allergies.remove(allergy); } }))).toList()),
      const SizedBox(height: 14),
      _field('Outras alergias ou restrições', controller: _otherRestrictions, hint: 'Ex.: peixe, soja, frutos do mar', validator: (_) => null, maxLines: 2),
      const Divider(height: 32),
      Text('Metas nutricionais', style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 6),
      const Text('As metas são opcionais e podem ser alteradas depois na tela de macros.'),
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: const Text('Quero definir minhas metas agora'),
        subtitle: Text(_defineNutritionGoals
            ? 'Preencha os valores abaixo.'
            : 'Desativado: prefiro não informar agora.'),
        value: _defineNutritionGoals,
        onChanged: (value) => setState(() => _defineNutritionGoals = value),
      ),
      if (_defineNutritionGoals) ...[
        _goalField('Calorias diárias', _caloriesGoal, 'kcal', _positiveGoal),
        _goalField('Proteínas diárias', _proteinGoal, 'g', _positiveGoal),
        _goalField('Carboidratos diários', _carbohydrateGoal, 'g', _positiveGoal),
        _goalField('Gorduras diárias', _fatGoal, 'g', _positiveGoal),
        _goalField('Fibras diárias (opcional)', _fiberGoal, 'g', _optionalPositiveGoal),
      ],
    ]);
  }

  Widget _goalField(String label, TextEditingController controller,
      String suffix, FormFieldValidator<String> validator) {
    return _field(
      label,
      controller: controller,
      keyboard: const TextInputType.numberWithOptions(decimal: true),
      validator: validator,
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]'))],
      suffixText: suffix,
    );
  }

  Widget _restaurantAddress() {
    return Column(children: [
      _field('CEP', controller: _zipCode, hint: '00000-000', keyboard: TextInputType.number, validator: (value) => value == null || value.replaceAll(RegExp(r'\D'), '').length != 8 ? 'Informe os 8 números do CEP.' : null),
      _field('Rua ou avenida', validator: _required),
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(flex: 2, child: _field('Número', controller: _addressNumber, keyboard: TextInputType.number, validator: _required)), const SizedBox(width: 10), Expanded(flex: 3, child: _field('Complemento', validator: (_) => null))]),
      _field('Bairro', controller: _neighborhood, validator: _required),
      _field('Cidade', validator: _required),
      _field('Estado', hint: 'CE', validator: (value) => value == null || value.trim().length != 2 ? 'Use a sigla com 2 letras.' : null),
      _field('Categoria', controller: _category, hint: 'Ex.: saudável, regional', validator: _required),
      _field('Descrição do estabelecimento', controller: _description, validator: _required, maxLines: 3),
    ]);
  }

  Widget _field(String label, {TextEditingController? controller, String? hint, required FormFieldValidator<String> validator, TextInputType keyboard = TextInputType.text, int maxLines = 1, List<TextInputFormatter>? inputFormatters, Widget? suffixIcon, String? suffixText}) {
    return Padding(padding: const EdgeInsets.only(bottom: 14), child: TextFormField(controller: controller, keyboardType: keyboard, maxLines: maxLines, inputFormatters: inputFormatters, decoration: InputDecoration(labelText: label, hintText: hint, border: const OutlineInputBorder(), suffixIcon: suffixIcon, suffixText: suffixText), validator: validator));
  }

  Widget _passwordField({required TextEditingController controller, required String label, required FormFieldValidator<String> validator}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(controller: controller, obscureText: _hidePassword, decoration: InputDecoration(labelText: label, prefixIcon: const Icon(Icons.lock_outline), border: const OutlineInputBorder(), suffixIcon: IconButton(onPressed: () => setState(() => _hidePassword = !_hidePassword), icon: Icon(_hidePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined))), validator: validator),
    );
  }
}
