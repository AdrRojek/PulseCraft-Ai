import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'boot_log.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  BootLog.logSync('main() start');

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    BootLog.logSync('FlutterError: ${details.exceptionAsString()}');
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    BootLog.logSync('PlatformDispatcher: $error\n$stack');
    return true;
  };

  ErrorWidget.builder = (details) => Material(
        color: Colors.red.shade900,
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'UI error:\n${details.exceptionAsString()}',
                style: const TextStyle(color: Colors.white, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      );

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  BootLog.logSync('main() runApp');
  runApp(const PulseCraftApp());
}

class PulseCraftApp extends StatelessWidget {
  const PulseCraftApp({super.key});

  @override
  Widget build(BuildContext context) {
    BootLog.logSync('PulseCraftApp.build');
    return MaterialApp.router(
      title: 'PulseCraft AI',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      themeMode: ThemeMode.dark,
      routerConfig: appRouter,
      builder: (context, child) {
        // Visible even if router child is null.
        return ColoredBox(
          color: AppColors.steel900,
          child: child ??
              const Center(
                child: Text(
                  'PulseCraft loading…',
                  style: TextStyle(
                    color: AppColors.acidLime,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
        );
      },
    );
  }
}
