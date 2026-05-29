import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/widgets.dart';
import '../../../data/providers/lifeos_provider.dart';
import '../../daily_flow/screens/missions_screen.dart';
import '../../../data/models/day_entry.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LifeOSProvider>();
    final weeklyData = provider.getWeeklyScores();
    final heatmap = provider.getHeatmapData();
    final last7 = provider.getLastNDays(7);
    final avgScore = provider.weeklyAvgScore;

    // Sort all entries descending
    final sortedEntries = List<DayEntry>.from(provider.allEntries)
      ..sort((a, b) => b.dateKey.compareTo(a.dateKey));

    return Container(
      decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
      child: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Analytics', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: AppTheme.textPrimary))
                  .animate().slideY(begin: -0.2, duration: 400.ms),
              const SizedBox(height: 4),
              const Text('Track your consistency and growth patterns.', style: TextStyle(color: AppTheme.textSecondary, fontSize: 14))
                  .animate().fadeIn(delay: 100.ms),
              const SizedBox(height: 20),

              // Summary Row
              Row(
                children: [
                  Expanded(child: _MiniStat(label: 'Weekly Avg', value: '${(avgScore * 100).round()}%', color: AppTheme.neonGreen)),
                  const SizedBox(width: 10),
                  Expanded(child: _MiniStat(label: 'Best Streak', value: '${provider.longestStreak}d', color: Colors.orange)),
                  const SizedBox(width: 10),
                  Expanded(child: _MiniStat(label: 'Total XP', value: '${provider.totalXP}', color: AppTheme.neonBlue)),
                ],
              ).animate().fadeIn(delay: 150.ms),
              const SizedBox(height: 20),

              // Weekly Bar Chart
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('WEEKLY PERFORMANCE',
                        style: TextStyle(color: AppTheme.textMuted, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 2)),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 160,
                      child: last7.isEmpty
                          ? const Center(child: Text('No data yet. Complete your first day!',
                              style: TextStyle(color: AppTheme.textMuted)))
                          : BarChart(
                              BarChartData(
                                alignment: BarChartAlignment.spaceAround,
                                maxY: 1.0,
                                barTouchData: BarTouchData(enabled: false),
                                titlesData: FlTitlesData(
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (val, meta) {
                                        if (val.toInt() < last7.length) {
                                          final entry = last7[val.toInt()];
                                          final parts = entry.dateKey.split('-');
                                          final date = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
                                          return Text(
                                            DateFormat('E').format(date),
                                            style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                                          );
                                        }
                                        return const Text('');
                                      },
                                    ),
                                  ),
                                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                ),
                                gridData: FlGridData(
                                  show: true,
                                  drawVerticalLine: false,
                                  getDrawingHorizontalLine: (_) => FlLine(
                                    color: AppTheme.glassBorder,
                                    strokeWidth: 0.5,
                                  ),
                                ),
                                borderData: FlBorderData(show: false),
                                barGroups: List.generate(last7.length, (i) {
                                  final score = last7[i].completionPercentage;
                                  final color = score >= 0.8
                                      ? AppTheme.neonGreen
                                      : score >= 0.5
                                          ? AppTheme.warningColor
                                          : AppTheme.errorColor;
                                  return BarChartGroupData(
                                    x: i,
                                    barRods: [
                                      BarChartRodData(
                                        toY: score,
                                        color: color,
                                        width: 28,
                                        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                                        backDrawRodData: BackgroundBarChartRodData(
                                          show: true,
                                          toY: 1.0,
                                          color: AppTheme.surfaceLight,
                                        ),
                                      ),
                                    ],
                                  );
                                }),
                              ),
                            ),
                    ),
                  ],
                ),
              ).animate().slideY(begin: 0.2, delay: 200.ms, duration: 500.ms),
              const SizedBox(height: 16),

              // Streak Info
              GlassCard(
                child: Row(
                  children: [
                    const Text('🔥', style: TextStyle(fontSize: 36)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('STREAK STATUS',
                              style: TextStyle(color: AppTheme.textMuted, fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 1.5)),
                          const SizedBox(height: 4),
                          Text(
                            '${provider.currentStreak} day streak',
                            style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w700, fontSize: 20),
                          ),
                          Text(
                            'Best: ${provider.longestStreak} days',
                            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                          ),
                          const SizedBox(height: 8),
                          NeonProgressBar(
                            value: provider.currentStreak / (provider.longestStreak > 0 ? provider.longestStreak : 1),
                            color: Colors.orange,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 300.ms),
              const SizedBox(height: 16),

              // Heatmap Calendar
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('CONSISTENCY HEATMAP',
                        style: TextStyle(color: AppTheme.textMuted, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 2)),
                    const SizedBox(height: 4),
                    const Text('Last 60 days · Green = productive, Yellow = partial, Red = missed',
                        style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                    const SizedBox(height: 16),
                    _HeatmapWidget(heatmapData: heatmap),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _HeatLegend(color: AppTheme.neonGreen, label: 'Great (80%+)'),
                        const SizedBox(width: 12),
                        _HeatLegend(color: AppTheme.warningColor, label: 'Good (40%+)'),
                        const SizedBox(width: 12),
                        _HeatLegend(color: AppTheme.errorColor, label: 'Missed'),
                      ],
                    ),
                  ],
                ),
              ).animate().slideY(begin: 0.3, delay: 400.ms, duration: 500.ms),

              const SizedBox(height: 16),

              // Day History (Tap to Edit)
              if (provider.allEntries.isNotEmpty) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('DAY HISTORY (TAP TO EDIT)',
                        style: TextStyle(color: AppTheme.textMuted, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 2)),
                    Text('${provider.allEntries.length} total',
                        style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                  ],
                ),
                const SizedBox(height: 12),
                ...sortedEntries.map((entry) {
                  final score = entry.completionPercentage;
                  final color = score >= 0.8
                      ? AppTheme.neonGreen
                      : score >= 0.5
                          ? AppTheme.warningColor
                          : AppTheme.errorColor;
                  return GestureDetector(
                    onTap: () => _showEditDialog(context, provider, entry),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceLight,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppTheme.glassBorder),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  entry.dateDisplay,
                                  style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w700, fontSize: 14),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${entry.completedMissions.length} missions · ${entry.waterIntakeLiters.toStringAsFixed(1)}L · ${entry.workoutCompleted ? "Workout Done" : "No Workout"}',
                                  style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          if (entry.isPerfectDay)
                            const Padding(
                              padding: EdgeInsets.only(right: 8),
                              child: Text('⭐ Perfect', style: TextStyle(color: AppTheme.warningColor, fontSize: 12)),
                            ),
                          Text('${(score * 100).round()}%',
                              style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 14)),
                          const SizedBox(width: 8),
                          const Icon(Icons.edit_note_rounded, color: AppTheme.textMuted, size: 20),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, LifeOSProvider provider, DayEntry entry) {
    final waterController = TextEditingController(text: entry.waterIntakeLiters.toString());
    final instaController = TextEditingController(text: entry.instagramMinutes.toString());
    final ytController = TextEditingController(text: entry.youtubeMinutes.toString());
    final wellController = TextEditingController(text: entry.journalWentWell);
    final wasteController = TextEditingController(text: entry.journalWastedTime);
    final improveController = TextEditingController(text: entry.journalImprove);
    
    bool workoutCompleted = entry.workoutCompleted;
    List<String> completedMissions = List<String>.from(entry.completedMissions);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: AppTheme.background,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: const BorderSide(color: AppTheme.glassBorder),
              ),
              child: Container(
                decoration: const BoxDecoration(
                  gradient: AppTheme.backgroundGradient,
                  borderRadius: BorderRadius.all(Radius.circular(24)),
                ),
                padding: const EdgeInsets.all(24),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Edit Day: ${entry.dateDisplay}',
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.w800,
                              fontSize: 20,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: AppTheme.textMuted),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                      const Divider(color: Colors.white10, height: 24),
                      
                      // ── Missions ──
                      const Text('DAILY MISSIONS',
                          style: TextStyle(color: AppTheme.neonGreen, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
                      const SizedBox(height: 12),
                      ...MissionsScreen.missions.map((m) {
                        final mId = m['id'] as String;
                        final mTitle = m['title'] as String;
                        final isCompleted = completedMissions.contains(mId);
                        return CheckboxListTile(
                          title: Text(mTitle, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14)),
                          value: isCompleted,
                          activeColor: AppTheme.neonGreen,
                          checkColor: Colors.black,
                          contentPadding: EdgeInsets.zero,
                          onChanged: (val) {
                            setState(() {
                              if (val == true) {
                                completedMissions.add(mId);
                              } else {
                                completedMissions.remove(mId);
                              }
                            });
                          },
                        );
                      }).toList(),
                      
                      const Divider(color: Colors.white10, height: 24),

                      // ── Water & Workout ──
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('WATER INTAKE (L)',
                                    style: TextStyle(color: AppTheme.neonBlue, fontSize: 10, fontWeight: FontWeight.w700)),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: waterController,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                                  decoration: InputDecoration(
                                    hintText: 'e.g. 3.0',
                                    hintStyle: const TextStyle(color: AppTheme.textMuted),
                                    filled: true,
                                    fillColor: Colors.white.withOpacity(0.05),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('WORKOUT COMPLETED',
                                    style: TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.w700)),
                                const SizedBox(height: 8),
                                SwitchListTile(
                                  value: workoutCompleted,
                                  activeColor: Colors.orange,
                                  contentPadding: EdgeInsets.zero,
                                  onChanged: (val) {
                                    setState(() => workoutCompleted = val);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      const Divider(color: Colors.white10, height: 24),

                      // ── Screen Time ──
                      const Text('SCREEN TIME (MINUTES)',
                          style: TextStyle(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Instagram', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                                const SizedBox(height: 6),
                                TextField(
                                  controller: instaController,
                                  keyboardType: TextInputType.number,
                                  style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.white.withOpacity(0.05),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('YouTube', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                                const SizedBox(height: 6),
                                TextField(
                                  controller: ytController,
                                  keyboardType: TextInputType.number,
                                  style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.white.withOpacity(0.05),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      const Divider(color: Colors.white10, height: 24),

                      // ── Journal ──
                      const Text('DAILY JOURNAL',
                          style: TextStyle(color: Colors.pinkAccent, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
                      const SizedBox(height: 12),
                      _JournalEditField(label: 'What went well today?', controller: wellController),
                      const SizedBox(height: 12),
                      _JournalEditField(label: 'How did you waste time?', controller: wasteController),
                      const SizedBox(height: 12),
                      _JournalEditField(label: 'How can you improve tomorrow?', controller: improveController),
                      
                      const SizedBox(height: 32),

                      // ── Action Buttons ──
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.white30),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                              child: const Text('Cancel', style: TextStyle(color: AppTheme.textPrimary)),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.neonGreen,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                              child: const Text('Save Changes', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700)),
                              onPressed: () async {
                                final water = double.tryParse(waterController.text) ?? entry.waterIntakeLiters;
                                final insta = int.tryParse(instaController.text) ?? entry.instagramMinutes;
                                final yt = int.tryParse(ytController.text) ?? entry.youtubeMinutes;
                                
                                final updatedEntry = DayEntry(
                                  dateKey: entry.dateKey,
                                  createdAt: entry.createdAt,
                                  completedMissions: completedMissions,
                                  waterIntakeLiters: water,
                                  workoutCompleted: workoutCompleted,
                                  instagramMinutes: insta,
                                  youtubeMinutes: yt,
                                  journalWentWell: wellController.text,
                                  journalWastedTime: wasteController.text,
                                  journalImprove: improveController.text,
                                  xpEarned: entry.xpEarned,
                                  isPerfectDay: entry.isPerfectDay,
                                );
                                
                                await provider.updateEntry(updatedEntry);
                                if (context.mounted) {
                                  Navigator.of(context).pop();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('✅ Entry for ${entry.dateDisplay} updated successfully!'),
                                      backgroundColor: AppTheme.neonGreenDim,
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _JournalEditField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  
  const _JournalEditField({required this.label, required this.controller});
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: 2,
          style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.all(12),
          ),
        ),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MiniStat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      child: Column(
        children: [
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 20)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
        ],
      ),
    );
  }
}

class _HeatLegend extends StatelessWidget {
  final Color color;
  final String label;
  const _HeatLegend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 10)),
      ],
    );
  }
}

class _HeatmapWidget extends StatelessWidget {
  final Map<DateTime, int> heatmapData;
  const _HeatmapWidget({required this.heatmapData});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final days = List.generate(60, (i) => now.subtract(Duration(days: 59 - i)));

    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: days.map((date) {
        final key = DateTime(date.year, date.month, date.day);
        final val = heatmapData[key];
        Color color;
        if (val == null) {
          color = AppTheme.surfaceLight;
        } else if (val == 2) {
          color = AppTheme.neonGreen;
        } else if (val == 1) {
          color = AppTheme.warningColor;
        } else {
          color = AppTheme.errorColor;
        }
        return Tooltip(
          message: DateFormat('MMM d').format(date),
          child: Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3),
              boxShadow: val == 2
                  ? [BoxShadow(color: AppTheme.neonGreen.withOpacity(0.4), blurRadius: 4)]
                  : null,
            ),
          ),
        );
      }).toList(),
    );
  }
}
