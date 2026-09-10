import 'package:flutter/material.dart';
import 'package:leafeat_mobile/core/theme/app_colors.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const CircleAvatar(
            radius: 44,
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.onPrimary,
            child: Icon(Icons.person, size: 48),
          ),
          const SizedBox(height: 16),
          const Text(
            'Visitante',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.favorite_outline),
                  title: const Text('Locais favoritos'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.history),
                  title: const Text('Minhas avaliações'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.settings_outlined),
                  title: const Text('Configurações'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('O acesso à conta será integrado em breve.'),
                ),
              );
            },
            icon: const Icon(Icons.login),
            label: const Text('Entrar ou criar conta'),
          ),
        ],
      ),
    );
  }
}
