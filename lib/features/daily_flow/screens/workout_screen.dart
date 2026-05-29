import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/widgets.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/providers/lifeos_provider.dart';

class WorkoutScreen extends StatelessWidget {
  const WorkoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LifeOSProvider>();
    final workout = provider.todayWorkout;
    final exercises = provider.todayExercises;
    final completed = provider.todayEntry?.workoutCompleted ?? false;
    final weekday = DateFormat('EEEE').format(DateTime.now());

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Workout Plan',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
              ),
              XPBadge(xp: AppConstants.xpPerWorkout),
            ],
          ).animate().slideY(begin: -0.2, duration: 400.ms),
          const SizedBox(height: 4),
          Text(
            '$weekday — Stay consistent, stay winning.',
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
          ).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 20),

          // Today's Focus
          GlassCard(
            borderColor: Colors.orange.withOpacity(0.4),
            backgroundColor: Colors.orange.withOpacity(0.05),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.orange.withOpacity(0.15),
                    border: Border.all(color: Colors.orange.withOpacity(0.4)),
                  ),
                  child: const Center(child: Text('🔥', style: TextStyle(fontSize: 26))),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('TODAY\'S FOCUS',
                        style: TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 2)),
                    const SizedBox(height: 4),
                    Text(
                      workout,
                      style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w700, fontSize: 20),
                    ),
                  ],
                ),
              ],
            ),
          ).animate().slideX(begin: -0.2, delay: 150.ms, duration: 450.ms),

          const SizedBox(height: 20),

          // Exercise List
          const Text(
            'EXERCISE LIST',
            style: TextStyle(color: AppTheme.textMuted, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 2),
          ),
          const SizedBox(height: 12),
          ...List.generate(exercises.length, (i) {
            return _ExerciseTile(exercise: exercises[i], index: i)
                .animate()
                .slideX(begin: 0.2, delay: Duration(milliseconds: 200 + i * 60), duration: 400.ms);
          }),

          const SizedBox(height: 20),

          // Weekly Split Preview
          const Text(
            'WEEKLY SPLIT',
            style: TextStyle(color: AppTheme.textMuted, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 2),
          ),
          const SizedBox(height: 12),
          GlassCard(
            child: Column(
              children: AppConstants.workoutSplit.entries.map((e) {
                final isToday = e.key == weekday;
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: AppTheme.glassBorder, width: 0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 90,
                        child: Text(
                          e.key,
                          style: TextStyle(
                            color: isToday ? AppTheme.neonGreen : AppTheme.textSecondary,
                            fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      if (isToday)
                        Container(
                          width: 6,
                          height: 6,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.neonGreen,
                            boxShadow: [BoxShadow(color: AppTheme.neonGreenGlow, blurRadius: 6)],
                          ),
                        ),
                      Expanded(
                        child: Text(
                          e.value,
                          style: TextStyle(
                            color: isToday ? AppTheme.textPrimary : AppTheme.textMuted,
                            fontWeight: isToday ? FontWeight.w600 : FontWeight.w400,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ).animate().fadeIn(delay: 400.ms),

          const SizedBox(height: 20),

          // Mark Complete Button
          GestureDetector(
            onTap: () => context.read<LifeOSProvider>().setWorkoutCompleted(!completed),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: completed
                    ? LinearGradient(colors: [AppTheme.neonGreen.withOpacity(0.2), AppTheme.neonGreen.withOpacity(0.05)])
                    : AppTheme.cardGradient,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: completed ? AppTheme.neonGreen : AppTheme.glassBorder,
                  width: completed ? 1.5 : 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    completed ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                    color: completed ? AppTheme.neonGreen : AppTheme.textMuted,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    completed ? 'Workout Complete! 💪' : 'Mark Workout Done',
                    style: TextStyle(
                      color: completed ? AppTheme.neonGreen : AppTheme.textSecondary,
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                    ),
                  ),
                ],
              ),
            ),
          ).animate().scale(delay: 500.ms, duration: 400.ms, curve: Curves.easeOut),
        ],
      ),
    );
  }
}

class _ExerciseTile extends StatelessWidget {
  final String exercise;
  final int index;

  const _ExerciseTile({required this.exercise, required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.glassBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppTheme.neonGreen.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  color: AppTheme.neonGreen,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            exercise,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
