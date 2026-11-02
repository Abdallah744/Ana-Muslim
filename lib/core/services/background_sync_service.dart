import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BackgroundSyncService {
  static Timer? _periodicTimer;

  /// Initialize Background Sync Service
  static Future<void> init() async {
    try {
      // Perform initial silent sync
      syncHabitsAndWorshipLogs();

      // Set up periodic background sync timer every 30 minutes while app is running
      _periodicTimer?.cancel();
      _periodicTimer = Timer.periodic(const Duration(minutes: 30), (_) {
        syncHabitsAndWorshipLogs();
      });
      debugPrint('BackgroundSyncService: Initialized periodic silent background sync timer.');
    } catch (e) {
      debugPrint('BackgroundSyncService init error: $e');
    }
  }

  /// Perform silent async sync of local habit logs to Supabase
  static Future<void> syncHabitsAndWorshipLogs() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return; // Skip sync for guests or non-logged-in users

      final prefs = await SharedPreferences.getInstance();

      final Map<String, dynamic> habitsData = {
        'user_id': user.id,
        'habit_quran': prefs.getBool('habit_1') ?? false,
        'habit_azkar_morning': prefs.getBool('habit_2') ?? false,
        'habit_istighfar': prefs.getBool('habit_3') ?? false,
        'habit_witr': prefs.getBool('habit_4') ?? false,
        'quit_streak_gheba': prefs.getInt('quit_habit_1') ?? 12,
        'quit_streak_browsing': prefs.getInt('quit_habit_2') ?? 7,
        'updated_at': DateTime.now().toIso8601String(),
      };

      await Supabase.instance.client
          .from('user_habits')
          .upsert(habitsData, onConflict: 'user_id');

      debugPrint('BackgroundSyncService: Silently synced habit logs to Supabase cloud!');
    } catch (e) {
      debugPrint('BackgroundSyncService sync error: $e');
    }
  }

  /// Trigger immediate silent sync
  static void triggerOneOffSync() {
    Future.microtask(() => syncHabitsAndWorshipLogs());
  }

  static void dispose() {
    _periodicTimer?.cancel();
  }
}
