import 'package:flutter/material.dart';
import 'package:leafeat_mobile/app/session/app_session.dart';
import 'package:leafeat_mobile/features/explore/presentation/pages/explore_page.dart';
import 'package:leafeat_mobile/features/map/presentation/pages/map_page.dart';
import 'package:leafeat_mobile/features/profile/presentation/pages/profile_page.dart';
import 'package:leafeat_mobile/features/restaurant/presentation/pages/restaurant_home_page.dart';
import 'package:leafeat_mobile/features/restaurant/presentation/pages/restaurant_menu_page.dart';
import 'package:leafeat_mobile/features/restaurant/presentation/pages/restaurant_reviews_page.dart';
import 'package:leafeat_mobile/features/review/presentation/pages/review_page.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  UserMode? _previousMode;

  @override
  Widget build(BuildContext context) {
    final mode = AppSessionScope.watch(context).mode;
    final changedMode = _previousMode != null && _previousMode != mode;
    _previousMode = mode;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: mode == UserMode.restaurant
          ? _RestaurantNavigation(
              key: const ValueKey('restaurant-navigation'),
              initialIndex: changedMode ? 3 : 0,
            )
          : _CustomerNavigation(
              key: const ValueKey('customer-navigation'),
              initialIndex: changedMode ? 3 : 0,
            ),
    );
  }
}

class _CustomerNavigation extends StatefulWidget {
  const _CustomerNavigation({required this.initialIndex, super.key});

  final int initialIndex;
  @override
  State<_CustomerNavigation> createState() => _CustomerNavigationState();
}

class _CustomerNavigationState extends State<_CustomerNavigation> {
  late final PageController _pageController;
  late int _selectedIndex;
  bool _isAnimating = false;

  static const _pages = [MapPage(), ExplorePage(), ReviewPage(), ProfilePage()];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _selectPage(int index) async {
    if (index == _selectedIndex || _isAnimating) return;
    if (MediaQuery.disableAnimationsOf(context)) {
      _pageController.jumpToPage(index);
      return;
    }
    final distance = (index - _selectedIndex).abs();
    setState(() => _isAnimating = true);
    await _pageController.animateToPage(
      index,
      duration: Duration(milliseconds: 320 + (distance * 100)),
      curve: Curves.easeInOutCubic,
    );
    if (mounted) setState(() => _isAnimating = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) => setState(() => _selectedIndex = index),
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _selectPage,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.map_outlined), selectedIcon: Icon(Icons.map), label: 'Mapa'),
          NavigationDestination(icon: Icon(Icons.search), selectedIcon: Icon(Icons.travel_explore), label: 'Explorar'),
          NavigationDestination(icon: Icon(Icons.qr_code_scanner), label: 'Avaliar'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}

class _RestaurantNavigation extends StatefulWidget {
  const _RestaurantNavigation({required this.initialIndex, super.key});

  final int initialIndex;
  @override
  State<_RestaurantNavigation> createState() => _RestaurantNavigationState();
}

class _RestaurantNavigationState extends State<_RestaurantNavigation> {
  late int _selectedIndex;
  static const _pages = [RestaurantHomePage(), RestaurantMenuPage(), RestaurantReviewsPage(), ProfilePage()];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Início'),
          NavigationDestination(icon: Icon(Icons.restaurant_menu), label: 'Cardápio'),
          NavigationDestination(icon: Icon(Icons.reviews_outlined), selectedIcon: Icon(Icons.reviews), label: 'Avaliações'),
          NavigationDestination(icon: Icon(Icons.store_outlined), selectedIcon: Icon(Icons.store), label: 'Perfil'),
        ],
      ),
    );
  }
}
