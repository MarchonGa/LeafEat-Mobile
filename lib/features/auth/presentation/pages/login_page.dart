import 'package:flutter/material.dart';
import 'package:leafeat_mobile/app/session/app_session.dart';
import 'package:leafeat_mobile/core/theme/app_colors.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  UserMode _accountType = UserMode.customer;

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    AppSessionScope.read(context).switchMode(_accountType);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Entrar'), backgroundColor: AppColors.primary, foregroundColor: AppColors.onPrimary),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Icon(Icons.eco, size: 72, color: AppColors.primary),
            const SizedBox(height: 20),
            Text('Acesse sua conta', textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 24),
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
            FilledButton(onPressed: _submit, child: const Text('Entrar')),
            const SizedBox(height: 10),
            const Text('Acesso demonstrativo: os dados não são enviados ou armazenados.', textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
