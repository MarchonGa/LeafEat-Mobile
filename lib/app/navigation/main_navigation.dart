import 'package:flutter/material.dart';
import 'package:leafeat_mobile/features/explore/presentation/pages/explore_page.dart';
import 'package:leafeat_mobile/features/map/presentation/pages/map_page.dart';
import 'package:leafeat_mobile/features/profile/presentation/pages/profile_page.dart';
import 'package:leafeat_mobile/features/review/presentation/pages/review_page.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  final _pageController = PageController();
  int _selectedIndex = 0;
  bool _isAnimating = false;

  static const _pages = [
    MapPage(),
    ExplorePage(),
    ReviewPage(),
    ProfilePage(),
  ];

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
    final duration = Duration(
      milliseconds: 320 + (distance * 100),
    );

    setState(() => _isAnimating = true);

    await _pageController.animateToPage(
      index,
      duration: duration,
      curve: Curves.easeInOutCubic,
    );

    if (mounted) {
      setState(() => _isAnimating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() => _selectedIndex = index);
        },
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _selectPage,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map),
            label: 'Mapa',
          ),
          NavigationDestination(
            icon: Icon(Icons.search),
            selectedIcon: Icon(Icons.travel_explore),
            label: 'Explorar',
          ),
          NavigationDestination(
            icon: Icon(Icons.qr_code_scanner),
            label: 'Avaliar',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
