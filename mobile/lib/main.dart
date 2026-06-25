import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PulseCraftApp());
}

class PulseCraftApp extends StatelessWidget {
  const PulseCraftApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PulseCraft AI',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const Scaffold(
        backgroundColor: Color(0xFF0F141A),
        body: Center(child: Text('PulseCraft AI', style: TextStyle(color: Colors.white))),
      ),
    );
  }
}
