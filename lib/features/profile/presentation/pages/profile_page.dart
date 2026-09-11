import 'package:flutter/material.dart';
import 'package:leafeat_mobile/core/theme/app_colors.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  final _accessCardKey = GlobalKey();
  late final AnimationController _highlightController;
  late final Animation<double> _highlight;

  @override
  void initState() {
    super.initState();
    _highlightController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _highlight = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: 1), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1, end: 0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0, end: 1), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1, end: 0), weight: 1),
    ]).animate(
      CurvedAnimation(
        parent: _highlightController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _highlightController.dispose();
    super.dispose();
  }

  Future<void> _requestAuthentication(String feature) async {
    final accessCardContext = _accessCardKey.currentContext;

    if (accessCardContext != null) {
      await Scrollable.ensureVisible(
        accessCardContext,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut,
        alignment: 0.15,
      );
    }

    if (!mounted) return;

    _highlightController.forward(from: 0);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            'Entre ou crie uma conta para acessar $feature.',
          ),
        ),
      );
  }

  void _showAuthenticationMessage() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('A autenticação será integrada em breve.'),
        ),
      );
  }

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
          const SizedBox(height: 12),
          const Text(
            'Visitante',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            'Você está navegando sem uma conta.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          AnimatedBuilder(
            key: _accessCardKey,
            animation: _highlight,
            builder: (context, child) {
              final pulse = _highlight.value;
              return Card(
                elevation: 2 + (pulse * 6),
                color: Color.lerp(
                  Theme.of(context).colorScheme.surface,
                  AppColors.primary.withValues(alpha: 0.14),
                  pulse,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: Color.lerp(
                      Colors.transparent,
                      AppColors.primary,
                      pulse,
                    )!,
                    width: 1 + pulse,
                  ),
                ),
                child: child,
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Icon(
                    Icons.lock_open,
                    color: AppColors.primary,
                    size: 34,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Acesse todos os recursos',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Entre para salvar locais, publicar avaliações e personalizar suas preferências.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton(
                          onPressed: _showAuthenticationMessage,
                          child: const Text('Entrar'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _showAuthenticationMessage,
                          child: const Text('Criar conta'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 22),
          Text(
            'Recursos da sua conta',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          Card(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Column(
              children: [
                _LockedOption(
                  icon: Icons.favorite_outline,
                  title: 'Locais favoritos',
                  subtitle: 'Salve os lugares que você mais gosta',
                  onTap: () => _requestAuthentication('seus favoritos'),
                ),
                const Divider(height: 1),
                _LockedOption(
                  icon: Icons.history,
                  title: 'Minhas avaliações',
                  subtitle: 'Consulte as avaliações que você publicou',
                  onTap: () => _requestAuthentication('suas avaliações'),
                ),
                const Divider(height: 1),
                _LockedOption(
                  icon: Icons.donut_large,
                  title: 'Ingestão de macros e calorias',
                  subtitle: 'Acompanhe suas metas e refeições diárias',
                  onTap: () => _requestAuthentication(
                    'sua ingestão de macros e calorias',
                  ),
                ),
                const Divider(height: 1),
                _LockedOption(
                  icon: Icons.tune,
                  title: 'Preferências alimentares',
                  subtitle: 'Personalize os resultados exibidos',
                  onTap: () => _requestAuthentication('suas preferências'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LockedOption extends StatelessWidget {
  const _LockedOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final disabledColor = Theme.of(context).colorScheme.onSurfaceVariant;

    return ListTile(
      leading: Icon(icon, color: disabledColor),
      title: Text(
        title,
        style: TextStyle(color: disabledColor),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: disabledColor),
      ),
      trailing: Icon(Icons.lock_outline, color: disabledColor),
      onTap: onTap,
    );
  }
}
