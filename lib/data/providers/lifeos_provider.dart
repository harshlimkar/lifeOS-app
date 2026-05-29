import 'package:flutter/material.dart';
import '../models/day_entry.dart';
import '../../core/constants/app_constants.dart';
import '../services/supabase_service.dart';
import 'package:intl/intl.dart';

class LifeOSProvider extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();

  String _userId = '';
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  // User profile
  String _userName = 'Champion';
  int _totalXP = 0;
  int _currentStreak = 0;
  int _longestStreak = 0;
  Set<String> _unlockedAchievements = {};
  int _totalPomodoroSessions = 0;
  int _totalWaterGoalDays = 0;
  int _totalWorkoutDays = 0;
  int _totalJournalEntries = 0;
  bool _onboardingComplete = false;

  // Today's state
  DayEntry? _todayEntry;
  bool _flowCompleted = false;
  List<DayEntry> _allEntries = [];

  // Getters
  String get userName => _userName;
  int get totalXP => _totalXP;
  int get currentStreak => _currentStreak;
  int get longestStreak => _longestStreak;
  Set<String> get unlockedAchievements => _unlockedAchievements;
  bool get onboardingComplete => _onboardingComplete;
  DayEntry? get todayEntry => _todayEntry;
  bool get flowCompleted => _flowCompleted;
  List<DayEntry> get allEntries => _allEntries;

  int get currentLevel {
    for (int i = AppConstants.levelThresholds.length - 1; i >= 0; i--) {
      if (_totalXP >= AppConstants.levelThresholds[i]) return i;
    }
    return 0;
  }

  String get levelTitle {
    final lvl = currentLevel;
    if (lvl < AppConstants.levelTitles.length) return AppConstants.levelTitles[lvl];
    return AppConstants.levelTitles.last;
  }

  double get xpProgress {
    final lvl = currentLevel;
    final nextLvl = lvl + 1;
    if (nextLvl >= AppConstants.levelThresholds.length) return 1.0;
    final current = _totalXP - AppConstants.levelThresholds[lvl];
    final needed = AppConstants.levelThresholds[nextLvl] - AppConstants.levelThresholds[lvl];
    return (current / needed).clamp(0.0, 1.0);
  }

  int get xpToNextLevel {
    final lvl = currentLevel;
    final nextLvl = lvl + 1;
    if (nextLvl >= AppConstants.levelThresholds.length) return 0;
    return AppConstants.levelThresholds[nextLvl] - _totalXP;
  }

  String get todayKey => DateFormat('yyyy-MM-dd').format(DateTime.now());

  String get motivationalQuote {
    final day = DateTime.now().day;
    return AppConstants.motivationalQuotes[day % AppConstants.motivationalQuotes.length];
  }

  String get todayWorkout {
    final weekday = DateFormat('EEEE').format(DateTime.now());
    return AppConstants.workoutSplit[weekday] ?? 'Rest Day';
  }

  List<String> get todayExercises {
    return AppConstants.workoutExercises[todayWorkout] ?? [];
  }

  // ── Init ───────────────────────────────────────────────────────────────────
  Future<void> init(String userId) async {
    if (_isInitialized && _userId == userId) return; // already loaded
    _userId = userId;
    _isInitialized = false;
    notifyListeners();

    // Run all three Supabase fetches IN PARALLEL — ~3x faster than sequential
    await Future.wait([
      _loadProfile(),
      _loadTodayEntry(),
      _loadAllEntries(),
    ]);
    _calculateStreak();

    _isInitialized = true;
    notifyListeners();
  }

  void reset() {
    _userId = '';
    _isInitialized = false;
    _userName = 'Champion';
    _totalXP = 0;
    _currentStreak = 0;
    _longestStreak = 0;
    _unlockedAchievements = {};
    _totalPomodoroSessions = 0;
    _totalWaterGoalDays = 0;
    _totalWorkoutDays = 0;
    _totalJournalEntries = 0;
    _onboardingComplete = false;
    _todayEntry = null;
    _flowCompleted = false;
    _allEntries = [];
    notifyListeners();
  }

  // ── Profile ────────────────────────────────────────────────────────────────
  Future<void> _loadProfile() async {
    final data = await _supabaseService.loadProfile(_userId);
    if (data != null) {
      _userName = data['user_name'] ?? 'Champion';
      _totalXP = data['total_xp'] ?? 0;
      _currentStreak = data['current_streak'] ?? 0;
      _longestStreak = data['longest_streak'] ?? 0;
      _onboardingComplete = data['onboarding_complete'] ?? false;
      _totalPomodoroSessions = data['total_pomodoro_sessions'] ?? 0;
      _totalWaterGoalDays = data['total_water_goal_days'] ?? 0;
      _totalWorkoutDays = data['total_workout_days'] ?? 0;
      _totalJournalEntries = data['total_journal_entries'] ?? 0;
      final achievementsList = List<String>.from(data['achievements'] ?? []);
      _unlockedAchievements = Set.from(achievementsList);
      _flowCompleted = data['flow_completed_$todayKey'] ?? false;
    }
  }

  Future<void> _saveProfile() async {
    if (_userId.isEmpty) return;
    await _supabaseService.saveProfile(_userId, {
      'userName': _userName,
      'totalXP': _totalXP,
      'currentStreak': _currentStreak,
      'longestStreak': _longestStreak,
      'onboardingComplete': _onboardingComplete,
      'totalPomodoroSessions': _totalPomodoroSessions,
      'totalWaterGoalDays': _totalWaterGoalDays,
      'totalWorkoutDays': _totalWorkoutDays,
      'totalJournalEntries': _totalJournalEntries,
      'achievements': _unlockedAchievements.toList(),
      'flowCompleted_$todayKey': _flowCompleted,
    });
  }

  // ── Day Entry ──────────────────────────────────────────────────────────────
  Future<void> _loadTodayEntry() async {
    final entry = await _supabaseService.loadDayEntry(_userId, todayKey);
    _todayEntry = entry ??
        DayEntry(
          dateKey: todayKey,
          createdAt: DateTime.now(),
        );
  }

  Future<void> _loadAllEntries() async {
    _allEntries = await _supabaseService.loadAllEntries(_userId);
  }

  void _calculateStreak() {
    int streak = 0;
    final now = DateTime.now();
    for (int i = 0; i < 365; i++) {
      final date = now.subtract(Duration(days: i));
      final key = DateFormat('yyyy-MM-dd').format(date);
      final entry = _allEntries.cast<DayEntry?>().firstWhere(
        (e) => e?.dateKey == key,
        orElse: () => null,
      );
      if (entry != null &&
          (entry.completedMissions.isNotEmpty || entry.workoutCompleted)) {
        streak++;
      } else {
        break;
      }
    }
    if (streak != _currentStreak) {
      _currentStreak = streak;
      if (streak > _longestStreak) _longestStreak = streak;
    }
  }

  Future<void> _saveToday() async {
    if (_userId.isEmpty) return;
    await _supabaseService.saveDayEntry(_userId, _todayEntry!);
    // Update local cache
    final idx = _allEntries.indexWhere((e) => e.dateKey == _todayEntry!.dateKey);
    if (idx >= 0) {
      _allEntries[idx] = _todayEntry!;
    } else {
      _allEntries.add(_todayEntry!);
    }
  }

  // ── Missions ───────────────────────────────────────────────────────────────
  void toggleMission(String missionId) {
    final entry = _todayEntry!;
    if (entry.completedMissions.contains(missionId)) {
      entry.completedMissions.remove(missionId);
    } else {
      entry.completedMissions.add(missionId);
    }
    _saveToday();
    notifyListeners();
  }

  bool isMissionCompleted(String missionId) {
    return _todayEntry?.completedMissions.contains(missionId) ?? false;
  }

  // ── Water ──────────────────────────────────────────────────────────────────
  void addWater(double liters) {
    _todayEntry!.waterIntakeLiters =
        (_todayEntry!.waterIntakeLiters + liters).clamp(0.0, 6.0);
    _saveToday();
    notifyListeners();
  }

  void removeWater(double liters) {
    _todayEntry!.waterIntakeLiters =
        (_todayEntry!.waterIntakeLiters - liters).clamp(0.0, 6.0);
    _saveToday();
    notifyListeners();
  }

  // ── Workout ────────────────────────────────────────────────────────────────
  void setWorkoutCompleted(bool val) {
    _todayEntry!.workoutCompleted = val;
    _saveToday();
    notifyListeners();
  }

  // ── Focus ──────────────────────────────────────────────────────────────────
  void addFocusMinutes(int minutes) {
    _todayEntry!.focusMinutes += minutes;
    _totalPomodoroSessions++;
    _saveToday();
    _saveProfile();
    notifyListeners();
  }

  // ── Screen Time ────────────────────────────────────────────────────────────
  void setScreenTime(int instagramMin, int youtubeMin) {
    _todayEntry!.instagramMinutes = instagramMin;
    _todayEntry!.youtubeMinutes = youtubeMin;
    _saveToday();
    notifyListeners();
  }

  // ── Journal ────────────────────────────────────────────────────────────────
  void saveJournal(String wentWell, String wastedTime, String improve) {
    _todayEntry!.journalWentWell = wentWell;
    _todayEntry!.journalWastedTime = wastedTime;
    _todayEntry!.journalImprove = improve;
    _totalJournalEntries++;
    _saveToday();
    _saveProfile();
    notifyListeners();
  }

  // ── Complete Day ──────────────────────────────────────────────────────────
  Future<void> completeDay() async {
    final entry = _todayEntry!;
    int xp = 0;
    xp += entry.completedMissions.length * AppConstants.xpPerMission;
    if (entry.waterIntakeLiters >= AppConstants.dailyWaterGoalLiters) {
      xp += AppConstants.xpPerWaterGoal;
      _totalWaterGoalDays++;
    }
    if (entry.workoutCompleted) {
      xp += AppConstants.xpPerWorkout;
      _totalWorkoutDays++;
    }
    if (entry.journalWentWell.isNotEmpty) xp += AppConstants.xpPerJournal;

    final isPerfect = entry.completedMissions.length >= 6 &&
        entry.waterIntakeLiters >= AppConstants.dailyWaterGoalLiters &&
        entry.workoutCompleted &&
        entry.journalWentWell.isNotEmpty;

    if (isPerfect) xp += AppConstants.xpPerfectDayBonus;

    entry.xpEarned = xp;
    entry.isPerfectDay = isPerfect;

    _totalXP += xp;
    _flowCompleted = true;

    await _saveToday();
    _calculateStreak();
    _checkAchievements();
    await _saveProfile();
    notifyListeners();
  }

  // ── Edit/Update Entry (for any day in history) ───────────────────────────
  Future<void> updateEntry(DayEntry entry) async {
    if (_userId.isEmpty) return;

    // Recalculate entry's XP and Perfect Day status (without focus)
    int xp = 0;
    xp += entry.completedMissions.length * AppConstants.xpPerMission;
    if (entry.waterIntakeLiters >= AppConstants.dailyWaterGoalLiters) {
      xp += AppConstants.xpPerWaterGoal;
    }
    if (entry.workoutCompleted) {
      xp += AppConstants.xpPerWorkout;
    }
    if (entry.journalWentWell.isNotEmpty) xp += AppConstants.xpPerJournal;

    final isPerfect = entry.completedMissions.length >= 6 &&
        entry.waterIntakeLiters >= AppConstants.dailyWaterGoalLiters &&
        entry.workoutCompleted &&
        entry.journalWentWell.isNotEmpty;

    if (isPerfect) xp += AppConstants.xpPerfectDayBonus;

    final oldXp = entry.xpEarned;
    entry.xpEarned = xp;
    entry.isPerfectDay = isPerfect;

    // Correct total XP
    _totalXP = _totalXP - oldXp + xp;

    await _supabaseService.saveDayEntry(_userId, entry);

    // Update local cache
    final idx = _allEntries.indexWhere((e) => e.dateKey == entry.dateKey);
    if (idx >= 0) {
      _allEntries[idx] = entry;
    } else {
      _allEntries.add(entry);
    }

    if (entry.dateKey == todayKey) {
      _todayEntry = entry;
    }

    _calculateStreak();
    _checkAchievements();
    await _saveProfile();
    notifyListeners();
  }

  void _checkAchievements() {
    final newAchievements = <String>[];
    if (!_unlockedAchievements.contains('first_day') && _allEntries.isNotEmpty) {
      newAchievements.add('first_day');
    }
    if (!_unlockedAchievements.contains('streak_3') && _currentStreak >= 3) {
      newAchievements.add('streak_3');
    }
    if (!_unlockedAchievements.contains('streak_7') && _currentStreak >= 7) {
      newAchievements.add('streak_7');
    }
    if (!_unlockedAchievements.contains('streak_30') && _currentStreak >= 30) {
      newAchievements.add('streak_30');
    }
    if (!_unlockedAchievements.contains('perfect_day') && _todayEntry!.isPerfectDay) {
      newAchievements.add('perfect_day');
    }
    if (!_unlockedAchievements.contains('hydration_master') && _totalWaterGoalDays >= 7) {
      newAchievements.add('hydration_master');
    }
    if (!_unlockedAchievements.contains('deep_focus') && _totalPomodoroSessions >= 10) {
      newAchievements.add('deep_focus');
    }
    if (!_unlockedAchievements.contains('gym_warrior') && _totalWorkoutDays >= 20) {
      newAchievements.add('gym_warrior');
    }
    if (!_unlockedAchievements.contains('journal_sage') && _totalJournalEntries >= 14) {
      newAchievements.add('journal_sage');
    }

    for (final id in newAchievements) {
      _unlockedAchievements.add(id);
      final ach = AppConstants.achievements.firstWhere(
          (a) => a['id'] == id,
          orElse: () => {});
      if (ach.isNotEmpty) {
        _totalXP += (ach['xp'] as int);
      }
    }
  }

  // ── Profile actions ────────────────────────────────────────────────────────
  Future<void> setUserName(String name) async {
    _userName = name;
    await _saveProfile();
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    _onboardingComplete = true;
    await _saveProfile();
    notifyListeners();
  }

  // ── Analytics ──────────────────────────────────────────────────────────────
  List<DayEntry> getLastNDays(int n) {
    final now = DateTime.now();
    final entries = <DayEntry>[];
    for (int i = n - 1; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final key = DateFormat('yyyy-MM-dd').format(date);
      final entry = _allEntries.cast<DayEntry?>().firstWhere(
        (e) => e?.dateKey == key,
        orElse: () => null,
      );
      if (entry != null) entries.add(entry);
    }
    return entries;
  }

  Map<String, double> getWeeklyScores() {
    final days = getLastNDays(7);
    final map = <String, double>{};
    for (final d in days) {
      map[d.dateKey] = d.completionPercentage;
    }
    return map;
  }

  double get weeklyAvgScore {
    final days = getLastNDays(7);
    if (days.isEmpty) return 0;
    return days.map((d) => d.completionPercentage).reduce((a, b) => a + b) /
        days.length;
  }

  Map<DateTime, int> getHeatmapData() {
    final map = <DateTime, int>{};
    for (final entry in _allEntries) {
      final parts = entry.dateKey.split('-');
      final date =
          DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
      final pct = entry.completionPercentage;
      if (pct >= 0.8) map[date] = 2;
      else if (pct >= 0.4) map[date] = 1;
      else if (pct > 0) map[date] = 0;
    }
    return map;
  }

  bool checkPerfectWeek() {
    final days = getLastNDays(7);
    if (days.length < 7) return false;
    return days.every((d) => d.isPerfectDay);
  }
}
