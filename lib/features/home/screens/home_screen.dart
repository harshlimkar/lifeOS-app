import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/widgets.dart';
import '../../../data/providers/lifeos_provider.dart';
import '../../daily_flow/screens/daily_flow_screen.dart';
import '../../analytics/screens/analytics_screen.dart';
import '../../achievements/screens/achievements_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTab = 0;

  final List<Widget> _tabs = const [
    _HomeTab(),
    AnalyticsScreen(),
    AchievementsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      extendBody: true,
      body: IndexedStack(index: _selectedTab, children: _tabs),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppTheme.glassBorder),
        boxShadow: [
          BoxShadow(
            color: AppTheme.neonGreen.withOpacity(0.05),
            blurRadius: 20,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 20,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(icon: Icons.home_rounded, label: 'Home', index: 0, selected: _selectedTab == 0, onTap: () => setState(() => _selectedTab = 0)),
          _NavItem(icon: Icons.bar_chart_rounded, label: 'Analytics', index: 1, selected: _selectedTab == 1, onTap: () => setState(() => _selectedTab = 1)),
          _NavItem(icon: Icons.emoji_events_rounded, label: 'Trophies', index: 2, selected: _selectedTab == 2, onTap: () => setState(() => _selectedTab = 2)),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppTheme.neonGreen.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: selected ? AppTheme.neonGreen : AppTheme.textMuted,
              size: 22,
            ),
            if (selected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: AppTheme.neonGreen,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LifeOSProvider>();
    final now = DateTime.now();
    final greeting = _getGreeting(now.hour);
    final dayName = DateFormat('EEEE').format(now);
    final dateStr = DateFormat('MMMM d, yyyy').format(now);

    return Container(
      decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
      child: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/images/logo.png',
                          width: 42,
                          height: 42,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                greeting,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.textSecondary,
                                  letterSpacing: 1,
                                ),
                              ),
                              Text(
                                provider.userName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ).animate().slideX(begin: -0.2, duration: 500.ms),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.neonGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.neonGreen.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.local_fire_department_rounded, color: AppTheme.neonGreen, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${provider.currentStreak}d',
                          style: const TextStyle(
                            color: AppTheme.neonGreen,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ).animate().slideX(begin: 0.2, duration: 500.ms),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '$dayName · $dateStr',
                style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
              ).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 28),

              // Level Card
              _LevelCard(provider: provider).animate().slideY(begin: 0.2, delay: 100.ms, duration: 500.ms),
              const SizedBox(height: 16),

              // Stats Row
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'Level',
                      value: '${provider.currentLevel}',
                      subtitle: provider.levelTitle,
                      icon: Icons.star_rounded,
                      color: AppTheme.warningColor,
                    ).animate().slideY(begin: 0.2, delay: 200.ms, duration: 500.ms),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      label: 'Streak',
                      value: '${provider.currentStreak}',
                      subtitle: 'days 🔥',
                      icon: Icons.local_fire_department_rounded,
                      color: Colors.orange,
                    ).animate().slideY(begin: 0.2, delay: 300.ms, duration: 500.ms),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      label: 'Total XP',
                      value: '${provider.totalXP}',
                      subtitle: '${provider.xpToNextLevel} to next',
                      icon: Icons.bolt_rounded,
                      color: AppTheme.neonGreen,
                    ).animate().slideY(begin: 0.2, delay: 400.ms, duration: 500.ms),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Quote Card
              _QuoteCard(quote: provider.motivationalQuote)
                  .animate().fadeIn(delay: 500.ms, duration: 600.ms),
              const SizedBox(height: 24),

              // Today's workout preview
              _WorkoutPreviewCard(
                workout: provider.todayWorkout,
                completed: provider.todayEntry?.workoutCompleted ?? false,
              ).animate().slideY(begin: 0.2, delay: 600.ms, duration: 500.ms),
              const SizedBox(height: 28),

              // Start Today Button
              if (!provider.flowCompleted)
                NeonButton(
                  label: 'Start Today\'s Flow ⚡',
                  icon: Icons.play_arrow_rounded,
                  onPressed: () {
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        pageBuilder: (_, a, __) => const DailyFlowScreen(),
                        transitionsBuilder: (_, a, __, child) {
                          return SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(1, 0),
                              end: Offset.zero,
                            ).animate(CurvedAnimation(parent: a, curve: Curves.easeInOutCubic)),
                            child: child,
                          );
                        },
                        transitionDuration: const Duration(milliseconds: 400),
                      ),
                    );
                  },
                ).animate().scale(delay: 700.ms, duration: 400.ms, curve: Curves.elasticOut)
              else
                _CompletedBanner().animate().fadeIn(delay: 300.ms),
            ],
          ),
        ),
      ),
    );
  }

  String _getGreeting(int hour) {
    if (hour < 12) return 'GOOD MORNING';
    if (hour < 17) return 'GOOD AFTERNOON';
    if (hour < 21) return 'GOOD EVENING';
    return 'GOOD NIGHT';
  }
}

class _LevelCard extends StatelessWidget {
  final LifeOSProvider provider;
  const _LevelCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Lv. ${provider.currentLevel} · ${provider.levelTitle}',
                    style: const TextStyle(
                      color: AppTheme.neonGreen,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${provider.totalXP} XP total',
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 22,
                    ),
                  ),
                ],
              ),
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppTheme.neonGreenGradient,
                  boxShadow: AppTheme.neonGlow,
                ),
                child: Center(
                  child: Text(
                    '${provider.currentLevel}',
                    style: const TextStyle(
                      color: AppTheme.background,
                      fontWeight: FontWeight.w900,
                      fontSize: 22,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          NeonProgressBar(value: provider.xpProgress, height: 10),
          const SizedBox(height: 8),
          Text(
            '${provider.xpToNextLevel} XP to level ${provider.currentLevel + 1}',
            style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 24,
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(color: AppTheme.textMuted, fontSize: 10),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuoteCard extends StatelessWidget {
  final String quote;
  const _QuoteCard({required this.quote});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderColor: AppTheme.neonGreen.withOpacity(0.2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('💬', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'DAILY WISDOM',
                  style: TextStyle(
                    color: AppTheme.neonGreen,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '"$quote"',
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkoutPreviewCard extends StatelessWidget {
  final String workout;
  final bool completed;
  const _WorkoutPreviewCard({required this.workout, required this.completed});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: completed
                  ? AppTheme.neonGreen.withOpacity(0.2)
                  : AppTheme.surfaceLight,
            ),
            child: Icon(
              completed ? Icons.check_circle_rounded : Icons.fitness_center_rounded,
              color: completed ? AppTheme.neonGreen : AppTheme.textSecondary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "TODAY'S WORKOUT",
                  style: TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  workout,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          if (completed)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.neonGreen.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Done ✓',
                style: TextStyle(
                  color: AppTheme.neonGreen,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CompletedBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderColor: AppTheme.neonGreen.withOpacity(0.4),
      backgroundColor: AppTheme.neonGreen.withOpacity(0.08),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Text('✅', style: TextStyle(fontSize: 24)),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "TODAY'S FLOW COMPLETE!",
                style: TextStyle(
                  color: AppTheme.neonGreen,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  letterSpacing: 1,
                ),
              ),
              Text(
                "Come back tomorrow. Keep the streak! 🔥",
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
