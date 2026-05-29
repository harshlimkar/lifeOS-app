class AppConstants {
  // XP System
  static const int xpPerMission = 50;
  static const int xpPerWaterGoal = 30;
  static const int xpPerWorkout = 80;
  static const int xpPerFocusSession = 60;
  static const int xpPerJournal = 40;
  static const int xpPerfectDayBonus = 200;
  static const int xpPerfectWeekBonus = 500;

  static const List<int> levelThresholds = [
    0, 200, 500, 900, 1400, 2000, 2700, 3500, 4400, 5400,
    6500, 7700, 9000, 10400, 12000,
  ];

  static const List<String> levelTitles = [
    'Beginner', 'Apprentice', 'Seeker', 'Explorer', 'Warrior',
    'Champion', 'Master', 'Elite', 'Legend', 'Apex',
    'Titan', 'Immortal', 'Mythic', 'Transcendent', 'LifeOS God',
  ];

  // Water Tracking
  static const double dailyWaterGoalLiters = 3.0;
  static const double waterIncrementLiters = 0.25;

  // Focus Timer
  static const int focusDurationMinutes = 25;
  static const int shortBreakMinutes = 5;
  static const int longBreakMinutes = 15;

  // Motivational Quotes
  static const List<String> motivationalQuotes = [
    "The only bad workout is the one that didn't happen.",
    "Discipline is the bridge between goals and accomplishment.",
    "Small daily improvements lead to staggering long-term results.",
    "Your future self is watching you right now through your memories.",
    "The pain of discipline is far less than the pain of regret.",
    "Every expert was once a beginner. Every pro was once an amateur.",
    "Success is the sum of small efforts repeated day in and day out.",
    "Don't stop when you're tired. Stop when you're done.",
    "The secret of getting ahead is getting started.",
    "You don't have to be extreme, just consistent.",
    "Fall in love with the process and results will come.",
    "Push yourself because no one else is going to do it for you.",
    "One more rep. One more page. One more step.",
    "Be the energy you want to attract.",
    "Champions are made in the moments they want to quit.",
  ];

  // Workout Split
  static const Map<String, String> workoutSplit = {
    'Monday': 'Chest + Triceps',
    'Tuesday': 'Back + Biceps',
    'Wednesday': 'Shoulders + Core',
    'Thursday': 'Legs (Quads + Glutes)',
    'Friday': 'Arms + Chest Finisher',
    'Saturday': 'Full Body / Cardio',
    'Sunday': 'Active Recovery / Rest',
  };

  static const Map<String, List<String>> workoutExercises = {
    'Chest + Triceps': ['Bench Press 4×8', 'Incline DB Press 3×10', 'Cable Flyes 3×12', 'Tricep Pushdowns 4×12', 'Skull Crushers 3×10', 'Dips to Failure'],
    'Back + Biceps': ['Deadlifts 4×5', 'Pull-Ups 4×8', 'Barbell Rows 4×8', 'Lat Pulldowns 3×12', 'Barbell Curls 4×10', 'Hammer Curls 3×12'],
    'Shoulders + Core': ['Overhead Press 4×8', 'Lateral Raises 4×15', 'Face Pulls 3×15', 'Planks 3×60s', 'Cable Crunches 3×15', 'Leg Raises 3×15'],
    'Legs (Quads + Glutes)': ['Squats 4×6', 'Romanian Deadlifts 3×10', 'Leg Press 4×12', 'Lunges 3×12', 'Hip Thrusts 4×12', 'Calf Raises 4×20'],
    'Arms + Chest Finisher': ['EZ Bar Curls 4×10', 'Tricep Overhead Extension 4×10', 'Preacher Curls 3×12', 'Tricep Dips 3×12', 'Push-Ups 3×20', 'Cable Curls 3×15'],
    'Full Body / Cardio': ['Burpees 4×15', 'Jump Squats 3×20', 'Mountain Climbers 3×30s', 'KB Swings 4×15', 'Box Jumps 3×10', '20 min HIIT Cardio'],
    'Active Recovery / Rest': ['Light Stretching 15min', 'Yoga Flow 20min', 'Walk 30min', 'Foam Rolling 10min', 'Mobility Work 15min'],
  };

  // Screen Time Limits
  static const int instagramLimitMinutes = 30;
  static const int youtubeLimitMinutes = 60;

  // Achievements
  static const List<Map<String, dynamic>> achievements = [
    {'id': 'first_day', 'title': 'Day Zero', 'desc': 'Complete your first day', 'icon': '🚀', 'xp': 100},
    {'id': 'streak_3', 'title': 'Momentum', 'desc': '3-day streak', 'icon': '🔥', 'xp': 150},
    {'id': 'streak_7', 'title': '7 Day Warrior', 'desc': 'Complete 7 days in a row', 'icon': '⚡', 'xp': 300},
    {'id': 'streak_30', 'title': 'Consistency Champion', 'desc': '30-day streak achieved', 'icon': '👑', 'xp': 1000},
    {'id': 'perfect_day', 'title': 'Perfect Day', 'desc': 'Complete all daily missions', 'icon': '✨', 'xp': 200},
    {'id': 'perfect_week', 'title': 'Perfect Week', 'desc': 'All missions for 7 days', 'icon': '🏆', 'xp': 500},
    {'id': 'hydration_master', 'title': 'Hydration Master', 'desc': 'Hit water goal 7 days', 'icon': '💧', 'xp': 200},
    {'id': 'deep_focus', 'title': 'Deep Focus', 'desc': 'Complete 10 Pomodoros', 'icon': '🎯', 'xp': 250},
    {'id': 'gym_warrior', 'title': 'Gym Warrior', 'desc': 'Work out 20 times', 'icon': '💪', 'xp': 400},
    {'id': 'journal_sage', 'title': 'Journal Sage', 'desc': 'Write 14 journal entries', 'icon': '📖', 'xp': 300},
  ];
}
