import 'package:flutter/material.dart';
import 'core/theme/pulsecraft_theme.dart';
import 'core/router/app_router.dart';

class PulseCraftApp extends StatelessWidget {
  const PulseCraftApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'PulseCraft AI',
      debugShowCheckedModeBanner: false,
      theme: PulseCraftTheme.dark(),
      routerConfig: appRouter,
    );
  }
}
