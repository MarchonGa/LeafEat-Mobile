import 'package:flutter/material.dart';
import 'package:leafeat_mobile/core/theme/app_colors.dart';

class NutritionTrackingPage extends StatelessWidget {
  const NutritionTrackingPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Macros e calorias'), backgroundColor: AppColors.primary, foregroundColor: AppColors.onPrimary),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Resumo de hoje', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          const _ProgressCard(label: 'Calorias', current: 1280, goal: 2000, unit: 'kcal'),
          const _ProgressCard(label: 'Proteínas', current: 72, goal: 110, unit: 'g'),
          const _ProgressCard(label: 'Carboidratos', current: 145, goal: 240, unit: 'g'),
          const _ProgressCard(label: 'Gorduras', current: 44, goal: 65, unit: 'g'),
          const SizedBox(height: 12),
          const Text('Valores demonstrativos mantidos somente em memória.'),
        ],
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.label, required this.current, required this.goal, required this.unit});
  final String label;
  final int current;
  final int goal;
  final String unit;
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('$label: $current de $goal $unit', style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          LinearProgressIndicator(value: current / goal),
        ]),
      ),
    );
  }
}
