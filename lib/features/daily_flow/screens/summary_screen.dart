import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/widgets.dart';
import '../../../data/providers/lifeos_provider.dart';
import '../../home/screens/home_screen.dart';

class SummaryScreen extends StatefulWidget {
  const SummaryScreen({super.key});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> with TickerProviderStateMixin {
  late AnimationController _confettiController;
  late AnimationController _scoreController;
  late Animation<double> _scoreAnim;

  @override
  void initState() {
    super.initState();
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _scoreController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _scoreAnim = CurvedAnimation(parent: _scoreController, curve: Curves.easeOutCubic);
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _scoreController.forward();
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _scoreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LifeOSProvider>();
    final entry = provider.todayEntry;
    final isPerfect = entry?.isPerfectDay ?? false;
    final xp = entry?.xpEarned ?? 0;
    final score = entry?.completionPercentage ?? 0;
    final perfectWeek = provider.checkPerfectWeek();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          // Animated background
          const _AnimatedBackground(),

          // Confetti if perfect day
          if (isPerfect)
            AnimatedBuilder(
              animation: _confettiController,
              builder: (_, __) => CustomPaint(
                painter: _ConfettiPainter(progress: _confettiController.value),
                child: const SizedBox.expand(),
              ),
            ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Header
                  if (isPerfect)
                    const Text('🏆', style: TextStyle(fontSize: 64))
                        .animate()
                        .scale(duration: 800.ms, curve: Curves.elasticOut)
                  else
                    Image.asset(
                      'assets/images/logo.png',
                      width: 90,
                      height: 90,
                      fit: BoxFit.contain,
                    )
                        .animate()
                        .scale(duration: 600.ms, curve: Curves.elasticOut),
                  const SizedBox(height: 16),
                  Text(
                    isPerfect ? 'PERFECT DAY!' : 'Day Complete!',
                    style: TextStyle(
                      fontSize: isPerfect ? 32 : 28,
                      fontWeight: FontWeight.w800,
                      color: isPerfect ? AppTheme.neonGreen : AppTheme.textPrimary,
                      letterSpacing: isPerfect ? 2 : 0,
                    ),
                  ).animate().slideY(begin: 0.3, delay: 200.ms, duration: 500.ms),
                  const SizedBox(height: 8),
                  Text(
                    isPerfect
                        ? 'Flawless execution. You are unstoppable! 🔥'
                        : 'Every step counts. Keep building momentum.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 15),
                  ).animate().fadeIn(delay: 300.ms),

                  if (perfectWeek) ...[
                    const SizedBox(height: 16),
                    GlassCard(
                      borderColor: AppTheme.warningColor.withOpacity(0.5),
                      backgroundColor: AppTheme.warningColor.withOpacity(0.05),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('👑', style: TextStyle(fontSize: 28)),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('PERFECT WEEK ACHIEVED!',
                                  style: TextStyle(color: AppTheme.warningColor, fontWeight: FontWeight.w800, fontSize: 15)),
                              const Text('Bonus +500 XP unlocked!',
                                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                    ).animate().scale(delay: 400.ms, duration: 500.ms, curve: Curves.elasticOut),
                  ],

                  const SizedBox(height: 28),

                  // Score Ring
                  AnimatedBuilder(
                    animation: _scoreAnim,
                    builder: (context, child) {
                      final displayScore = score * _scoreAnim.value;
                      return SizedBox(
                        width: 180,
                        height: 180,
                        child: CustomPaint(
                          painter: _ScoreRingPainter(progress: displayScore),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${(displayScore * 100).round()}%',
                                  style: const TextStyle(
                                    fontSize: 40,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                const Text(
                                  'Daily Score',
                                  style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ).animate().scale(delay: 200.ms, duration: 600.ms, curve: Curves.elasticOut),

                  const SizedBox(height: 28),

                  // XP Earned Card
                  GlassCard(
                    borderColor: AppTheme.neonGreen.withOpacity(0.4),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: AppTheme.neonGreenGradient,
                            boxShadow: AppTheme.neonGlow,
                          ),
                          child: const Center(
                            child: Icon(Icons.bolt_rounded, color: AppTheme.background, size: 28),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('XP EARNED TODAY',
                                  style: TextStyle(color: AppTheme.textMuted, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
                              AnimatedBuilder(
                                animation: _scoreAnim,
                                builder: (_, __) => Text(
                                  '+${(xp * _scoreAnim.value).round()} XP',
                                  style: const TextStyle(
                                    color: AppTheme.neonGreen,
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              Text(
                                'Total: ${provider.totalXP} XP · Level ${provider.currentLevel}',
                                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ).animate().slideY(begin: 0.3, delay: 400.ms, duration: 500.ms),

                  const SizedBox(height: 16),

                  // Stats Grid
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.6,
                    children: [
                      _StatTile(
                        label: 'Missions',
                        value: '${entry?.completedMissions.length ?? 0}/6',
                        emoji: '✅',
                        color: AppTheme.neonGreen,
                      ),
                      _StatTile(
                        label: 'Hydration',
                        value: '${entry?.waterIntakeLiters.toStringAsFixed(1) ?? 0}L',
                        emoji: '💧',
                        color: AppTheme.neonBlue,
                      ),
                      _StatTile(
                        label: 'Workout',
                        value: entry?.workoutCompleted == true ? 'Done ✓' : 'Skipped',
                        emoji: '💪',
                        color: Colors.orange,
                      ),
                      _StatTile(
                        label: 'Screen Time',
                        value: '${(entry?.instagramMinutes ?? 0) + (entry?.youtubeMinutes ?? 0)} min',
                        emoji: '📱',
                        color: Colors.redAccent,
                      ),
                      _StatTile(
                        label: 'Streak',
                        value: '${provider.currentStreak}🔥',
                        emoji: '🔥',
                        color: Colors.deepOrange,
                      ),
                      _StatTile(
                        label: 'Journal',
                        value: entry?.journalWentWell.isNotEmpty == true ? 'Done ✓' : 'Skipped',
                        emoji: '📖',
                        color: const Color(0xFFFF69B4),
                      ),
                    ],
                  ).animate().fadeIn(delay: 500.ms),

                  const SizedBox(height: 24),

                  // Level Progress
                  GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Level ${provider.currentLevel} · ${provider.levelTitle}',
                              style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w700, fontSize: 15),
                            ),
                            Text(
                              '${provider.xpToNextLevel} XP to next',
                              style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        NeonProgressBar(value: provider.xpProgress, height: 10),
                      ],
                    ),
                  ).animate().slideY(begin: 0.2, delay: 600.ms, duration: 400.ms),

                  const SizedBox(height: 28),

                  // Home Button
                  NeonButton(
                    label: 'Back to Dashboard',
                    icon: Icons.home_rounded,
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const HomeScreen()),
                        (route) => false,
                      );
                    },
                  ).animate().scale(delay: 700.ms, duration: 400.ms, curve: Curves.elasticOut),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final String emoji;
  final Color color;

  const _StatTile({required this.label, required this.value, required this.emoji, required this.color});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 16)),
        ],
      ),
    );
  }
}

class _ScoreRingPainter extends CustomPainter {
  final double progress;
  _ScoreRingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 20) / 2;

    // Background ring
    final bgPaint = Paint()
      ..color = AppTheme.surfaceLight
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14;
    canvas.drawCircle(center, radius, bgPaint);

    // Score color
    final color = progress >= 0.8
        ? AppTheme.neonGreen
        : progress >= 0.5
            ? AppTheme.warningColor
            : AppTheme.errorColor;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round
      ..shader = LinearGradient(
        colors: [color, color.withOpacity(0.6)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      paint,
    );

    // Glow
    final glowPaint = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 24
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      glowPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ScoreRingPainter old) => old.progress != progress;
}

class _ConfettiPainter extends CustomPainter {
  final double progress;
  _ConfettiPainter({required this.progress});

  final _rnd = math.Random(42);

  @override
  void paint(Canvas canvas, Size size) {
    final colors = [
      AppTheme.neonGreen,
      AppTheme.neonBlue,
      AppTheme.neonPurple,
      AppTheme.warningColor,
      Colors.pinkAccent,
    ];

    for (int i = 0; i < 40; i++) {
      final x = _rnd.nextDouble() * size.width;
      final startY = -20.0;
      final speed = 150 + _rnd.nextDouble() * 200;
      final y = startY + (progress * speed * (1 + _rnd.nextDouble())) % (size.height + 40);
      final color = colors[i % colors.length];
      final paint = Paint()..color = color.withOpacity(0.7);
      final rectW = 6 + _rnd.nextDouble() * 8;
      final rectH = 10 + _rnd.nextDouble() * 8;
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(progress * math.pi * 4 * (i % 2 == 0 ? 1 : -1));
      canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: rectW, height: rectH), paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter old) => old.progress != progress;
}

class _AnimatedBackground extends StatelessWidget {
  const _AnimatedBackground();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: CustomPaint(painter: _BgGlowPainter()),
      ),
    );
  }
}

class _BgGlowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.neonGreen.withOpacity(0.05)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 80);
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.2), 200, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}
