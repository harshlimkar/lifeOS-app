import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/widgets.dart';
import '../../../data/providers/lifeos_provider.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  late TextEditingController _wentWellCtrl;
  late TextEditingController _wastedTimeCtrl;
  late TextEditingController _improveCtrl;
  int _activePrompt = 0;

  final List<Map<String, dynamic>> _prompts = const [
    {
      'question': 'What went well today?',
      'hint': 'Wins, achievements, moments of discipline...',
      'emoji': '✅',
      'color': AppTheme.neonGreen,
      'sublabel': 'Celebrate your progress',
    },
    {
      'question': 'What wasted your time today?',
      'hint': 'Distractions, procrastination, bad habits...',
      'emoji': '⏰',
      'color': AppTheme.warningColor,
      'sublabel': 'Identify what held you back',
    },
    {
      'question': 'What will you improve tomorrow?',
      'hint': 'One action, one commitment...',
      'emoji': '🚀',
      'color': AppTheme.neonBlue,
      'sublabel': 'Set your intention',
    },
  ];

  @override
  void initState() {
    super.initState();
    final provider = context.read<LifeOSProvider>();
    final entry = provider.todayEntry;
    _wentWellCtrl = TextEditingController(text: entry?.journalWentWell ?? '');
    _wastedTimeCtrl = TextEditingController(text: entry?.journalWastedTime ?? '');
    _improveCtrl = TextEditingController(text: entry?.journalImprove ?? '');

    // Auto-save on changes
    for (final ctrl in [_wentWellCtrl, _wastedTimeCtrl, _improveCtrl]) {
      ctrl.addListener(_autoSave);
    }
  }

  void _autoSave() {
    context.read<LifeOSProvider>().saveJournal(
          _wentWellCtrl.text,
          _wastedTimeCtrl.text,
          _improveCtrl.text,
        );
  }

  @override
  void dispose() {
    _wentWellCtrl.dispose();
    _wastedTimeCtrl.dispose();
    _improveCtrl.dispose();
    super.dispose();
  }

  TextEditingController _ctrlForIndex(int i) {
    switch (i) {
      case 0:
        return _wentWellCtrl;
      case 1:
        return _wastedTimeCtrl;
      default:
        return _improveCtrl;
    }
  }

  bool _hasContent(int i) => _ctrlForIndex(i).text.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Daily Reflection',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
          ).animate().slideY(begin: -0.2, duration: 400.ms),
          const SizedBox(height: 4),
          const Text(
            'Reflect, grow, and set tomorrow\'s intention.',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
          ).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 20),

          // Prompt tabs
          Row(
            children: List.generate(_prompts.length, (i) {
              final active = _activePrompt == i;
              final prompt = _prompts[i];
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _activePrompt = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: EdgeInsets.only(right: i < 2 ? 8 : 0),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: active
                          ? (prompt['color'] as Color).withOpacity(0.15)
                          : AppTheme.surfaceLight,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: active
                            ? (prompt['color'] as Color).withOpacity(0.5)
                            : AppTheme.glassBorder,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(prompt['emoji'], style: const TextStyle(fontSize: 18)),
                        const SizedBox(height: 2),
                        if (_hasContent(i))
                          Icon(Icons.check_circle_rounded,
                              color: prompt['color'] as Color, size: 12),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ).animate().fadeIn(delay: 150.ms),

          const SizedBox(height: 20),

          // Active Prompt Card
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            transitionBuilder: (child, anim) => FadeTransition(
              opacity: anim,
              child: SlideTransition(
                position: Tween<Offset>(begin: const Offset(0.05, 0), end: Offset.zero)
                    .animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
                child: child,
              ),
            ),
            child: _PromptCard(
              key: ValueKey(_activePrompt),
              prompt: _prompts[_activePrompt],
              controller: _ctrlForIndex(_activePrompt),
            ),
          ),

          const SizedBox(height: 16),

          // Navigation between prompts
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (_activePrompt > 0)
                TextButton.icon(
                  onPressed: () => setState(() => _activePrompt--),
                  icon: const Icon(Icons.arrow_back_rounded, size: 16),
                  label: const Text('Previous'),
                  style: TextButton.styleFrom(foregroundColor: AppTheme.textSecondary),
                )
              else
                const SizedBox(),
              if (_activePrompt < _prompts.length - 1)
                TextButton.icon(
                  onPressed: () => setState(() => _activePrompt++),
                  icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                  label: const Text('Next Prompt'),
                  style: TextButton.styleFrom(foregroundColor: AppTheme.neonGreen),
                )
              else
                const SizedBox(),
            ],
          ).animate().fadeIn(delay: 300.ms),

          const SizedBox(height: 16),

          // Completion summary
          GlassCard(
            borderColor: _hasContent(0) && _hasContent(1) && _hasContent(2)
                ? AppTheme.neonGreen.withOpacity(0.4)
                : AppTheme.glassBorder,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('JOURNAL PROGRESS',
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 2)),
                const SizedBox(height: 12),
                ...List.generate(_prompts.length, (i) {
                  final done = _hasContent(i);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Icon(
                          done ? Icons.check_circle_rounded : Icons.circle_outlined,
                          color: done ? AppTheme.neonGreen : AppTheme.textMuted,
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          _prompts[i]['question'],
                          style: TextStyle(
                            color: done ? AppTheme.textPrimary : AppTheme.textMuted,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                if (_hasContent(0) && _hasContent(1) && _hasContent(2)) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.neonGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      '✨ Journal Complete! +40 XP',
                      style: TextStyle(color: AppTheme.neonGreen, fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                  ),
                ],
              ],
            ),
          ).animate().fadeIn(delay: 400.ms),
        ],
      ),
    );
  }
}

class _PromptCard extends StatelessWidget {
  final Map<String, dynamic> prompt;
  final TextEditingController controller;

  const _PromptCard({super.key, required this.prompt, required this.controller});

  @override
  Widget build(BuildContext context) {
    final color = prompt['color'] as Color;

    return GlassCard(
      borderColor: color.withOpacity(0.3),
      backgroundColor: color.withOpacity(0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(prompt['emoji'], style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      prompt['question'],
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      prompt['sublabel'],
                      style: TextStyle(color: color.withOpacity(0.8), fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: controller,
            maxLines: 5,
            autofocus: false,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 15,
              height: 1.6,
            ),
            decoration: InputDecoration(
              hintText: prompt['hint'],
              hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 14),
              filled: true,
              fillColor: AppTheme.background.withOpacity(0.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: color.withOpacity(0.5)),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ],
      ),
    );
  }
}
