import 'package:flutter/foundation.dart';

/// In-memory ring log visible on-device (and printed to console).
class BootLog extends ChangeNotifier {
  BootLog._();
  static final BootLog instance = BootLog._();

  static const int maxLines = 80;
  final List<String> lines = <String>[];

  static final List<String> memory = instance.lines;

  static void logSync(String message) {
    instance._append(message);
  }

  void _append(String message) {
    final stamp = DateTime.now().toIso8601String().substring(11, 19);
    final line = '$stamp $message';
    lines.add(line);
    if (lines.length > maxLines) {
      lines.removeRange(0, lines.length - maxLines);
    }
    // ignore: avoid_print
    print('PULSECRAFT $line');
    debugPrint('PULSECRAFT $line');
    notifyListeners();
  }

  static Future<void> init() async {
    logSync('BootLog.init');
  }
}
