import 'package:flutter/material.dart';
import 'package:leafeat_mobile/app/session/app_session.dart';
import 'package:leafeat_mobile/core/theme/app_colors.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  UserMode _accountType = UserMode.customer;

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    AppSessionScope.read(context).switchMode(_accountType);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isRestaurant = _accountType == UserMode.restaurant;
    return Scaffold(
      appBar: AppBar(title: const Text('Criar conta'), backgroundColor: AppColors.primary, foregroundColor: AppColors.onPrimary),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text('Qual conta você deseja criar?', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            SegmentedButton<UserMode>(
              segments: const [
                ButtonSegment(value: UserMode.customer, label: Text('Cliente'), icon: Icon(Icons.person)),
                ButtonSegment(value: UserMode.restaurant, label: Text('Restaurante'), icon: Icon(Icons.store)),
              ],
              selected: {_accountType},
              onSelectionChanged: (selection) => setState(() => _accountType = selection.first),
            ),
            const SizedBox(height: 20),
            TextFormField(
              decoration: InputDecoration(labelText: isRestaurant ? 'Nome do estabelecimento' : 'Nome completo', border: const OutlineInputBorder()),
              validator: (value) => value == null || value.trim().isEmpty ? 'Preencha este campo.' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'E-mail', border: OutlineInputBorder()),
              validator: (value) => value == null || !value.contains('@') ? 'Informe um e-mail válido.' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Senha', border: OutlineInputBorder()),
              validator: (value) => value == null || value.length < 4 ? 'Informe pelo menos 4 caracteres.' : null,
            ),
            const SizedBox(height: 24),
            FilledButton(onPressed: _submit, child: const Text('Criar conta demonstrativa')),
          ],
        ),
      ),
    );
  }
}
