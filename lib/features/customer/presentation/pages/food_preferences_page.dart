import 'package:flutter/material.dart';
import 'package:leafeat_mobile/core/theme/app_colors.dart';

class FoodPreferencesPage extends StatefulWidget {
  const FoodPreferencesPage({super.key});
  @override
  State<FoodPreferencesPage> createState() => _FoodPreferencesPageState();
}

class _FoodPreferencesPageState extends State<FoodPreferencesPage> {
  bool vegan = false;
  bool lactoseFree = true;
  bool showMetricMenus = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Preferências alimentares'), backgroundColor: AppColors.primary, foregroundColor: AppColors.onPrimary),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(title: const Text('Alimentação vegana'), subtitle: const Text('Priorizar pratos sem ingredientes de origem animal'), value: vegan, onChanged: (value) => setState(() => vegan = value)),
          SwitchListTile(title: const Text('Sem lactose'), subtitle: const Text('Destacar pratos indicados como livres de lactose'), value: lactoseFree, onChanged: (value) => setState(() => lactoseFree = value)),
          SwitchListTile(title: const Text('Cardápio com métricas'), subtitle: const Text('Priorizar estabelecimentos com informações nutricionais'), value: showMetricMenus, onChanged: (value) => setState(() => showMetricMenus = value)),
          const SizedBox(height: 20),
          FilledButton(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Preferências salvas nesta demonstração.'))), child: const Text('Salvar preferências')),
        ],
      ),
    );
  }
}
