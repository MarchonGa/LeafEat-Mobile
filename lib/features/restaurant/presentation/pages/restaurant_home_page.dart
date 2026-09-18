import 'package:flutter/material.dart';
import 'package:leafeat_mobile/core/theme/app_colors.dart';

class RestaurantHomePage extends StatelessWidget {
  const RestaurantHomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Painel do restaurante'), backgroundColor: AppColors.primary, foregroundColor: AppColors.onPrimary),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Olá, Sabor Natural!', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 6),
          const Text('Acompanhe o preenchimento do seu cardápio.'),
          const SizedBox(height: 20),
          const Row(children: [
            Expanded(child: _SummaryCard(icon: Icons.restaurant_menu, value: '12', label: 'Pratos')),
            SizedBox(width: 12),
            Expanded(child: _SummaryCard(icon: Icons.star, value: '4,8', label: 'Nota geral')),
          ]),
          const SizedBox(height: 12),
          const Row(children: [
            Expanded(child: _SummaryCard(icon: Icons.monitor_heart_outlined, value: '100%', label: 'Cobertura')),
            SizedBox(width: 12),
            Expanded(child: _SummaryCard(icon: Icons.rate_review_outlined, value: '38', label: 'Avaliações')),
          ]),
          const SizedBox(height: 24),
          Text('Cobertura nutricional', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(18),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [Icon(Icons.workspace_premium, color: Color(0xFFC28B00)), SizedBox(width: 8), Text('Selo Gold', style: TextStyle(fontWeight: FontWeight.bold))]),
                SizedBox(height: 10),
                LinearProgressIndicator(value: 1),
                SizedBox(height: 8),
                Text('12 de 12 pratos possuem informações nutricionais.'),
                SizedBox(height: 6),
                Text('O selo indica cobertura, não verificação por visita técnica.'),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.icon, required this.value, required this.label});
  final IconData icon;
  final String value;
  final String label;
  @override
  Widget build(BuildContext context) {
    return Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [Icon(icon, color: AppColors.primary), const SizedBox(height: 8), Text(value, style: Theme.of(context).textTheme.headlineSmall), Text(label)])));
  }
}
