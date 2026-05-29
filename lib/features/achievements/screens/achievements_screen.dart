import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/widgets.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/providers/lifeos_provider.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LifeOSProvider>();
    final unlocked = provider.unlockedAchievements;
    final allAchievements = AppConstants.achievements;
    final unlockedCount = allAchievements.where((a) => unlocked.contains(a['id'])).length;

    return Container(
      decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
      child: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Achievements', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: AppTheme.textPrimary))
                  .animate().slideY(begin: -0.2, duration: 400.ms),
              const SizedBox(height: 4),
              Text('$unlockedCount of ${allAchievements.length} unlocked — Keep pushing!',
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14))
                  .animate().fadeIn(delay: 100.ms),
              const SizedBox(height: 20),

              // Progress bar
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('OVERALL PROGRESS',
                        style: TextStyle(color: AppTheme.textMuted, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 2)),
                    const SizedBox(height: 12),
                    NeonProgressBar(
                      value: unlockedCount / allAchievements.length,
                      height: 12,
                      color: AppTheme.warningColor,
                    ),
                    const SizedBox(height: 8),
                    Text('$unlockedCount / ${allAchievements.length} Achievements',
                        style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
                  ],
                ),
              ).animate().fadeIn(delay: 150.ms),
              const SizedBox(height: 20),

              // Achievement Grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.9,
                ),
                itemCount: allAchievements.length,
                itemBuilder: (context, i) {
                  final ach = allAchievements[i];
                  final isUnlocked = unlocked.contains(ach['id']);
                  return _AchievementCard(achievement: ach, isUnlocked: isUnlocked)
                      .animate()
                      .scale(
                        delay: Duration(milliseconds: 100 + i * 60),
                        duration: 400.ms,
                        curve: Curves.easeOut,
                      );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final Map<String, dynamic> achievement;
  final bool isUnlocked;

  const _AchievementCard({required this.achievement, required this.isUnlocked});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      borderColor: isUnlocked
          ? AppTheme.warningColor.withOpacity(0.4)
          : AppTheme.glassBorder,
      backgroundColor: isUnlocked
          ? AppTheme.warningColor.withOpacity(0.05)
          : Colors.transparent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isUnlocked
                  ? AppTheme.warningColor.withOpacity(0.15)
                  : AppTheme.surfaceLight,
              border: Border.all(
                color: isUnlocked
                    ? AppTheme.warningColor.withOpacity(0.5)
                    : AppTheme.glassBorder,
                width: 2,
              ),
              boxShadow: isUnlocked
                  ? [BoxShadow(color: AppTheme.warningColor.withOpacity(0.3), blurRadius: 16)]
                  : null,
            ),
            child: Center(
              child: isUnlocked
                  ? Text(achievement['icon'], style: const TextStyle(fontSize: 28))
                  : const Icon(Icons.lock_rounded, color: AppTheme.textMuted, size: 24),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            isUnlocked ? achievement['title'] : '???',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isUnlocked ? AppTheme.textPrimary : AppTheme.textMuted,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isUnlocked ? achievement['desc'] : 'Keep going to unlock',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (isUnlocked) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppTheme.warningColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '+${achievement['xp']} XP',
                style: const TextStyle(color: AppTheme.warningColor, fontWeight: FontWeight.w700, fontSize: 11),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
