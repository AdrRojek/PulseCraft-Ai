import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../domain/models/workout_session.dart';
import '../domain/models/week_plan.dart';

class SessionRepository {
  SessionRepository._();
  static final SessionRepository instance = SessionRepository._();

  Future<File> _sessionsFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/pulsecraft_sessions.json');
  }

  Future<File> _planFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/pulsecraft_plan.json');
  }

  Future<List<WorkoutSession>> loadSessions() async {
    final file = await _sessionsFile();
    if (!await file.exists()) return [];
    final raw = jsonDecode(await file.readAsString()) as List<dynamic>;
    final list = raw.map((e) => WorkoutSession.fromJson(e as Map<String, dynamic>)).toList();
    list.sort((a, b) => b.startedAt.compareTo(a.startedAt));
    return list;
  }

  Future<WorkoutSession?> getSession(String id) async {
    final all = await loadSessions();
    try {
      return all.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveSession(WorkoutSession session) async {
    final all = await loadSessions();
    final idx = all.indexWhere((s) => s.id == session.id);
    if (idx >= 0) {
      all[idx] = session;
    } else {
      all.insert(0, session);
    }
    final file = await _sessionsFile();
    await file.writeAsString(jsonEncode(all.map((s) => s.toJson()).toList()));
  }

  Future<WeekPlan> loadPlan() async {
    final file = await _planFile();
    if (!await file.exists()) return WeekPlan();
    return WeekPlan.fromJson(jsonDecode(await file.readAsString()) as Map<String, dynamic>);
  }

  Future<void> savePlan(WeekPlan plan) async {
    final file = await _planFile();
    await file.writeAsString(jsonEncode(plan.toJson()));
  }
}
