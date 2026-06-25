import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(home: Scaffold(body: Center(child: Text('PulseCraft AI')))));
}

class PulseCraftApp extends StatelessWidget {
  const PulseCraftApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'PulseCraft AI',
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
    );
  }
}
