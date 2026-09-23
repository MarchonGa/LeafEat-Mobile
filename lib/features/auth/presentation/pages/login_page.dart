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
  bool _hidePassword = true;

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
            const SizedBox(height: 16),
            Text('Bem-vindo de volta', textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 6),
            const Text('Acesse suas preferências ou gerencie seu estabelecimento.', textAlign: TextAlign.center),
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
              autofillHints: const [AutofillHints.email],
              decoration: const InputDecoration(labelText: 'E-mail', prefixIcon: Icon(Icons.email_outlined), border: OutlineInputBorder()),
              validator: (value) => value == null || !RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(value.trim()) ? 'Informe um e-mail válido.' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              obscureText: _hidePassword,
              autofillHints: const [AutofillHints.password],
              decoration: InputDecoration(
                labelText: 'Senha',
                prefixIcon: const Icon(Icons.lock_outline),
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(tooltip: _hidePassword ? 'Mostrar senha' : 'Ocultar senha', onPressed: () => setState(() => _hidePassword = !_hidePassword), icon: Icon(_hidePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined)),
              ),
              validator: (value) => value == null || value.isEmpty ? 'Informe sua senha.' : null,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => showDialog<void>(context: context, builder: (context) => AlertDialog(title: const Text('Recuperar senha'), content: const Text('A recuperação por e-mail será conectada ao backend posteriormente.'), actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Entendi'))])),
                child: const Text('Esqueci minha senha'),
              ),
            ),
            const SizedBox(height: 8),
            FilledButton.icon(onPressed: _submit, icon: const Icon(Icons.login), label: const Text('Entrar')),
            const SizedBox(height: 12),
            const Text('Acesso demonstrativo: os dados não são enviados ou armazenados.', textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
