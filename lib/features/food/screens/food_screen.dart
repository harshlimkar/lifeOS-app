import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/widgets.dart';
import '../../../data/providers/lifeos_provider.dart';

// ── Meal Plan Data ──────────────────────────────────────────────────────────

class MealItem {
  final String id;
  final String name;
  const MealItem({required this.id, required this.name});
}

class MealSection {
  final String title;
  final String emoji;
  final List<MealItem> items;
  const MealSection({required this.title, required this.emoji, required this.items});
}

class DayPlan {
  final String day;
  final String type;  // 'Non-Veg' or 'Veg'
  final String proteinRange;
  final List<MealSection> sections;
  const DayPlan({required this.day, required this.type, required this.proteinRange, required this.sections});
}

const _dailyShake = MealSection(
  title: 'Daily Weight Gain Shake',
  emoji: '🥤',
  items: [
    MealItem(id: 'shake_milk', name: '500 ml Full-Fat Milk'),
    MealItem(id: 'shake_banana', name: '2 Bananas'),
    MealItem(id: 'shake_peanut', name: '2 tbsp Peanut Butter / 30–40g Roasted Peanuts'),
  ],
);

const List<DayPlan> _weeklyPlan = [
  DayPlan(
    day: 'Monday', type: 'Non-Veg', proteinRange: '90–100g',
    sections: [
      MealSection(title: 'Breakfast', emoji: '🌅', items: [MealItem(id: 'mon_bf_1', name: '2 Egg Dosa')]),
      MealSection(title: 'Lunch', emoji: '🍽️', items: [
        MealItem(id: 'mon_ln_1', name: '2 Egg Fried Rice'),
        MealItem(id: 'mon_ln_2', name: '2 Boiled Eggs'),
      ]),
      MealSection(title: 'Evening Shake', emoji: '🥤', items: [MealItem(id: 'mon_ev_1', name: 'Banana Weight Gain Shake')]),
      MealSection(title: 'Dinner', emoji: '🌙', items: [
        MealItem(id: 'mon_dn_1', name: 'Chicken Fried Rice'),
        MealItem(id: 'mon_dn_2', name: '200–250g Chicken'),
      ]),
    ],
  ),
  DayPlan(
    day: 'Tuesday', type: 'Veg', proteinRange: '85–95g',
    sections: [
      MealSection(title: 'Breakfast', emoji: '🌅', items: [
        MealItem(id: 'tue_bf_1', name: '4 Dosa'),
        MealItem(id: 'tue_bf_2', name: 'Sambar'),
      ]),
      MealSection(title: 'Lunch', emoji: '🍽️', items: [
        MealItem(id: 'tue_ln_1', name: 'Rice + Sambar'),
        MealItem(id: 'tue_ln_2', name: '100g Soya Chunks Curry'),
      ]),
      MealSection(title: 'Evening', emoji: '🌆', items: [
        MealItem(id: 'tue_ev_1', name: 'Banana Weight Gain Shake'),
        MealItem(id: 'tue_ev_2', name: '150g Boiled Green Gram Sprouts'),
      ]),
      MealSection(title: 'Dinner', emoji: '🌙', items: [
        MealItem(id: 'tue_dn_1', name: '5 Dosa'),
        MealItem(id: 'tue_dn_2', name: 'Soya Kurma'),
      ]),
    ],
  ),
  DayPlan(
    day: 'Wednesday', type: 'Non-Veg', proteinRange: '95–105g',
    sections: [
      MealSection(title: 'Breakfast', emoji: '🌅', items: [MealItem(id: 'wed_bf_1', name: '2 Egg Dosa')]),
      MealSection(title: 'Lunch', emoji: '🍽️', items: [
        MealItem(id: 'wed_ln_1', name: '2 Egg Fried Rice'),
        MealItem(id: 'wed_ln_2', name: '2 Boiled Eggs'),
      ]),
      MealSection(title: 'Evening Shake', emoji: '🥤', items: [MealItem(id: 'wed_ev_1', name: 'Banana Weight Gain Shake')]),
      MealSection(title: 'Dinner', emoji: '🌙', items: [
        MealItem(id: 'wed_dn_1', name: 'Chicken Biryani'),
        MealItem(id: 'wed_dn_2', name: 'Tandoori Chicken (250g)'),
      ]),
    ],
  ),
  DayPlan(
    day: 'Thursday', type: 'Non-Veg', proteinRange: '90–100g',
    sections: [
      MealSection(title: 'Breakfast', emoji: '🌅', items: [MealItem(id: 'thu_bf_1', name: '2 Egg Dosa')]),
      MealSection(title: 'Lunch', emoji: '🍽️', items: [
        MealItem(id: 'thu_ln_1', name: 'Chicken Biryani'),
        MealItem(id: 'thu_ln_2', name: 'Extra Chicken Pieces'),
        MealItem(id: 'thu_ln_3', name: '2 Boiled Eggs'),
      ]),
      MealSection(title: 'Evening Shake', emoji: '🥤', items: [MealItem(id: 'thu_ev_1', name: 'Banana Weight Gain Shake')]),
      MealSection(title: 'Dinner', emoji: '🌙', items: [
        MealItem(id: 'thu_dn_1', name: '4 Chapati'),
        MealItem(id: 'thu_dn_2', name: 'Chicken Gravy (150–200g Chicken)'),
      ]),
    ],
  ),
  DayPlan(
    day: 'Friday', type: 'Non-Veg', proteinRange: '90–100g',
    sections: [
      MealSection(title: 'Breakfast', emoji: '🌅', items: [MealItem(id: 'fri_bf_1', name: '2 Egg Dosa')]),
      MealSection(title: 'Lunch', emoji: '🍽️', items: [
        MealItem(id: 'fri_ln_1', name: 'Rice + Chicken Gravy'),
        MealItem(id: 'fri_ln_2', name: '2 Boiled Eggs'),
      ]),
      MealSection(title: 'Evening Shake', emoji: '🥤', items: [MealItem(id: 'fri_ev_1', name: 'Banana Weight Gain Shake')]),
      MealSection(title: 'Dinner', emoji: '🌙', items: [
        MealItem(id: 'fri_dn_1', name: 'Chilli Chicken (200g)'),
        MealItem(id: 'fri_dn_2', name: '3 Dosa'),
      ]),
    ],
  ),
  DayPlan(
    day: 'Saturday', type: 'Veg', proteinRange: '85–95g',
    sections: [
      MealSection(title: 'Breakfast', emoji: '🌅', items: [
        MealItem(id: 'sat_bf_1', name: '4 Dosa'),
        MealItem(id: 'sat_bf_2', name: 'Sambar'),
      ]),
      MealSection(title: 'Lunch', emoji: '🍽️', items: [
        MealItem(id: 'sat_ln_1', name: 'Curd Rice'),
        MealItem(id: 'sat_ln_2', name: '100g Soya Fry'),
      ]),
      MealSection(title: 'Evening', emoji: '🌆', items: [
        MealItem(id: 'sat_ev_1', name: 'Banana Weight Gain Shake'),
        MealItem(id: 'sat_ev_2', name: '150g Boiled Green Gram Sprouts'),
      ]),
      MealSection(title: 'Dinner', emoji: '🌙', items: [
        MealItem(id: 'sat_dn_1', name: 'Dosa'),
        MealItem(id: 'sat_dn_2', name: 'Soya Gravy'),
      ]),
    ],
  ),
  DayPlan(
    day: 'Sunday', type: 'Veg', proteinRange: '85–95g',
    sections: [
      MealSection(title: 'Breakfast', emoji: '🌅', items: [
        MealItem(id: 'sun_bf_1', name: '500 ml Milk'),
        MealItem(id: 'sun_bf_2', name: '2 Bananas'),
      ]),
      MealSection(title: 'Lunch', emoji: '🍽️', items: [
        MealItem(id: 'sun_ln_1', name: 'Soya Biryani'),
        MealItem(id: 'sun_ln_2', name: 'Onion Raita'),
      ]),
      MealSection(title: 'Evening', emoji: '🌆', items: [
        MealItem(id: 'sun_ev_1', name: 'Banana Weight Gain Shake'),
        MealItem(id: 'sun_ev_2', name: '150g Boiled White Chana'),
      ]),
      MealSection(title: 'Dinner', emoji: '🌙', items: [
        MealItem(id: 'sun_dn_1', name: '4 Chapati'),
        MealItem(id: 'sun_dn_2', name: 'Soya Kurma'),
      ]),
    ],
  ),
];

// ── Screen ──────────────────────────────────────────────────────────────────

class FoodScreen extends StatelessWidget {
  const FoodScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LifeOSProvider>();
    final now = DateTime.now();
    final weekdayName = DateFormat('EEEE').format(now);
    final dateStr = DateFormat('MMMM d').format(now);

    final todayPlan = _weeklyPlan.firstWhere(
      (p) => p.day == weekdayName,
      orElse: () => _weeklyPlan[0],
    );

    // Collect all meal IDs for today
    final allIds = [
      ..._dailyShake.items.map((i) => i.id),
      ...todayPlan.sections.expand((s) => s.items.map((i) => i.id)),
    ];
    final doneCount = allIds.where((id) => provider.isMealDone(id)).length;
    final progress = allIds.isEmpty ? 0.0 : doneCount / allIds.length;

    final isVeg = todayPlan.type == 'Veg';

    return Container(
      decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
      child: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──────────────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'MEAL PLAN',
                        style: TextStyle(color: AppTheme.neonGreen, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 2),
                      ),
                      Text(
                        weekdayName,
                        style: const TextStyle(color: AppTheme.textPrimary, fontSize: 26, fontWeight: FontWeight.w800),
                      ),
                      Text(
                        dateStr,
                        style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isVeg ? Colors.green.withValues(alpha: 0.15) : Colors.orange.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: isVeg ? Colors.green.withValues(alpha: 0.4) : Colors.orange.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(isVeg ? '🥗' : '🍗', style: const TextStyle(fontSize: 16)),
                        const SizedBox(width: 6),
                        Text(
                          todayPlan.type,
                          style: TextStyle(
                            color: isVeg ? Colors.green : Colors.orange,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ).animate().slideX(begin: -0.2, duration: 400.ms),
              const SizedBox(height: 16),

              // ── Progress Card ─────────────────────────────────────────────
              GlassCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "TODAY'S MEALS",
                          style: TextStyle(color: AppTheme.textMuted, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.5),
                        ),
                        Text(
                          '$doneCount / ${allIds.length} done',
                          style: const TextStyle(color: AppTheme.neonGreen, fontWeight: FontWeight.w700, fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    NeonProgressBar(value: progress, height: 8),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${(progress * 100).toStringAsFixed(0)}% complete',
                          style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppTheme.neonGreen.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppTheme.neonGreen.withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            '💪 ${todayPlan.proteinRange} Protein',
                            style: const TextStyle(color: AppTheme.neonGreen, fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ).animate().slideY(begin: 0.2, delay: 100.ms, duration: 400.ms),
              const SizedBox(height: 16),

              // ── Daily Shake Card ──────────────────────────────────────────
              _MealSectionCard(section: _dailyShake, provider: provider)
                  .animate().slideY(begin: 0.2, delay: 150.ms, duration: 400.ms),
              const SizedBox(height: 12),

              // ── Day's Meal Cards ──────────────────────────────────────────
              ...todayPlan.sections.asMap().entries.map((entry) {
                final i = entry.key;
                final section = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _MealSectionCard(section: section, provider: provider)
                      .animate().slideY(begin: 0.2, delay: Duration(milliseconds: 200 + i * 80), duration: 400.ms),
                );
              }),

              // ── Weekly Rule Card ──────────────────────────────────────────
              GlassCard(
                borderColor: AppTheme.neonPurple.withValues(alpha: 0.3),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('📋', style: TextStyle(fontSize: 22)),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'SIMPLE RULE',
                            style: TextStyle(color: AppTheme.neonPurple, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 2),
                          ),
                          SizedBox(height: 8),
                          Text('🍗 Non-veg days = Chicken + eggs + shake', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, height: 1.6)),
                          Text('🥗 Veg days = Soya + sprouts/chana + shake', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, height: 1.6)),
                          Text('🏋️ Gym 4–5 days/week', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, height: 1.6)),
                          Text('😴 Sleep 7–8 hours', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, height: 1.6)),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 600.ms),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Meal Section Card ─────────────────────────────────────────────────────────

class _MealSectionCard extends StatelessWidget {
  final MealSection section;
  final LifeOSProvider provider;
  const _MealSectionCard({required this.section, required this.provider});

  @override
  Widget build(BuildContext context) {
    final allDone = section.items.every((i) => provider.isMealDone(i.id));

    return GlassCard(
      padding: const EdgeInsets.all(0),
      borderColor: allDone ? AppTheme.neonGreen.withValues(alpha: 0.4) : AppTheme.glassBorder,
      backgroundColor: allDone ? AppTheme.neonGreen.withValues(alpha: 0.04) : null,
      child: Column(
        children: [
          // Section header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Text(section.emoji, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 10),
                Text(
                  section.title.toUpperCase(),
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                ),
                const Spacer(),
                if (allDone)
                  const Icon(Icons.check_circle_rounded, color: AppTheme.neonGreen, size: 18),
              ],
            ),
          ),
          const Divider(color: AppTheme.glassBorder, height: 1),
          // Meal items
          ...section.items.map((item) {
            final done = provider.isMealDone(item.id);
            return GestureDetector(
              onTap: () => provider.toggleMealItem(item.id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: done ? AppTheme.neonGreen.withValues(alpha: 0.06) : Colors.transparent,
                ),
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: done ? AppTheme.neonGreen : Colors.transparent,
                        border: Border.all(
                          color: done ? AppTheme.neonGreen : AppTheme.textMuted,
                          width: 1.5,
                        ),
                      ),
                      child: done
                          ? const Icon(Icons.check, color: Colors.black, size: 14)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item.name,
                        style: TextStyle(
                          color: done ? AppTheme.textMuted : AppTheme.textPrimary,
                          fontSize: 14,
                          fontWeight: done ? FontWeight.w400 : FontWeight.w500,
                          decoration: done ? TextDecoration.lineThrough : null,
                          decorationColor: AppTheme.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
