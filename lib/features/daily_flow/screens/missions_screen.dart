import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/widgets.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/providers/lifeos_provider.dart';

class MissionsScreen extends StatelessWidget {
  const MissionsScreen({super.key});

  static const List<Map<String, dynamic>> missions = [
    {'id': 'gym', 'title': 'Hit the Gym', 'desc': 'Complete your workout session', 'icon': '💪', 'xp': 50},
    {'id': 'hydration', 'title': 'Hydration Check', 'desc': 'Drink 3L of water today', 'icon': '💧', 'xp': 30},
    {'id': 'protein', 'title': 'Protein Intake', 'desc': 'Hit your daily protein goal', 'icon': '🥩', 'xp': 30},
    {'id': 'learn', 'title': 'Learn Something New', 'desc': 'Read, watch or study for 20min', 'icon': '📚', 'xp': 50},
    {'id': 'communication', 'title': 'Communication', 'desc': 'Practice speaking or networking', 'icon': '🗣️', 'xp': 40},
    {'id': 'meditation', 'title': 'Mindfulness', 'desc': 'Meditate or practice breathing for 10min', 'icon': '🧘', 'xp': 40},
  ];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LifeOSProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Daily Missions',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ).animate().slideY(begin: -0.2, duration: 400.ms),
          const SizedBox(height: 4),
          const Text(
            'Complete missions to earn XP and build your streak',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
          ).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 20),
          ...List.generate(missions.length, (i) {
            final mission = missions[i];
            final completed = provider.isMissionCompleted(mission['id']);
            return _MissionTile(
              mission: mission,
              completed: completed,
              onToggle: () => provider.toggleMission(mission['id']),
            ).animate().slideX(
              begin: 0.2,
              delay: Duration(milliseconds: 100 + i * 80),
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOut,
            );
          }),
          const SizedBox(height: 20),
          _XPSummaryRow(
            completed: missions
                .where((m) => provider.isMissionCompleted(m['id']))
                .length,
            total: missions.length,
          ).animate().fadeIn(delay: 600.ms),
        ],
      ),
    );
  }
}

class _MissionTile extends StatefulWidget {
  final Map<String, dynamic> mission;
  final bool completed;
  final VoidCallback onToggle;

  const _MissionTile({
    required this.mission,
    required this.completed,
    required this.onToggle,
  });

  @override
  State<_MissionTile> createState() => _MissionTileState();
}

class _MissionTileState extends State<_MissionTile> with SingleTickerProviderStateMixin {
  late AnimationController _bounceController;
  late Animation<double> _bounceAnim;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _bounceAnim = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  void _handleTap() {
    _bounceController.forward().then((_) => _bounceController.reverse());
    widget.onToggle();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _bounceAnim,
      child: GestureDetector(
        onTap: _handleTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: widget.completed
                ? LinearGradient(
                    colors: [
                      AppTheme.neonGreen.withOpacity(0.12),
                      AppTheme.neonGreen.withOpacity(0.05),
                    ],
                  )
                : AppTheme.cardGradient,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: widget.completed
                  ? AppTheme.neonGreen.withOpacity(0.4)
                  : AppTheme.glassBorder,
            ),
            boxShadow: widget.completed ? AppTheme.cardShadow : null,
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.completed
                      ? AppTheme.neonGreen.withOpacity(0.2)
                      : AppTheme.surfaceLight,
                  border: Border.all(
                    color: widget.completed
                        ? AppTheme.neonGreen
                        : AppTheme.glassBorder,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: widget.completed
                      ? const Icon(Icons.check_rounded, color: AppTheme.neonGreen, size: 24)
                      : Text(
                          widget.mission['icon'],
                          style: const TextStyle(fontSize: 22),
                        ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.mission['title'],
                      style: TextStyle(
                        color: widget.completed
                            ? AppTheme.neonGreen
                            : AppTheme.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        decoration: widget.completed
                            ? TextDecoration.lineThrough
                            : null,
                        decorationColor: AppTheme.neonGreen,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.mission['desc'],
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              XPBadge(xp: widget.mission['xp'], compact: true),
            ],
          ),
        ),
      ),
    );
  }
}

class _XPSummaryRow extends StatelessWidget {
  final int completed;
  final int total;

  const _XPSummaryRow({required this.completed, required this.total});

  @override
  Widget build(BuildContext context) {
    final xpEarned = completed * AppConstants.xpPerMission;
    return GlassCard(
      borderColor: AppTheme.neonGreen.withOpacity(0.2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'MISSIONS PROGRESS',
                style: TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$completed / $total completed',
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: 180,
                child: NeonProgressBar(value: completed / total),
              ),
            ],
          ),
          XPBadge(xp: xpEarned),
        ],
      ),
    );
  }
}
