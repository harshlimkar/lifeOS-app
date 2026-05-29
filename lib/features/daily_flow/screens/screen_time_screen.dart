import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/widgets.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/providers/lifeos_provider.dart';

class ScreenTimeScreen extends StatefulWidget {
  const ScreenTimeScreen({super.key});

  @override
  State<ScreenTimeScreen> createState() => _ScreenTimeScreenState();
}

class _ScreenTimeScreenState extends State<ScreenTimeScreen> {
  late TextEditingController _instagramController;
  late TextEditingController _youtubeController;

  @override
  void initState() {
    super.initState();
    final provider = context.read<LifeOSProvider>();
    _instagramController = TextEditingController(
        text: provider.todayEntry?.instagramMinutes.toString() ?? '0');
    _youtubeController = TextEditingController(
        text: provider.todayEntry?.youtubeMinutes.toString() ?? '0');
  }

  @override
  void dispose() {
    _instagramController.dispose();
    _youtubeController.dispose();
    super.dispose();
  }

  void _save() {
    final ig = int.tryParse(_instagramController.text) ?? 0;
    final yt = int.tryParse(_youtubeController.text) ?? 0;
    context.read<LifeOSProvider>().setScreenTime(ig, yt);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LifeOSProvider>();
    final ig = provider.todayEntry?.instagramMinutes ?? 0;
    final yt = provider.todayEntry?.youtubeMinutes ?? 0;
    final total = ig + yt;
    final igProgress = (ig / AppConstants.instagramLimitMinutes).clamp(0.0, 1.0);
    final ytProgress = (yt / AppConstants.youtubeLimitMinutes).clamp(0.0, 1.0);
    final igOver = ig > AppConstants.instagramLimitMinutes;
    final ytOver = yt > AppConstants.youtubeLimitMinutes;

    String productivityRating;
    Color ratingColor;
    String ratingEmoji;
    if (total < 30) {
      productivityRating = 'EXCELLENT';
      ratingColor = AppTheme.neonGreen;
      ratingEmoji = '🌟';
    } else if (total < 60) {
      productivityRating = 'GOOD';
      ratingColor = AppTheme.neonBlue;
      ratingEmoji = '✅';
    } else if (total < 90) {
      productivityRating = 'AVERAGE';
      ratingColor = AppTheme.warningColor;
      ratingEmoji = '⚠️';
    } else {
      productivityRating = 'NEEDS WORK';
      ratingColor = AppTheme.errorColor;
      ratingEmoji = '🔴';
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Screen Time',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
          ).animate().slideY(begin: -0.2, duration: 400.ms),
          const SizedBox(height: 4),
          const Text(
            'Track social media usage. Reclaim your focus.',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
          ).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 20),

          // Productivity Rating
          GlassCard(
            borderColor: ratingColor.withOpacity(0.4),
            backgroundColor: ratingColor.withOpacity(0.05),
            child: Row(
              children: [
                Text(ratingEmoji, style: const TextStyle(fontSize: 36)),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PRODUCTIVITY RATING',
                      style: TextStyle(color: ratingColor.withOpacity(0.7), fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.5),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      productivityRating,
                      style: TextStyle(color: ratingColor, fontWeight: FontWeight.w800, fontSize: 22),
                    ),
                    Text('${total}min total screen time today',
                        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ).animate().fadeIn(delay: 150.ms),

          const SizedBox(height: 20),

          // Instagram Input
          _AppTimeCard(
            appName: 'Instagram',
            emoji: '📸',
            color: const Color(0xFFE1306C),
            controller: _instagramController,
            limitMinutes: AppConstants.instagramLimitMinutes,
            currentMinutes: ig,
            progress: igProgress,
            isOver: igOver,
            onChanged: (_) => _save(),
            hint: _buildQuickAdd((v) {
              final current = int.tryParse(_instagramController.text) ?? 0;
              _instagramController.text = (current + v).toString();
              _save();
            }),
          ).animate().slideX(begin: -0.2, delay: 200.ms, duration: 450.ms),

          const SizedBox(height: 16),

          // YouTube Input
          _AppTimeCard(
            appName: 'YouTube',
            emoji: '▶️',
            color: const Color(0xFFFF0000),
            controller: _youtubeController,
            limitMinutes: AppConstants.youtubeLimitMinutes,
            currentMinutes: yt,
            progress: ytProgress,
            isOver: ytOver,
            onChanged: (_) => _save(),
            hint: _buildQuickAdd((v) {
              final current = int.tryParse(_youtubeController.text) ?? 0;
              _youtubeController.text = (current + v).toString();
              _save();
            }),
          ).animate().slideX(begin: 0.2, delay: 300.ms, duration: 450.ms),

          const SizedBox(height: 20),

          // Tips
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('🧠 DIGITAL DISCIPLINE TIPS',
                    style: TextStyle(color: AppTheme.neonGreen, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
                const SizedBox(height: 12),
                ...const [
                  '• Use grayscale mode to reduce app appeal',
                  '• Delete social apps from your home screen',
                  '• Replace scroll time with reading or walking',
                  '• Every 30min saved = focus you can invest',
                ].map((tip) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(tip, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                    )),
              ],
            ),
          ).animate().fadeIn(delay: 400.ms),
        ],
      ),
    );
  }

  Widget _buildQuickAdd(Function(int) onAdd) {
    return Row(
      children: [15, 30, 60].map((v) {
        return GestureDetector(
          onTap: () => onAdd(v),
          child: Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.surfaceLight,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.glassBorder),
            ),
            child: Text('+${v}m',
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
          ),
        );
      }).toList(),
    );
  }
}

class _AppTimeCard extends StatelessWidget {
  final String appName;
  final String emoji;
  final Color color;
  final TextEditingController controller;
  final int limitMinutes;
  final int currentMinutes;
  final double progress;
  final bool isOver;
  final Function(String) onChanged;
  final Widget hint;

  const _AppTimeCard({
    required this.appName,
    required this.emoji,
    required this.color,
    required this.controller,
    required this.limitMinutes,
    required this.currentMinutes,
    required this.progress,
    required this.isOver,
    required this.onChanged,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderColor: isOver ? AppTheme.errorColor.withOpacity(0.4) : color.withOpacity(0.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(appName,
                      style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w700, fontSize: 16)),
                  Text('Limit: ${limitMinutes}min',
                      style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                ],
              ),
              const Spacer(),
              if (isOver)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.errorColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('OVER LIMIT', style: TextStyle(color: AppTheme.errorColor, fontSize: 10, fontWeight: FontWeight.w700)),
                ),
            ],
          ),
          const SizedBox(height: 12),
          NeonProgressBar(
            value: progress,
            height: 8,
            color: isOver ? AppTheme.errorColor : color,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text('${currentMinutes}min used',
                  style: TextStyle(color: isOver ? AppTheme.errorColor : AppTheme.textSecondary, fontSize: 12)),
              const Spacer(),
              Text('${(progress * 100).round()}%',
                  style: TextStyle(color: isOver ? AppTheme.errorColor : color, fontWeight: FontWeight.w700, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            onChanged: onChanged,
            style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              labelText: 'Minutes spent',
              labelStyle: const TextStyle(color: AppTheme.textMuted),
              suffixText: 'min',
              suffixStyle: const TextStyle(color: AppTheme.textMuted),
              filled: true,
              fillColor: AppTheme.surfaceLight,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          const SizedBox(height: 8),
          hint,
        ],
      ),
    );
  }
}
