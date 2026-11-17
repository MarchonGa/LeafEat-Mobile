import 'package:flutter/material.dart';
import 'package:leafeat_mobile/app/session/app_session.dart';
import 'package:leafeat_mobile/core/theme/app_colors.dart';
import 'package:leafeat_mobile/features/profile/data/account_profile.dart';
import 'package:leafeat_mobile/features/profile/data/profile_repository.dart';

class PublicProfileSettingsPage extends StatefulWidget {
  const PublicProfileSettingsPage({super.key});

  @override
  State<PublicProfileSettingsPage> createState() =>
      _PublicProfileSettingsPageState();
}

class _PublicProfileSettingsPageState
    extends State<PublicProfileSettingsPage> {
  final _alias = TextEditingController();
  final Set<String> _publicPreferences = {};
  AccountProfile? _profile;
  String _mode = 'FirstName';
  bool _showPreferences = false;
  bool _loading = true;
  bool _saving = false;
  String? _error;

  ProfileRepository get _repository {
    final session = AppSessionScope.read(context);
    return ProfileRepository(session.apiClient, session.token!);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_profile == null && _loading) _load();
  }

  Future<void> _load() async {
    try {
      final profile = await _repository.profile();
      if (!mounted) return;
      setState(() {
        _profile = profile;
        _mode = profile.publicNameMode;
        _alias.text = profile.publicAlias ?? '';
        _showPreferences = profile.showDietaryPreferences;
        _publicPreferences
          ..clear()
          ..addAll(profile.publicDietaryPreferences);
        _loading = false;
      });
    } catch (error) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = error.toString();
        });
      }
    }
  }

  String get _previewName {
    final name = _profile?.name.trim() ?? '';
    if (name.isEmpty) return 'Cliente LeafEat';
    switch (_mode) {
      case 'Masked':
        return '${name.characters.first}******';
      case 'Alias':
        return _alias.text.trim().isEmpty
            ? 'Seu apelido'
            : _alias.text.trim();
      case 'Anonymous':
        return 'Cliente LeafEat';
      default:
        return name.split(RegExp(r'\s+')).first;
    }
  }

  Future<void> _save() async {
    final profile = _profile;
    if (profile == null) return;
    if (_mode == 'Alias' && _alias.text.trim().isEmpty) {
      setState(() => _error = 'Informe o apelido público.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await _repository.updateCustomer({
        'name': profile.name,
        'email': profile.email,
        'publicNameMode': _mode,
        'publicAlias': _alias.text.trim(),
        'showDietaryPreferences': _showPreferences,
        'publicDietaryPreferences': _publicPreferences.toList(),
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil público atualizado.')),
      );
      Navigator.of(context).pop();
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _alias.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Perfil público'),
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  if (_error != null)
                    Card(
                      color: Theme.of(context).colorScheme.errorContainer,
                      child: ListTile(
                        leading: const Icon(Icons.error_outline),
                        title: Text(_error!),
                      ),
                    ),
                  Text(
                    'Como você aparecerá',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _mode,
                    decoration: const InputDecoration(
                      labelText: 'Identificação nas avaliações',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'FirstName',
                        child: Text('Somente o primeiro nome'),
                      ),
                      DropdownMenuItem(
                        value: 'Masked',
                        child: Text('Nome oculto (G******)'),
                      ),
                      DropdownMenuItem(
                        value: 'Alias',
                        child: Text('Apelido'),
                      ),
                      DropdownMenuItem(
                        value: 'Anonymous',
                        child: Text('Anônimo'),
                      ),
                    ],
                    onChanged: _saving
                        ? null
                        : (value) => setState(
                              () => _mode = value ?? 'FirstName',
                            ),
                  ),
                  if (_mode == 'Alias') ...[
                    const SizedBox(height: 14),
                    TextField(
                      controller: _alias,
                      onChanged: (_) => setState(() {}),
                      decoration: const InputDecoration(
                        labelText: 'Apelido público',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Card(
                    child: ListTile(
                      leading: const CircleAvatar(
                        child: Icon(Icons.person_outline),
                      ),
                      title: Text(_previewName),
                      subtitle: Text(
                        _showPreferences && _publicPreferences.isNotEmpty
                            ? _publicPreferences.join(' • ')
                            : 'Nenhuma preferência pública',
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Preferências públicas',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                      'Mostrar preferências alimentares',
                    ),
                    subtitle: const Text(
                      'Nada será publicado sem sua autorização.',
                    ),
                    value: _showPreferences,
                    onChanged: _saving
                        ? null
                        : (value) => setState(
                              () => _showPreferences = value,
                            ),
                  ),
                  if (_showPreferences)
                    if ((_profile?.dietaryRestrictions ?? []).isEmpty)
                      const Card(
                        child: ListTile(
                          leading: Icon(Icons.info_outline),
                          title: Text('Nenhuma restrição cadastrada'),
                          subtitle: Text(
                            'Cadastre-as em Preferências alimentares.',
                          ),
                        ),
                      )
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final preference
                              in _profile!.dietaryRestrictions)
                            FilterChip(
                              label: Text(preference),
                              selected:
                                  _publicPreferences.contains(preference),
                              onSelected: _saving
                                  ? null
                                  : (selected) => setState(() {
                                        if (selected) {
                                          _publicPreferences.add(preference);
                                        } else {
                                          _publicPreferences
                                              .remove(preference);
                                        }
                                      }),
                            ),
                        ],
                      ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: _saving ? null : _save,
                    icon: const Icon(Icons.save_outlined),
                    label: Text(_saving ? 'Salvando...' : 'Salvar'),
                  ),
                ],
              ),
      );
}
