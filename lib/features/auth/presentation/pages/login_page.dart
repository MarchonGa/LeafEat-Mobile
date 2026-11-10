import 'package:flutter/material.dart';
import 'package:leafeat_mobile/app/session/app_session.dart';
import 'package:leafeat_mobile/core/theme/app_colors.dart';
import 'package:leafeat_mobile/core/network/api_exception.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  UserMode _accountType = UserMode.customer;
  bool _hidePassword = true;
  bool _submitting = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    final session = AppSessionScope.read(context);
    try {
      final result = await session.authRepository.login(
        email: _email.text,
        password: _password.text,
      );
      if (result.user.role != _accountType) {
        throw ApiException(
          _accountType == UserMode.restaurant
              ? 'Esta conta não pertence a um restaurante.'
              : 'Esta conta pertence a um restaurante.',
        );
      }
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
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              decoration: const InputDecoration(labelText: 'E-mail', prefixIcon: Icon(Icons.email_outlined), border: OutlineInputBorder()),
              validator: (value) => value == null || !RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(value.trim()) ? 'Informe um e-mail válido.' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _password,
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
            FilledButton.icon(
              onPressed: _submitting ? null : _submit,
              icon: _submitting
                  ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.login),
              label: Text(_submitting ? 'Entrando...' : 'Entrar'),
            ),
            const SizedBox(height: 12),
            const Text('A sessão será conectada à API local do LeafEat.', textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
