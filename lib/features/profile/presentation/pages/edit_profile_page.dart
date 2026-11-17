import 'package:flutter/material.dart';
import 'package:leafeat_mobile/app/session/app_session.dart';
import 'package:leafeat_mobile/core/theme/app_colors.dart';
import 'package:leafeat_mobile/features/profile/data/account_profile.dart';
import 'package:leafeat_mobile/features/profile/data/profile_repository.dart';
import 'package:leafeat_mobile/features/profile/presentation/pages/change_password_page.dart';
import 'package:leafeat_mobile/features/profile/presentation/pages/public_profile_settings_page.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _cnpj = TextEditingController();
  final _zipCode = TextEditingController();
  final _addressNumber = TextEditingController();
  final _neighborhood = TextEditingController();
  final _category = TextEditingController();
  final _description = TextEditingController();

  AccountProfile? _profile;
  bool _initialized = false;
  bool _loading = true;
  bool _saving = false;
  String? _error;

  bool get _isRestaurant =>
      AppSessionScope.read(context).mode == UserMode.restaurant;

  ProfileRepository? _repository() {
    final session = AppSessionScope.read(context);
    return session.token == null
        ? null
        : ProfileRepository(session.apiClient, session.token!);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    _load();
  }

  Future<void> _load() async {
    final repository = _repository();
    if (repository == null) {
      setState(() {
        _loading = false;
        _error = 'Faça login para editar o perfil.';
      });
      return;
    }
    try {
      final profile = await repository.profile();
      if (!mounted) return;
      _apply(profile);
      setState(() {
        _loading = false;
        _error = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error.toString();
      });
    }
  }

  void _apply(AccountProfile profile) {
    _profile = profile;
    _name.text = profile.name;
    _email.text = profile.email;
    _cnpj.text = profile.cnpj ?? '';
    _zipCode.text = profile.zipCode ?? '';
    _addressNumber.text = profile.addressNumber ?? '';
    _neighborhood.text = profile.neighborhood ?? '';
    _category.text = profile.category ?? '';
    _description.text = profile.description ?? '';
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final repository = _repository();
    if (repository == null) return;

    setState(() => _saving = true);
    try {
      final profile = _isRestaurant
          ? await repository.updateRestaurant({
              'businessName': _name.text.trim(),
              'email': _email.text.trim(),
              'cnpj': _cnpj.text.trim(),
              'zipCode': _zipCode.text.trim(),
              'addressNumber': _addressNumber.text.trim(),
              'neighborhood': _neighborhood.text.trim(),
              'category': _category.text.trim(),
              'description': _description.text.trim(),
            })
          : await repository.updateCustomer({
              'name': _name.text.trim(),
              'email': _email.text.trim(),
              'publicNameMode': _profile?.publicNameMode ?? 'FirstName',
              'publicAlias': _profile?.publicAlias,
              'showDietaryPreferences':
                  _profile?.showDietaryPreferences ?? false,
              'publicDietaryPreferences':
                  _profile?.publicDietaryPreferences ?? const [],
            });
      if (!mounted) return;
      final session = AppSessionScope.read(context);
      final currentUser = session.user;
      if (currentUser != null) {
        await session.updateUser(currentUser.copyWith(
          name: profile.name,
          email: profile.email,
          dietaryRestrictions: profile.dietaryRestrictions,
        ));
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil atualizado com sucesso.')),
      );
      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'Campo obrigatório.' : null;

  String? _emailValidator(String? value) {
    if (_required(value) != null) return 'Campo obrigatório.';
    if (!value!.contains('@') || !value.contains('.')) {
      return 'Informe um e-mail válido.';
    }
    return null;
  }

  String? _digits(String? value, int length, String label) {
    if (_required(value) != null) return 'Campo obrigatório.';
    final digits = value!.replaceAll(RegExp(r'\D'), '');
    return digits.length == length
        ? null
        : '$label deve conter $length números.';
  }

  @override
  void dispose() {
    for (final controller in [
      _name,
      _email,
      _cnpj,
      _zipCode,
      _addressNumber,
      _neighborhood,
      _category,
      _description,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final restaurant = _isRestaurant;
    return Scaffold(
      appBar: AppBar(
        title: Text(restaurant ? 'Editar restaurante' : 'Editar perfil'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  if (_error != null)
                    Card(
                      color: Theme.of(context).colorScheme.errorContainer,
                      child: ListTile(
                        leading: const Icon(Icons.error_outline),
                        title: Text(_error!),
                        trailing: IconButton(
                          tooltip: 'Tentar novamente',
                          onPressed: _load,
                          icon: const Icon(Icons.refresh),
                        ),
                      ),
                    ),
                  _field(
                    _name,
                    restaurant ? 'Nome do estabelecimento' : 'Nome',
                    validator: _required,
                  ),
                  _field(
                    _email,
                    'E-mail',
                    validator: _emailValidator,
                    keyboardType: TextInputType.emailAddress,
                    helperText: 'Privado — não aparece no perfil público.',
                  ),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.lock_outline),
                      title: const Text('Alterar senha'),
                      subtitle: const Text(
                        'Confirme a senha atual antes de definir uma nova.',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const ChangePasswordPage(),
                        ),
                      ),
                    ),
                  ),
                  if (!restaurant)
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.public),
                        title: const Text('Perfil público e privacidade'),
                        subtitle: const Text(
                          'Escolha nome, apelido, anonimato e preferências públicas.',
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) =>
                                const PublicProfileSettingsPage(),
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 14),
                  if (restaurant) ...[
                    _field(
                      _cnpj,
                      'CNPJ',
                      validator: (value) => _digits(value, 14, 'O CNPJ'),
                      keyboardType: TextInputType.number,
                    ),
                    _field(
                      _zipCode,
                      'CEP',
                      validator: (value) => _digits(value, 8, 'O CEP'),
                      keyboardType: TextInputType.number,
                    ),
                    _field(
                      _addressNumber,
                      'Número',
                      validator: _required,
                    ),
                    _field(
                      _neighborhood,
                      'Bairro',
                      validator: _required,
                    ),
                    _field(
                      _category,
                      'Categoria',
                      validator: _required,
                    ),
                    _field(
                      _description,
                      'Descrição pública',
                      validator: _required,
                      maxLines: 4,
                    ),
                  ],
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: _saving ? null : _save,
                    icon: _saving
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save_outlined),
                    label: Text(_saving ? 'Salvando...' : 'Salvar alterações'),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    FormFieldValidator<String>? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? helperText,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          helperText: helperText,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
