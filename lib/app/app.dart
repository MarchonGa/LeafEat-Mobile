import 'package:flutter/material.dart';
import 'package:leafeat_mobile/core/theme/app_theme.dart';
import 'package:leafeat_mobile/features/welcome/presentation/pages/welcome_page.dart';

class LeafEatApp extends StatelessWidget {
  const LeafEatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LeafEat',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const WelcomePage(),
    );
  }
}
