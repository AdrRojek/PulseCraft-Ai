import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/home/home_screen.dart';
import '../../features/live/camera_hud_screen.dart';
import '../../features/dashboard/trajectory_dashboard_screen.dart';
import '../../features/planner/planner_screen.dart';
import '../../features/history/history_replay_screen.dart';
import '../../features/summary/session_summary_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [

      GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
      GoRoute(path: '/live', builder: (_, __) => const CameraHudScreen()),
      GoRoute(path: '/dashboard', builder: (_, __) => const TrajectoryDashboardScreen()),
      GoRoute(path: '/planner', builder: (_, __) => const PlannerScreen()),
      GoRoute(path: '/history', builder: (_, __) => const HistoryReplayScreen()),
      GoRoute(path: '/summary', builder: (_, __) => const SessionSummaryScreen()),

  ],
);
