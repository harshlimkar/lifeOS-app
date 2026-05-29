import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/widgets.dart';
import '../../../data/providers/lifeos_provider.dart';
import 'missions_screen.dart';
import 'water_screen.dart';
import 'workout_screen.dart';
import 'screen_time_screen.dart';
import 'journal_screen.dart';
import 'summary_screen.dart';

class DailyFlowScreen extends StatefulWidget {
  const DailyFlowScreen({super.key});

  @override
  State<DailyFlowScreen> createState() => _DailyFlowScreenState();
}

class _DailyFlowScreenState extends State<DailyFlowScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _completing = false;

  final int _totalSteps = 5;

  final List<String> _stepLabels = const [
    'Missions',
    'Hydration',
    'Workout',
    'Screen Time',
    'Journal',
  ];

  void _nextPage() {
    if (_currentPage < _totalSteps - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _completeDay();
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOutCubic,
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  Future<void> _completeDay() async {
    setState(() => _completing = true);
    await context.read<LifeOSProvider>().completeDay();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, a, __) => const SummaryScreen(),
          transitionsBuilder: (_, a, __, child) {
            return FadeTransition(
              opacity: CurvedAnimation(parent: a, curve: Curves.easeIn),
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.95, end: 1.0)
                    .animate(CurvedAnimation(parent: a, curve: Curves.easeOut)),
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Top Bar
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: _prevPage,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppTheme.glassWhite,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.glassBorder),
                        ),
                        child: const Icon(
                          Icons.arrow_back_rounded,
                          color: AppTheme.textPrimary,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _stepLabels[_currentPage],
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            'Step ${_currentPage + 1} of $_totalSteps',
                            style: const TextStyle(
                              color: AppTheme.textMuted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: FlowProgressIndicator(
                  currentStep: _currentPage,
                  totalSteps: _totalSteps,
                ),
              ),
              const SizedBox(height: 8),

              // Page View
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  children: const [
                    MissionsScreen(),
                    WaterScreen(),
                    WorkoutScreen(),
                    ScreenTimeScreen(),
                    JournalScreen(),
                  ],
                ),
              ),

              // Bottom Nav
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                child: NeonButton(
                  label: _currentPage < _totalSteps - 1
                      ? 'Continue'
                      : 'Complete Day 🎉',
                  icon: _currentPage < _totalSteps - 1
                      ? Icons.arrow_forward_rounded
                      : Icons.check_circle_rounded,
                  isLoading: _completing,
                  onPressed: _completing ? null : _nextPage,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
