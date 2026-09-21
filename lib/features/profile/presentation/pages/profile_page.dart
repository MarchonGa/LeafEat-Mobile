import 'package:flutter/material.dart';
import 'package:leafeat_mobile/app/session/app_session.dart';
import 'package:leafeat_mobile/core/theme/app_colors.dart';
import 'package:leafeat_mobile/features/auth/presentation/pages/login_page.dart';
import 'package:leafeat_mobile/features/auth/presentation/pages/register_page.dart';
import 'package:leafeat_mobile/features/customer/presentation/pages/favorites_page.dart';
import 'package:leafeat_mobile/features/customer/presentation/pages/food_preferences_page.dart';
import 'package:leafeat_mobile/features/customer/presentation/pages/my_reviews_page.dart';
import 'package:leafeat_mobile/features/customer/presentation/pages/nutrition_tracking_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final mode = AppSessionScope.watch(context).mode;
    return Scaffold(
      appBar: AppBar(
        title: Text(mode == UserMode.restaurant ? 'Perfil do restaurante' : 'Perfil'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
      ),
      body: switch (mode) {
        UserMode.guest => const _GuestProfile(),
        UserMode.customer => const _CustomerProfile(),
        UserMode.restaurant => const _RestaurantProfile(),
      },
    );
  }
}

class _GuestProfile extends StatefulWidget {
  const _GuestProfile();
  @override
  State<_GuestProfile> createState() => _GuestProfileState();
}

class _GuestProfileState extends State<_GuestProfile> with SingleTickerProviderStateMixin {
  final _accessCardKey = GlobalKey();
  late final AnimationController _controller;
  late final Animation<double> _highlight;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _highlight = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: 1), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1, end: 0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0, end: 1), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1, end: 0), weight: 1),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _requestAuthentication(String feature) async {
    final cardContext = _accessCardKey.currentContext;
    if (cardContext != null) {
      await Scrollable.ensureVisible(cardContext, duration: const Duration(milliseconds: 350), curve: Curves.easeOut, alignment: 0.15);
    }
    if (!mounted) return;
    _controller.forward(from: 0);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('Entre ou crie uma conta para acessar $feature.')));
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const _ProfileHeader(icon: Icons.person, title: 'Visitante', subtitle: 'Você está navegando sem uma conta.'),
        const SizedBox(height: 24),
        AnimatedBuilder(
          key: _accessCardKey,
          animation: _highlight,
          builder: (context, child) {
            final pulse = _highlight.value;
            return Card(
              elevation: 2 + pulse * 6,
              color: Color.lerp(Theme.of(context).colorScheme.surface, AppColors.primary.withValues(alpha: 0.14), pulse),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Color.lerp(Colors.transparent, AppColors.primary, pulse)!, width: 1 + pulse)),
              child: child,
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(children: [
              const Icon(Icons.lock_open, color: AppColors.primary, size: 34),
              const SizedBox(height: 10),
              const Text('Acesse todos os recursos', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              const Text('Entre para salvar locais, publicar avaliações e personalizar suas preferências.', textAlign: TextAlign.center),
              const SizedBox(height: 18),
              Row(children: [
                Expanded(child: FilledButton(onPressed: () => _open(context, const LoginPage()), child: const Text('Entrar'))),
                const SizedBox(width: 10),
                Expanded(child: OutlinedButton(onPressed: () => _open(context, const RegisterPage()), child: const Text('Criar conta'))),
              ]),
            ]),
          ),
        ),
        const SizedBox(height: 22),
        _AccountOptions(locked: true, onLockedTap: _requestAuthentication),
        const SizedBox(height: 28),
        const _ModeSwitcher(),
      ],
    );
  }
}

class _CustomerProfile extends StatelessWidget {
  const _CustomerProfile();
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: const [
        _ProfileHeader(icon: Icons.person, title: 'Cliente LeafEat', subtitle: 'cliente@leafeat.com'),
        SizedBox(height: 24),
        _AccountOptions(locked: false),
        SizedBox(height: 28),
        _ModeSwitcher(),
      ],
    );
  }
}

class _RestaurantProfile extends StatelessWidget {
  const _RestaurantProfile();
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const _ProfileHeader(icon: Icons.store, title: 'Sabor Natural', subtitle: 'Refeições saudáveis • Aracati, CE'),
        const SizedBox(height: 20),
        const Text('Pratos equilibrados preparados com ingredientes frescos e informações nutricionais por porção.'),
        const SizedBox(height: 22),
        Text('Conquistas e selos', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 10),
        const Wrap(spacing: 8, runSpacing: 8, children: [
          Chip(avatar: Icon(Icons.workspace_premium, color: Color(0xFFC28B00)), label: Text('Ouro — 100% de cobertura')),
          Chip(avatar: Icon(Icons.eco, color: AppColors.primary), label: Text('Opções veganas')),
          Chip(avatar: Icon(Icons.no_food, color: AppColors.primary), label: Text('Opções sem lactose')),
        ]),
        const SizedBox(height: 10),
        const Card(child: ListTile(leading: Icon(Icons.info_outline), title: Text('Cobertura não é verificação'), subtitle: Text('As informações foram fornecidas pelo estabelecimento. A verificação depende de visita técnica.'))),
        const SizedBox(height: 28),
        const _ModeSwitcher(),
      ],
    );
  }
}

class _AccountOptions extends StatelessWidget {
  const _AccountOptions({required this.locked, this.onLockedTap});
  final bool locked;
  final ValueChanged<String>? onLockedTap;

  @override
  Widget build(BuildContext context) {
    void open(Widget page) => _open(context, page);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Recursos da sua conta', style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 10),
      Card(
        color: locked ? Theme.of(context).colorScheme.surfaceContainerHighest : null,
        child: Column(children: [
          _Option(icon: Icons.favorite_outline, title: 'Locais favoritos', subtitle: 'Salve os lugares que você mais gosta', locked: locked, onTap: () => locked ? onLockedTap?.call('seus favoritos') : open(const FavoritesPage())),
          const Divider(height: 1),
          _Option(icon: Icons.history, title: 'Minhas avaliações', subtitle: 'Consulte as avaliações que você publicou', locked: locked, onTap: () => locked ? onLockedTap?.call('suas avaliações') : open(const MyReviewsPage())),
          const Divider(height: 1),
          _Option(icon: Icons.donut_large, title: 'Ingestão de macros e calorias', subtitle: 'Acompanhe suas metas e refeições diárias', locked: locked, onTap: () => locked ? onLockedTap?.call('sua ingestão de macros e calorias') : open(const NutritionTrackingPage())),
          const Divider(height: 1),
          _Option(icon: Icons.tune, title: 'Preferências alimentares', subtitle: 'Personalize os resultados exibidos', locked: locked, onTap: () => locked ? onLockedTap?.call('suas preferências') : open(const FoodPreferencesPage())),
        ]),
      ),
    ]);
  }
}

class _Option extends StatelessWidget {
  const _Option({required this.icon, required this.title, required this.subtitle, required this.locked, required this.onTap});
  final IconData icon;
  final String title;
  final String subtitle;
  final bool locked;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final color = locked ? Theme.of(context).colorScheme.onSurfaceVariant : null;
    return ListTile(leading: Icon(icon, color: color), title: Text(title, style: TextStyle(color: color)), subtitle: Text(subtitle, style: TextStyle(color: color)), trailing: Icon(locked ? Icons.lock_outline : Icons.chevron_right, color: color), onTap: onTap);
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.icon, required this.title, required this.subtitle});
  final IconData icon;
  final String title;
  final String subtitle;
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      CircleAvatar(radius: 44, backgroundColor: AppColors.primary, foregroundColor: AppColors.onPrimary, child: Icon(icon, size: 48)),
      const SizedBox(height: 12),
      Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      const SizedBox(height: 6),
      Text(subtitle, textAlign: TextAlign.center),
    ]);
  }
}

class _ModeSwitcher extends StatelessWidget {
  const _ModeSwitcher();
  @override
  Widget build(BuildContext context) {
    final session = AppSessionScope.watch(context);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Divider(),
      const SizedBox(height: 12),
      Text('Visualização de demonstração', style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 6),
      const Text('Troque o tipo de usuário enquanto não há backend.'),
      const SizedBox(height: 12),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          ChoiceChip(
            avatar: const Icon(Icons.person_outline, size: 18),
            label: const Text('Visitante'),
            selected: session.mode == UserMode.guest,
            onSelected: (_) => session.switchMode(UserMode.guest),
          ),
          ChoiceChip(
            avatar: const Icon(Icons.person, size: 18),
            label: const Text('Cliente'),
            selected: session.mode == UserMode.customer,
            onSelected: (_) => session.switchMode(UserMode.customer),
          ),
          ChoiceChip(
            avatar: const Icon(Icons.store, size: 18),
            label: const Text('Restaurante'),
            selected: session.mode == UserMode.restaurant,
            onSelected: (_) => session.switchMode(UserMode.restaurant),
          ),
        ],
      ),
    ]);
  }
}

void _open(BuildContext context, Widget page) {
  Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
}
