import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:async';
import 'dart:math' as math;
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/widgets.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/providers/lifeos_provider.dart';

class FocusScreen extends StatefulWidget {
  const FocusScreen({super.key});

  @override
  State<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends State<FocusScreen> with SingleTickerProviderStateMixin {
  Timer? _timer;
  int _secondsRemaining = AppConstants.focusDurationMinutes * 60;
  bool _isRunning = false;
  bool _isBreak = false;
  int _sessionsCompleted = 0;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _startTimer() {
    setState(() => _isRunning = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        _onTimerComplete();
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() => _isRunning = false);
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _isBreak = false;
      _secondsRemaining = AppConstants.focusDurationMinutes * 60;
    });
  }

  void _onTimerComplete() {
    _timer?.cancel();
    if (!_isBreak) {
      // Completed a focus session
      _sessionsCompleted++;
      context.read<LifeOSProvider>().addFocusMinutes(AppConstants.focusDurationMinutes);
      setState(() {
        _isRunning = false;
        _isBreak = true;
        _secondsRemaining = (_sessionsCompleted % 4 == 0
            ? AppConstants.longBreakMinutes
            : AppConstants.shortBreakMinutes) * 60;
      });
      _showSessionComplete();
    } else {
      setState(() {
        _isRunning = false;
        _isBreak = false;
        _secondsRemaining = AppConstants.focusDurationMinutes * 60;
      });
    }
  }

  void _showSessionComplete() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎯', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            const Text('Focus Session Complete!',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w700, fontSize: 18)),
            const SizedBox(height: 8),
            Text('+${AppConstants.xpPerFocusSession} XP earned',
                style: const TextStyle(color: AppTheme.neonGreen, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text('$_sessionsCompleted sessions today',
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
            const SizedBox(height: 20),
            NeonButton(label: 'Take a Break 🧘', onPressed: () {
              Navigator.pop(context);
              _startTimer();
            }),
          ],
        ),
      ),
    );
  }

  String get _timeDisplay {
    final m = _secondsRemaining ~/ 60;
    final s = _secondsRemaining % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  double get _timerProgress {
    final total = _isBreak
        ? (_sessionsCompleted % 4 == 0 ? AppConstants.longBreakMinutes : AppConstants.shortBreakMinutes) * 60
        : AppConstants.focusDurationMinutes * 60;
    return 1 - (_secondsRemaining / total);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LifeOSProvider>();
    final totalFocusMinutes = provider.todayEntry?.focusMinutes ?? 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Deep Focus',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
          ).animate().slideY(begin: -0.2, duration: 400.ms),
          const SizedBox(height: 4),
          Text(
            _isBreak ? 'Rest your mind. You earned it.' : 'Eliminate distractions. Enter flow state.',
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
          ).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 32),

          // Timer Ring
          Center(
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                final glow = _isRunning ? 0.3 + _pulseController.value * 0.2 : 0.15;
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer glow
                    if (_isRunning)
                      Container(
                        width: 220 + _pulseController.value * 20,
                        height: 220 + _pulseController.value * 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: (_isBreak ? AppTheme.neonBlue : AppTheme.neonGreen).withOpacity(glow),
                              blurRadius: 40,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                      ),
                    SizedBox(
                      width: 220,
                      height: 220,
                      child: CustomPaint(
                        painter: _TimerRingPainter(
                          progress: _timerProgress,
                          color: _isBreak ? AppTheme.neonBlue : AppTheme.neonGreen,
                        ),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _timeDisplay,
                                style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 44,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -2,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _isBreak ? '☕ BREAK' : '🎯 FOCUS',
                                style: TextStyle(
                                  color: _isBreak ? AppTheme.neonBlue : AppTheme.neonGreen,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ).animate().scale(delay: 200.ms, duration: 600.ms, curve: Curves.elasticOut),

          const SizedBox(height: 32),

          // Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ControlBtn(
                icon: Icons.refresh_rounded,
                onTap: _resetTimer,
                color: AppTheme.textMuted,
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: _isRunning ? _pauseTimer : _startTimer,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        (_isBreak ? AppTheme.neonBlue : AppTheme.neonGreen),
                        (_isBreak ? AppTheme.neonBlue : AppTheme.neonGreen).withOpacity(0.7),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (_isBreak ? AppTheme.neonBlue : AppTheme.neonGreen).withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: Icon(
                    _isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: AppTheme.background,
                    size: 36,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              _ControlBtn(
                icon: Icons.skip_next_rounded,
                onTap: _onTimerComplete,
                color: AppTheme.textMuted,
              ),
            ],
          ).animate().fadeIn(delay: 300.ms),

          const SizedBox(height: 32),

          // Stats Row
          Row(
            children: [
              Expanded(
                child: GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('🎯', style: TextStyle(fontSize: 20)),
                      const SizedBox(height: 8),
                      Text(
                        '$_sessionsCompleted',
                        style: const TextStyle(color: AppTheme.neonGreen, fontSize: 28, fontWeight: FontWeight.w800),
                      ),
                      const Text('Sessions today', style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('⏱️', style: TextStyle(fontSize: 20)),
                      const SizedBox(height: 8),
                      Text(
                        '${totalFocusMinutes}m',
                        style: const TextStyle(color: AppTheme.neonBlue, fontSize: 28, fontWeight: FontWeight.w800),
                      ),
                      const Text('Focus today', style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('⚡', style: TextStyle(fontSize: 20)),
                      const SizedBox(height: 8),
                      Text(
                        '+${_sessionsCompleted * AppConstants.xpPerFocusSession}',
                        style: const TextStyle(color: AppTheme.warningColor, fontSize: 28, fontWeight: FontWeight.w800),
                      ),
                      const Text('XP earned', style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                    ],
                  ),
                ),
              ),
            ],
          ).animate().slideY(begin: 0.3, delay: 400.ms, duration: 500.ms),
        ],
      ),
    );
  }
}

class _ControlBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  const _ControlBtn({required this.icon, required this.onTap, required this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppTheme.surfaceLight,
          border: Border.all(color: AppTheme.glassBorder),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
    );
  }
}

class _TimerRingPainter extends CustomPainter {
  final double progress;
  final Color color;

  _TimerRingPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 16) / 2;

    // Background ring
    final bgPaint = Paint()
      ..color = AppTheme.surfaceLight
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12;
    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round
      ..shader = LinearGradient(
        colors: [color, color.withOpacity(0.6)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      paint,
    );

    // Glow paint
    if (progress > 0) {
      final glowPaint = Paint()
        ..color = color.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 20
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        glowPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _TimerRingPainter old) =>
      old.progress != progress || old.color != color;
}
