import 'package:flutter/material.dart';
import 'package:leafeat_mobile/core/theme/app_colors.dart';

class MyReviewsPage extends StatelessWidget {
  const MyReviewsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Minhas avaliações'), backgroundColor: AppColors.primary, foregroundColor: AppColors.onPrimary),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Card(child: ListTile(leading: Icon(Icons.star, color: Colors.amber), title: Text('Sabor Natural — 5,0'), subtitle: Text('Atendimento rápido e prato muito saboroso.'))),
          Card(child: ListTile(leading: Icon(Icons.star, color: Colors.amber), title: Text('Horta da Praça — 4,0'), subtitle: Text('Boas opções vegetarianas.'))),
        ],
      ),
    );
  }
}
