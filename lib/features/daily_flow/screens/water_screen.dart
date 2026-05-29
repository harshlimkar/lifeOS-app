import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/widgets.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/providers/lifeos_provider.dart';

class WaterScreen extends StatelessWidget {
  const WaterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LifeOSProvider>();
    final intake = provider.todayEntry?.waterIntakeLiters ?? 0;
    final goal = AppConstants.dailyWaterGoalLiters;
    final progress = (intake / goal).clamp(0.0, 1.0);
    final glasses = (intake / 0.25).round();
    final goalMet = intake >= goal;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hydration',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
          ).animate().slideY(begin: -0.2, duration: 400.ms),
          const SizedBox(height: 4),
          const Text(
            'Track your daily water intake for peak performance',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
          ).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 28),

          // Main Water Display
          Center(
            child: Column(
              children: [
                _WaterBottle(progress: progress)
                    .animate()
                    .scale(delay: 200.ms, duration: 600.ms, curve: Curves.elasticOut),
                const SizedBox(height: 20),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  child: Text(
                    '${intake.toStringAsFixed(2)} L',
                    key: ValueKey(intake),
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w800,
                      color: goalMet ? AppTheme.neonGreen : AppTheme.textPrimary,
                    ),
                  ),
                ),
                Text(
                  'of ${goal.toStringAsFixed(1)}L daily goal',
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 15),
                ),
                const SizedBox(height: 8),
                if (goalMet)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.neonGreen.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.neonGreen.withOpacity(0.4)),
                    ),
                    child: const Text(
                      '🎉 Goal Met! +30 XP',
                      style: TextStyle(
                        color: AppTheme.neonGreen,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ).animate().scale(duration: 300.ms, curve: Curves.elasticOut),
              ],
            ),
          ).animate().fadeIn(delay: 200.ms),

          const SizedBox(height: 28),
          NeonProgressBar(
            value: progress,
            height: 12,
            color: AppTheme.neonBlue,
          ).animate().slideX(begin: -0.5, delay: 300.ms, duration: 600.ms),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$glasses glasses (250ml each)',
                  style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
              Text('${(progress * 100).round()}%',
                  style: const TextStyle(color: AppTheme.neonBlue, fontWeight: FontWeight.w700, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 28),

          // Control Buttons
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ADD WATER',
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 2),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _WaterBtn(
                      label: '+250ml',
                      icon: '🥤',
                      onTap: () => context.read<LifeOSProvider>().addWater(0.25),
                    ),
                    const SizedBox(width: 10),
                    _WaterBtn(
                      label: '+500ml',
                      icon: '🍶',
                      onTap: () => context.read<LifeOSProvider>().addWater(0.5),
                    ),
                    const SizedBox(width: 10),
                    _WaterBtn(
                      label: '+1L',
                      icon: '🫙',
                      onTap: () => context.read<LifeOSProvider>().addWater(1.0),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Center(
                  child: TextButton.icon(
                    onPressed: () => context.read<LifeOSProvider>().removeWater(0.25),
                    icon: const Icon(Icons.remove_circle_outline, color: AppTheme.errorColor, size: 18),
                    label: const Text('Remove 250ml', style: TextStyle(color: AppTheme.errorColor, fontSize: 13)),
                  ),
                ),
              ],
            ),
          ).animate().slideY(begin: 0.3, delay: 400.ms, duration: 500.ms),

          const SizedBox(height: 16),

          // Tips
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('💡 HYDRATION TIPS',
                    style: TextStyle(color: AppTheme.neonBlue, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
                const SizedBox(height: 10),
                ...const [
                  '• Drink a glass first thing in the morning',
                  '• Have water before every meal',
                  '• Set hourly reminders throughout the day',
                  '• Hydration improves focus by up to 30%',
                ].map((tip) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(tip,
                          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                    )),
              ],
            ),
          ).animate().fadeIn(delay: 500.ms),
        ],
      ),
    );
  }
}

class _WaterBtn extends StatelessWidget {
  final String label;
  final String icon;
  final VoidCallback onTap;

  const _WaterBtn({required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: AppTheme.neonBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.neonBlue.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Text(icon, style: const TextStyle(fontSize: 22)),
              const SizedBox(height: 4),
              Text(label,
                  style: const TextStyle(
                    color: AppTheme.neonBlue,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

class _WaterBottle extends StatelessWidget {
  final double progress;
  const _WaterBottle({required this.progress});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 160,
      child: CustomPaint(
        painter: _WaterBottlePainter(progress: progress),
      ),
    );
  }
}

class _WaterBottlePainter extends CustomPainter {
  final double progress;
  _WaterBottlePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final paint = Paint()..style = PaintingStyle.fill;

    // Bottle outline
    final outlinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = AppTheme.neonBlue.withOpacity(0.4)
      ..strokeWidth = 2;

    final bottlePath = Path()
      ..moveTo(w * 0.35, 0)
      ..lineTo(w * 0.65, 0)
      ..lineTo(w * 0.8, h * 0.15)
      ..lineTo(w * 0.8, h)
      ..lineTo(w * 0.2, h)
      ..lineTo(w * 0.2, h * 0.15)
      ..close();

    // Water fill
    final waterH = h - (h * (1 - progress));
    final waterPath = Path()
      ..moveTo(w * 0.2, h)
      ..lineTo(w * 0.8, h)
      ..lineTo(w * 0.8, h - waterH + h * 0.15)
      ..lineTo(w * 0.2, h - waterH + h * 0.15)
      ..close();

    canvas.clipPath(bottlePath);
    paint.color = AppTheme.neonBlue.withOpacity(0.25);
    canvas.drawPath(waterPath, paint);

    // Water shimmer
    paint.shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [AppTheme.neonBlue.withOpacity(0.5), AppTheme.neonBlue.withOpacity(0.2)],
    ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawPath(waterPath, paint);

    canvas.drawPath(bottlePath, outlinePaint);

    // Bubbles
    if (progress > 0) {
      final bubblePaint = Paint()
        ..color = Colors.white.withOpacity(0.3)
        ..style = PaintingStyle.fill;
      final rnd = math.Random(42);
      for (int i = 0; i < 6; i++) {
        final bx = w * 0.3 + rnd.nextDouble() * w * 0.4;
        final by = h - waterH * rnd.nextDouble();
        canvas.drawCircle(Offset(bx, by + h * 0.1), 2 + rnd.nextDouble() * 3, bubblePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _WaterBottlePainter old) => old.progress != progress;
}
