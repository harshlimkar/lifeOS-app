import 'package:hive/hive.dart';

part 'day_entry.g.dart';

@HiveType(typeId: 0)
class DayEntry extends HiveObject {
  @HiveField(0)
  late String dateKey; // 'YYYY-MM-DD'

  @HiveField(1)
  late List<String> completedMissions;

  @HiveField(2)
  late double waterIntakeLiters;

  @HiveField(3)
  late bool workoutCompleted;

  @HiveField(4)
  late int focusMinutes;

  @HiveField(5)
  late int instagramMinutes;

  @HiveField(6)
  late int youtubeMinutes;

  @HiveField(7)
  late String journalWentWell;

  @HiveField(8)
  late String journalWastedTime;

  @HiveField(9)
  late String journalImprove;

  @HiveField(10)
  late int xpEarned;

  @HiveField(11)
  late bool isPerfectDay;

  @HiveField(12)
  late DateTime createdAt;

  DayEntry({
    required this.dateKey,
    required this.createdAt,
    List<String>? completedMissions,
    this.waterIntakeLiters = 0,
    this.workoutCompleted = false,
    this.focusMinutes = 0,
    this.instagramMinutes = 0,
    this.youtubeMinutes = 0,
    this.journalWentWell = '',
    this.journalWastedTime = '',
    this.journalImprove = '',
    this.xpEarned = 0,
    this.isPerfectDay = false,
  }) : completedMissions = completedMissions ?? [];

  // ── Database Serialization ──────────────────────────────────────────────────
  Map<String, dynamic> toMap() {
    return {
      'dateKey': dateKey,
      'completedMissions': completedMissions,
      'waterIntakeLiters': waterIntakeLiters,
      'workoutCompleted': workoutCompleted,
      'focusMinutes': focusMinutes,
      'instagramMinutes': instagramMinutes,
      'youtubeMinutes': youtubeMinutes,
      'journalWentWell': journalWentWell,
      'journalWastedTime': journalWastedTime,
      'journalImprove': journalImprove,
      'xpEarned': xpEarned,
      'isPerfectDay': isPerfectDay,
      'createdAt': createdAt.toUtc().toIso8601String(),
    };
  }

  factory DayEntry.fromMap(Map<String, dynamic> map) {
    return DayEntry(
      dateKey: map['dateKey'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String).toLocal(),
      completedMissions: List<String>.from(map['completedMissions'] ?? []),
      waterIntakeLiters: (map['waterIntakeLiters'] as num?)?.toDouble() ?? 0,
      workoutCompleted: map['workoutCompleted'] as bool? ?? false,
      focusMinutes: map['focusMinutes'] as int? ?? 0,
      instagramMinutes: map['instagramMinutes'] as int? ?? 0,
      youtubeMinutes: map['youtubeMinutes'] as int? ?? 0,
      journalWentWell: map['journalWentWell'] as String? ?? '',
      journalWastedTime: map['journalWastedTime'] as String? ?? '',
      journalImprove: map['journalImprove'] as String? ?? '',
      xpEarned: map['xpEarned'] as int? ?? 0,
      isPerfectDay: map['isPerfectDay'] as bool? ?? false,
    );
  }

  // ── Computed ────────────────────────────────────────────────────────────────
  double get completionPercentage {
    // 6 missions + water + workout + journal = 9 items
    int completed = completedMissions.length;
    if (waterIntakeLiters >= 3.0) completed++;
    if (workoutCompleted) completed++;
    if (journalWentWell.isNotEmpty) completed++;
    return (completed / 9.0).clamp(0.0, 1.0);
  }

  String get dateDisplay {
    final parts = dateKey.split('-');
    final months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${parts[2]} ${months[int.parse(parts[1])]}';
  }
}

