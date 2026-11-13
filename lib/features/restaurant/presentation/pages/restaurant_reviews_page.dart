import 'package:flutter/material.dart';
import 'package:leafeat_mobile/core/theme/app_colors.dart';

class RestaurantReviewsPage extends StatelessWidget {
  const RestaurantReviewsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Avaliações recebidas'), backgroundColor: AppColors.primary, foregroundColor: AppColors.onPrimary),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Card(child: ListTile(leading: CircleAvatar(child: Text('M')), title: Text('Marina • 5,0 ★'), subtitle: Text('Cardápio variado e informações fáceis de consultar.'))),
          Card(child: ListTile(leading: CircleAvatar(child: Text('A')), title: Text('Ana • 4,8 ★'), subtitle: Text('Prato bem servido e saboroso.'))),
          Card(child: ListTile(leading: CircleAvatar(child: Text('C')), title: Text('Carlos • 4,5 ★'), subtitle: Text('Ambiente agradável e atendimento rápido.'))),
        ],
      ),
    );
  }
}
