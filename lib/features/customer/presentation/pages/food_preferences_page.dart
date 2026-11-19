import 'package:flutter/material.dart';
import 'package:leafeat_mobile/app/session/app_session.dart';
import 'package:leafeat_mobile/core/theme/app_colors.dart';
import 'package:leafeat_mobile/features/customer/data/customer_repository.dart';
import 'package:leafeat_mobile/features/customer/data/food_preferences.dart';

class FoodPreferencesPage extends StatefulWidget {
  const FoodPreferencesPage({super.key});

  @override
  State<FoodPreferencesPage> createState() => _FoodPreferencesPageState();
}

class _FoodPreferencesPageState extends State<FoodPreferencesPage> {
  static const _suggestions = [
    'Camarão',
    'Amendoim',
    'Glúten',
    'Alimentos vermelhos',
    'Alimentos amarelos',
  ];

  final _otherRestrictions = TextEditingController();
  final Set<String> _selectedRestrictions = {};
  bool _vegan = false;
  bool _lactoseFree = false;
  bool _metricMenus = false;
  bool _initialized = false;
  bool _loading = true;
  bool _saving = false;
  String? _error;

  CustomerRepository? _repository() {
    final session = AppSessionScope.read(context);
    return session.token == null
        ? null
        : CustomerRepository(session.apiClient, session.token!);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    final cached = AppSessionScope.read(context).foodPreferences;
    if (cached != null) _apply(cached);
    _load();
  }

  void _apply(FoodPreferences preferences) {
    _vegan = preferences.vegan;
    _lactoseFree = preferences.lactoseFree;
    _metricMenus = preferences.metricMenus;
    _selectedRestrictions
      ..clear()
      ..addAll(preferences.dietaryRestrictions.where(_suggestions.contains));
    _otherRestrictions.text = preferences.dietaryRestrictions
        .where((item) => !_suggestions.contains(item))
        .join(', ');
  }

  List<String> _restrictions() {
    final custom = _otherRestrictions.text
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty);
    return {..._selectedRestrictions, ...custom}.toList()..sort();
  }

  Future<void> _load() async {
    final repository = _repository();
    if (repository == null) {
      setState(() {
        _loading = false;
        _error = 'Faça login como cliente para editar suas preferências.';
      });
      return;
    }
    try {
      final preferences = await repository.foodPreferences();
      if (!mounted) return;
      AppSessionScope.read(context).setFoodPreferences(preferences);
      setState(() {
        _apply(preferences);
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

  Future<void> _save() async {
    final repository = _repository();
    if (repository == null) return;
    setState(() => _saving = true);
    try {
      final saved = await repository.updateFoodPreferences(FoodPreferences(
        vegan: _vegan,
        lactoseFree: _lactoseFree,
        metricMenus: _metricMenus,
        dietaryRestrictions: _restrictions(),
      ));
      if (!mounted) return;
      final session = AppSessionScope.read(context);
      session.setFoodPreferences(saved);
      final user = session.user;
      if (user != null) {
        await session.updateUser(user.copyWith(
          dietaryRestrictions: saved.dietaryRestrictions,
        ));
      }
      if (!mounted) return;
      setState(() {
        _apply(saved);
        _error = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preferências e restrições atualizadas.'),
        ),
      );
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

  @override
  void dispose() {
    _otherRestrictions.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preferências alimentares'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
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
                Text(
                  'Preferências de busca',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 6),
                const Text(
                  'Estas opções personalizam os resultados da tela Explorar.',
                ),
                SwitchListTile(
                  title: const Text('Alimentação vegana'),
                  value: _vegan,
                  onChanged: _saving
                      ? null
                      : (value) => setState(() => _vegan = value),
                ),
                SwitchListTile(
                  title: const Text('Sem lactose'),
                  value: _lactoseFree,
                  onChanged: _saving
                      ? null
                      : (value) => setState(() => _lactoseFree = value),
                ),
                SwitchListTile(
                  title: const Text('Cardápio com informações nutricionais'),
                  value: _metricMenus,
                  onChanged: _saving
                      ? null
                      : (value) => setState(() => _metricMenus = value),
                ),
                const Divider(height: 32),
                Text(
                  'Alergias e restrições',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 6),
                const Text(
                  'Selecione quantas opções precisar e acrescente outras '
                  'restrições no campo abaixo.',
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final restriction in _suggestions)
                      FilterChip(
                        label: Text(restriction),
                        selected:
                            _selectedRestrictions.contains(restriction),
                        onSelected: _saving
                            ? null
                            : (selected) => setState(() {
                                  if (selected) {
                                    _selectedRestrictions.add(restriction);
                                  } else {
                                    _selectedRestrictions.remove(restriction);
                                  }
                                }),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _otherRestrictions,
                  enabled: !_saving,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Outras restrições',
                    helperText:
                        'Separe por vírgulas. Ex.: corante, frutos do mar.',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(
                    _saving ? 'Salvando...' : 'Salvar preferências',
                  ),
                ),
              ],
            ),
    );
  }
}
