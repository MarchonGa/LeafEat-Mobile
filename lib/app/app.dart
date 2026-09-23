import 'package:flutter/material.dart';
import 'package:leafeat_mobile/app/session/app_session.dart';
import 'package:leafeat_mobile/core/theme/app_theme.dart';
import 'package:leafeat_mobile/features/welcome/presentation/pages/welcome_page.dart';

class LeafEatApp extends StatefulWidget {
  const LeafEatApp({super.key});

  @override
  State<LeafEatApp> createState() => _LeafEatAppState();
}

class _LeafEatAppState extends State<LeafEatApp> {
  final _session = AppSession();

  @override
  void dispose() {
    _session.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppSessionScope(
      notifier: _session,
      child: MaterialApp(
        title: 'LeafEat',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const WelcomePage(),
      ),
    );
  }
}
