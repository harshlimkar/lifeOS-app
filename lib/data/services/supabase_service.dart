import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/day_entry.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  // ── User Profile Queries ───────────────────────────────────────────────────
  Future<Map<String, dynamic>?> loadProfile(String userId) async {
    try {
      final response = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle()
          .timeout(const Duration(seconds: 10));
      return response;
    } catch (e) {
      return null;
    }
  }

  Future<void> saveProfile(String userId, Map<String, dynamic> data) async {
    try {
      await _client.from('profiles').upsert({
        'id': userId,
        'user_name': data['userName'],
        'total_xp': data['totalXP'],
        'current_streak': data['currentStreak'],
        'longest_streak': data['longestStreak'],
        'onboarding_complete': data['onboardingComplete'],
        'total_pomodoro_sessions': data['totalPomodoroSessions'],
        'total_water_goal_days': data['totalWaterGoalDays'],
        'total_workout_days': data['totalWorkoutDays'],
        'total_journal_entries': data['totalJournalEntries'],
        'achievements': data['achievements'] ?? [],
        'height_cm': data['heightCm'],
        'weight_kg': data['weightKg'],
        'gender': data['gender'],
        'age': data['age'],
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      });
    } catch (e) {
      // Handle error gracefully or let offline cache deal with it
    }
  }

  // ── Meal Checklist ─────────────────────────────────────────────────────────
  Future<Set<String>> loadMealChecklist(String userId, String dateKey) async {
    try {
      final response = await _client
          .from('meal_checklist')
          .select('meal_id')
          .eq('user_id', userId)
          .eq('date_key', dateKey)
          .eq('completed', true)
          .timeout(const Duration(seconds: 10));
      return Set<String>.from((response as List).map((r) => r['meal_id'] as String));
    } catch (e) {
      return {};
    }
  }

  Future<void> toggleMealItem(String userId, String dateKey, String mealId, bool completed) async {
    try {
      await _client.from('meal_checklist').upsert({
        'user_id': userId,
        'date_key': dateKey,
        'meal_id': mealId,
        'completed': completed,
      }, onConflict: 'user_id,date_key,meal_id');
    } catch (e) {
      // Silently fail — local state is already updated
    }
  }

  // ── Day Entry Queries ──────────────────────────────────────────────────────
  Future<DayEntry?> loadDayEntry(String userId, String dateKey) async {
    try {
      final response = await _client
          .from('day_entries')
          .select()
          .eq('user_id', userId)
          .eq('date_key', dateKey)
          .maybeSingle()
          .timeout(const Duration(seconds: 10));

      if (response == null) return null;
      return _mapToDayEntry(response);
    } catch (e) {
      return null;
    }
  }

  Future<void> saveDayEntry(String userId, DayEntry entry) async {
    try {
      await _client.from('day_entries').upsert({
        'user_id': userId,
        'date_key': entry.dateKey,
        'completed_missions': entry.completedMissions,
        'water_intake_liters': entry.waterIntakeLiters,
        'workout_completed': entry.workoutCompleted,
        'focus_minutes': entry.focusMinutes,
        'instagram_minutes': entry.instagramMinutes,
        'youtube_minutes': entry.youtubeMinutes,
        'journal_went_well': entry.journalWentWell,
        'journal_wasted_time': entry.journalWastedTime,
        'journal_improve': entry.journalImprove,
        'xp_earned': entry.xpEarned,
        'is_perfect_day': entry.isPerfectDay,
        'created_at': entry.createdAt.toUtc().toIso8601String(),
      }, onConflict: 'user_id,date_key');
    } catch (e) {
      // Let standard Supabase error handling take place
    }
  }

  Future<List<DayEntry>> loadAllEntries(String userId) async {
    try {
      final response = await _client
          .from('day_entries')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: true)
          .timeout(const Duration(seconds: 10));

      return (response as List)
          .map((d) => _mapToDayEntry(d as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Helper mapper from DB map to local DayEntry model
  DayEntry _mapToDayEntry(Map<String, dynamic> map) {
    return DayEntry(
      dateKey: map['date_key'] as String,
      createdAt: DateTime.parse(map['created_at'] as String).toLocal(),
      completedMissions: List<String>.from(map['completed_missions'] ?? []),
      waterIntakeLiters: (map['water_intake_liters'] as num?)?.toDouble() ?? 0,
      workoutCompleted: map['workout_completed'] as bool? ?? false,
      focusMinutes: map['focus_minutes'] as int? ?? 0,
      instagramMinutes: map['instagram_minutes'] as int? ?? 0,
      youtubeMinutes: map['youtube_minutes'] as int? ?? 0,
      journalWentWell: map['journal_went_well'] as String? ?? '',
      journalWastedTime: map['journal_wasted_time'] as String? ?? '',
      journalImprove: map['journal_improve'] as String? ?? '',
      xpEarned: map['xp_earned'] as int? ?? 0,
      isPerfectDay: map['is_perfect_day'] as bool? ?? false,
    );
  }
}
