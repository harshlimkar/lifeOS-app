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
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  String _selectedGender = 'Male';
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

  // Total pages = slides.length (3) + name (1) + profile details (1) = 5
  int get _totalPages => _slides.length + 2;

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
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

    // Save profile details if provided
    final heightText = _heightController.text.trim();
    final weightText = _weightController.text.trim();
    final ageText = _ageController.text.trim();
    final height = double.tryParse(heightText);
    final weight = double.tryParse(weightText);
    final age = int.tryParse(ageText);

    if (height != null && weight != null && age != null) {
      await provider.saveProfileDetails(
        heightCm: height,
        weightKg: weight,
        gender: _selectedGender,
        age: age,
      );
    }

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
                    itemCount: _totalPages,
                    itemBuilder: (context, index) {
                      if (index < _slides.length) return _buildSlide(_slides[index]);
                      if (index == _slides.length) return _buildNameScreen();
                      return _buildProfileDetailsScreen();
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
      children: List.generate(_totalPages, (i) {
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
                colors: [slide.accent.withValues(alpha: 0.2), slide.accent.withValues(alpha: 0.05)],
              ),
              border: Border.all(color: slide.accent.withValues(alpha: 0.3), width: 2),
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

  Widget _buildProfileDetailsScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text('💪', style: TextStyle(fontSize: 52))
              .animate().scale(duration: 600.ms, curve: Curves.elasticOut),
          const SizedBox(height: 24),
          const Text(
            'Your Physical\nProfile',
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
              height: 1.2,
            ),
          ).animate().slideY(begin: 0.3, duration: 500.ms),
          const SizedBox(height: 8),
          const Text(
            'Helps personalize your meal plan and fitness goals.',
            style: TextStyle(fontSize: 14, color: AppTheme.textSecondary, height: 1.5),
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 32),

          // Gender selector
          const Text('GENDER', style: TextStyle(color: AppTheme.neonGreen, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 2)),
          const SizedBox(height: 10),
          Row(
            children: ['Male', 'Female'].map((g) {
              final sel = _selectedGender == g;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedGender = g),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: EdgeInsets.only(right: g == 'Male' ? 8 : 0),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: sel ? AppTheme.neonGreen.withValues(alpha: 0.15) : AppTheme.glassWhite,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: sel ? AppTheme.neonGreen : AppTheme.glassBorder, width: sel ? 1.5 : 1),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(g == 'Male' ? '♂' : '♀', style: TextStyle(fontSize: 20, color: sel ? AppTheme.neonGreen : AppTheme.textSecondary)),
                        const SizedBox(width: 8),
                        Text(g, style: TextStyle(color: sel ? AppTheme.neonGreen : AppTheme.textSecondary, fontWeight: FontWeight.w600, fontSize: 15)),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ).animate().fadeIn(delay: 300.ms),
          const SizedBox(height: 20),

          // Age, Height, Weight fields
          Row(
            children: [
              Expanded(child: _buildInputField('AGE', 'yrs', _ageController)),
              const SizedBox(width: 12),
              Expanded(child: _buildInputField('HEIGHT', 'cm', _heightController)),
              const SizedBox(width: 12),
              Expanded(child: _buildInputField('WEIGHT', 'kg', _weightController)),
            ],
          ).animate().fadeIn(delay: 400.ms),
          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.neonBlue.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.neonBlue.withValues(alpha: 0.2)),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: AppTheme.neonBlue, size: 16),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'You can update these anytime from your profile.',
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, height: 1.4),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 500.ms),
        ],
      ),
    );
  }

  Widget _buildInputField(String label, String unit, TextEditingController ctrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppTheme.neonGreen, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.glassWhite,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.glassBorder),
          ),
          child: TextField(
            controller: ctrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              hintText: unit,
              hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNav() {
    final isProfileDetails = _currentPage == _totalPages - 1;
    final isNameScreen = _currentPage == _slides.length;
    final isLast = isProfileDetails;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          NeonButton(
            label: isLast ? 'Begin My Journey 🚀' : 'Continue',
            onPressed: isLast ? _complete : (isNameScreen ? _nextPage : _nextPage),
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
    final paint = Paint()..color = AppTheme.neonGreen.withValues(alpha: 0.04);
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
