import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/widgets.dart';
import '../../../data/providers/lifeos_provider.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  final TextEditingController _nameController = TextEditingController();
  int _currentPage = 0;

  final List<_OnboardSlide> _slides = [
    _OnboardSlide(
      emoji: '🚀',
      title: 'Welcome to LifeOS',
      subtitle: 'Your Futuristic\nSelf-Improvement OS',
      body: 'Build discipline, track growth, and unlock your highest self — one day at a time.',
      accent: AppTheme.neonGreen,
    ),
    _OnboardSlide(
      emoji: '⚡',
      title: 'Daily Flow System',
      subtitle: 'Step-by-Step\nDaily Missions',
      body: 'Move through focused daily screens: missions, hydration, workouts, deep focus, journaling.',
      accent: AppTheme.neonBlue,
    ),
    _OnboardSlide(
      emoji: '🏆',
      title: 'XP & Level Up',
      subtitle: 'Gamified\nSelf-Growth',
      body: 'Earn XP for every good habit. Level up, unlock achievements, and build unstoppable streaks.',
      accent: AppTheme.neonPurple,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _slides.length) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  Future<void> _complete() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your name'), backgroundColor: AppTheme.errorColor),
      );
      return;
    }
    final provider = context.read<LifeOSProvider>();
    await provider.setUserName(name);
    await provider.completeOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: Stack(
          children: [
            _buildBackgroundParticles(),
            Column(
              children: [
                const SizedBox(height: 60),
                _buildDots(),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (i) => setState(() => _currentPage = i),
                    itemCount: _slides.length + 1,
                    itemBuilder: (context, index) {
                      if (index < _slides.length) {
                        return _buildSlide(_slides[index]);
                      }
                      return _buildNameScreen();
                    },
                  ),
                ),
                _buildBottomNav(),
                const SizedBox(height: 48),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundParticles() {
    return Positioned.fill(
      child: CustomPaint(painter: _ParticlePainter()),
    );
  }

  Widget _buildDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_slides.length + 1, (i) {
        final active = i == _currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: active ? AppTheme.neonGreen : AppTheme.textMuted,
            borderRadius: BorderRadius.circular(4),
            boxShadow: active ? AppTheme.neonGlow : null,
          ),
        );
      }),
    );
  }

  Widget _buildSlide(_OnboardSlide slide) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [slide.accent.withOpacity(0.2), slide.accent.withOpacity(0.05)],
              ),
              border: Border.all(color: slide.accent.withOpacity(0.3), width: 2),
            ),
            child: Center(
              child: Text(slide.emoji, style: const TextStyle(fontSize: 52)),
            ),
          ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
          const SizedBox(height: 40),
          Text(
            slide.title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: slide.accent,
              letterSpacing: 3,
            ),
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 12),
          Text(
            slide.subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
              height: 1.2,
            ),
          ).animate().slideY(begin: 0.3, delay: 300.ms, duration: 500.ms),
          const SizedBox(height: 20),
          Text(
            slide.body,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: AppTheme.textSecondary,
              height: 1.6,
            ),
          ).animate().fadeIn(delay: 400.ms),
        ],
      ),
    );
  }

  Widget _buildNameScreen() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('✨', style: TextStyle(fontSize: 52))
              .animate().scale(duration: 600.ms, curve: Curves.elasticOut),
          const SizedBox(height: 32),
          const Text(
            'What should\nwe call you?',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
              height: 1.2,
            ),
          ).animate().slideY(begin: 0.3, duration: 500.ms),
          const SizedBox(height: 12),
          const Text(
            'This will personalize your LifeOS experience.',
            style: TextStyle(fontSize: 16, color: AppTheme.textSecondary),
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 40),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.glassWhite,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.glassBorder),
                ),
                child: TextField(
                  controller: _nameController,
                  autofocus: true,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Your name...',
                    hintStyle: TextStyle(color: AppTheme.textMuted),
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.person_outline, color: AppTheme.neonGreen),
                  ),
                ),
              ),
            ),
          ).animate().fadeIn(delay: 300.ms),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    final isLast = _currentPage == _slides.length;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          NeonButton(
            label: isLast ? 'Begin My Journey 🚀' : 'Continue',
            onPressed: isLast ? _complete : _nextPage,
          ),
          if (!isLast) ...[
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () {
                _pageController.jumpToPage(_slides.length);
              },
              child: const Text(
                'Skip',
                style: TextStyle(color: AppTheme.textMuted, fontSize: 14),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _OnboardSlide {
  final String emoji;
  final String title;
  final String subtitle;
  final String body;
  final Color accent;
  const _OnboardSlide({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.body,
    required this.accent,
  });
}

class _ParticlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppTheme.neonGreen.withOpacity(0.04);
    final positions = [
      Offset(size.width * 0.1, size.height * 0.2),
      Offset(size.width * 0.9, size.height * 0.15),
      Offset(size.width * 0.5, size.height * 0.5),
      Offset(size.width * 0.15, size.height * 0.7),
      Offset(size.width * 0.85, size.height * 0.8),
    ];
    for (final pos in positions) {
      canvas.drawCircle(pos, 80, paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
