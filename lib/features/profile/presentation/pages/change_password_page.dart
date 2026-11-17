import 'package:flutter/material.dart';
import 'package:leafeat_mobile/app/session/app_session.dart';
import 'package:leafeat_mobile/core/theme/app_colors.dart';
import 'package:leafeat_mobile/features/profile/data/profile_repository.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _password = TextEditingController();
  final _confirmation = TextEditingController();
  bool _saving = false;
  bool _obscure = true;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final session = AppSessionScope.read(context);
    if (session.token == null) return;
    setState(() => _saving = true);
    try {
      await ProfileRepository(session.apiClient, session.token!).changePassword(
        currentPassword: _current.text,
        newPassword: _password.text,
        confirmPassword: _confirmation.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Senha alterada com sucesso.')),
      );
      Navigator.of(context).pop();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String? _passwordValidator(String? value) {
    final password = value ?? '';
    final valid = password.length >= 8 &&
        RegExp('[A-Z]').hasMatch(password) &&
        RegExp('[a-z]').hasMatch(password) &&
        RegExp('[0-9]').hasMatch(password) &&
        RegExp(r'[^A-Za-z0-9]').hasMatch(password);
    return valid
        ? null
        : 'Use 8 caracteres, maiúscula, minúscula, número e símbolo.';
  }

  @override
  void dispose() {
    _current.dispose();
    _password.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Alterar senha'),
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _field(_current, 'Senha atual'),
              _field(_password, 'Nova senha', validator: _passwordValidator),
              _field(
                _confirmation,
                'Confirmar nova senha',
                validator: (value) => value == _password.text
                    ? null
                    : 'As senhas não coincidem.',
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: _saving ? null : _save,
                icon: const Icon(Icons.lock_reset),
                label: Text(_saving ? 'Salvando...' : 'Alterar senha'),
              ),
            ],
          ),
        ),
      );

  Widget _field(
    TextEditingController controller,
    String label, {
    FormFieldValidator<String>? validator,
  }) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: TextFormField(
          controller: controller,
          obscureText: _obscure,
          validator: validator ??
              (value) => (value ?? '').isEmpty ? 'Campo obrigatório.' : null,
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              tooltip: _obscure ? 'Mostrar senhas' : 'Ocultar senhas',
              onPressed: () => setState(() => _obscure = !_obscure),
              icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
            ),
          ),
        ),
      );
}
