import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/widgets.dart';
import '../../../data/providers/lifeos_provider.dart';
import '../../auth/providers/auth_provider.dart' as app_auth;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEditing = false;
  bool _isSaving = false;

  late TextEditingController _nameCtrl;
  late TextEditingController _heightCtrl;
  late TextEditingController _weightCtrl;
  late TextEditingController _ageCtrl;
  String _selectedGender = 'Male';

  @override
  void initState() {
    super.initState();
    final provider = context.read<LifeOSProvider>();
    _nameCtrl = TextEditingController(text: provider.userName);
    _heightCtrl = TextEditingController(text: provider.heightCm?.toStringAsFixed(1) ?? '');
    _weightCtrl = TextEditingController(text: provider.weightKg?.toStringAsFixed(1) ?? '');
    _ageCtrl = TextEditingController(text: provider.age?.toString() ?? '');
    _selectedGender = provider.gender ?? 'Male';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    _ageCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    setState(() => _isSaving = true);
    final provider = context.read<LifeOSProvider>();
    final name = _nameCtrl.text.trim();
    if (name.isNotEmpty) await provider.setUserName(name);

    final height = double.tryParse(_heightCtrl.text.trim());
    final weight = double.tryParse(_weightCtrl.text.trim());
    final age = int.tryParse(_ageCtrl.text.trim());
    if (height != null && weight != null && age != null) {
      await provider.saveProfileDetails(
        heightCm: height,
        weightKg: weight,
        gender: _selectedGender,
        age: age,
      );
    }
    setState(() {
      _isSaving = false;
      _isEditing = false;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Profile saved!'),
          backgroundColor: AppTheme.neonGreenDim,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Sign Out', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w700)),
        content: const Text('Are you sure you want to sign out?', style: TextStyle(color: AppTheme.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sign Out', style: TextStyle(color: AppTheme.errorColor, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      await context.read<app_auth.AuthProvider>().signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LifeOSProvider>();
    final auth = context.read<app_auth.AuthProvider>();
    final initials = (provider.userName.isNotEmpty ? provider.userName[0] : 'U').toUpperCase();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              // ── AppBar ──────────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppTheme.glassWhite,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.glassBorder),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textPrimary, size: 18),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'Profile',
                      style: TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.w700),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: _isEditing ? _saveChanges : () => setState(() => _isEditing = true),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: _isEditing ? AppTheme.neonGreenGradient : null,
                          color: _isEditing ? null : AppTheme.glassWhite,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: _isEditing ? AppTheme.neonGreen : AppTheme.glassBorder),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.black)),
                              )
                            : Text(
                                _isEditing ? 'Save' : 'Edit',
                                style: TextStyle(
                                  color: _isEditing ? Colors.black : AppTheme.textSecondary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Content ─────────────────────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),

                      // ── Avatar ──────────────────────────────────────────────
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppTheme.neonGreenGradient,
                          boxShadow: AppTheme.neonGlow,
                        ),
                        child: Center(
                          child: Text(
                            initials,
                            style: const TextStyle(color: Colors.black, fontSize: 36, fontWeight: FontWeight.w900),
                          ),
                        ),
                      ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
                      const SizedBox(height: 14),

                      // Name (editable)
                      _isEditing
                          ? _buildTextField('Full Name', _nameCtrl, Icons.person_outline)
                          : Text(
                              provider.userName,
                              style: const TextStyle(color: AppTheme.textPrimary, fontSize: 24, fontWeight: FontWeight.w800),
                            ),
                      const SizedBox(height: 4),
                      Text(
                        auth.email,
                        style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                      ),
                      const SizedBox(height: 20),

                      // ── Stats Strip ─────────────────────────────────────────
                      Row(
                        children: [
                          _StatChip(label: 'Level', value: '${provider.currentLevel}', icon: Icons.star_rounded, color: AppTheme.warningColor),
                          const SizedBox(width: 8),
                          _StatChip(label: 'Streak', value: '${provider.currentStreak}d', icon: Icons.local_fire_department_rounded, color: Colors.orange),
                          const SizedBox(width: 8),
                          _StatChip(label: 'XP', value: '${provider.totalXP}', icon: Icons.bolt_rounded, color: AppTheme.neonGreen),
                        ],
                      ).animate().fadeIn(delay: 100.ms),
                      const SizedBox(height: 24),

                      // ── Physical Info Card ──────────────────────────────────
                      GlassCard(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.accessibility_new_rounded, color: AppTheme.neonGreen, size: 18),
                                const SizedBox(width: 8),
                                const Text(
                                  'PHYSICAL PROFILE',
                                  style: TextStyle(color: AppTheme.neonGreen, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 2),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            if (_isEditing) ...[
                              // Gender
                              const Text('GENDER', style: TextStyle(color: AppTheme.textMuted, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1)),
                              const SizedBox(height: 8),
                              Row(
                                children: ['Male', 'Female'].map((g) {
                                  final sel = _selectedGender == g;
                                  return Expanded(
                                    child: GestureDetector(
                                      onTap: () => setState(() => _selectedGender = g),
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 200),
                                        margin: EdgeInsets.only(right: g == 'Male' ? 8 : 0),
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        decoration: BoxDecoration(
                                          color: sel ? AppTheme.neonGreen.withValues(alpha: 0.15) : AppTheme.glassWhite,
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: sel ? AppTheme.neonGreen : AppTheme.glassBorder),
                                        ),
                                        child: Text(
                                          '${g == 'Male' ? '♂' : '♀'} $g',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(color: sel ? AppTheme.neonGreen : AppTheme.textSecondary, fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  Expanded(child: _buildNumField('AGE (yrs)', _ageCtrl)),
                                  const SizedBox(width: 10),
                                  Expanded(child: _buildNumField('HEIGHT (cm)', _heightCtrl)),
                                  const SizedBox(width: 10),
                                  Expanded(child: _buildNumField('WEIGHT (kg)', _weightCtrl)),
                                ],
                              ),
                            ] else ...[
                              _InfoRow(icon: Icons.wc_rounded, label: 'Gender', value: provider.gender ?? '—'),
                              _InfoRow(icon: Icons.cake_rounded, label: 'Age', value: provider.age != null ? '${provider.age} yrs' : '—'),
                              _InfoRow(icon: Icons.height_rounded, label: 'Height', value: provider.heightCm != null ? '${provider.heightCm!.toStringAsFixed(1)} cm' : '—'),
                              _InfoRow(icon: Icons.monitor_weight_rounded, label: 'Weight', value: provider.weightKg != null ? '${provider.weightKg!.toStringAsFixed(1)} kg' : '—'),
                              if (provider.heightCm != null && provider.weightKg != null) ...[
                                const Divider(color: AppTheme.glassBorder, height: 24),
                                _BmiRow(heightCm: provider.heightCm!, weightKg: provider.weightKg!),
                              ],
                            ],
                          ],
                        ),
                      ).animate().slideY(begin: 0.2, delay: 200.ms, duration: 400.ms),

                      const SizedBox(height: 16),

                      // ── Notification Center Card ──────────────────────────────────
                      GlassCard(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.notifications_active_rounded, color: AppTheme.neonGreen, size: 18),
                                const SizedBox(width: 8),
                                const Text(
                                  'NOTIFICATION CENTER',
                                  style: TextStyle(color: AppTheme.neonGreen, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 2),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Keep a persistent, non-dismissible reminder in your status bar until you complete all daily checklist goals & workout.',
                              style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, height: 1.5),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Sticky Night Reminder', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
                                Switch(
                                  value: provider.nightlyReminderEnabled,
                                  onChanged: (val) async {
                                    await provider.toggleNightlyReminder(val);
                                  },
                                  activeColor: AppTheme.neonGreen,
                                  activeTrackColor: AppTheme.neonGreen.withValues(alpha: 0.2),
                                ),
                              ],
                            ),
                            const Divider(color: AppTheme.glassBorder, height: 24),
                            Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () async {
                                      final messenger = ScaffoldMessenger.of(context);
                                      await provider.triggerTestNotification();
                                      messenger.showSnackBar(
                                        const SnackBar(
                                          content: Text('⚡ Persistent reminder posted! Check your status bar.'),
                                          backgroundColor: AppTheme.neonGreenDim,
                                          duration: Duration(seconds: 3),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      decoration: BoxDecoration(
                                        color: AppTheme.neonGreen.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: AppTheme.neonGreen.withValues(alpha: 0.25)),
                                      ),
                                      child: const Text(
                                        '⚡ Test Reminder',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(color: AppTheme.neonGreen, fontWeight: FontWeight.w700, fontSize: 13),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () async {
                                      final messenger = ScaffoldMessenger.of(context);
                                      await provider.clearActiveNotification();
                                      messenger.showSnackBar(
                                        const SnackBar(
                                          content: Text('🧹 Cleared active persistent reminder.'),
                                          backgroundColor: AppTheme.surface,
                                          duration: Duration(seconds: 2),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.04),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: AppTheme.glassBorder),
                                      ),
                                      child: const Text(
                                        '🧹 Clear Active',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w600, fontSize: 13),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ).animate().slideY(begin: 0.2, delay: 250.ms, duration: 400.ms),

                      const SizedBox(height: 16),

                      // ── Account Card ────────────────────────────────────────
                      GlassCard(
                        padding: const EdgeInsets.all(4),
                        child: Column(
                          children: [
                            _ActionTile(
                              icon: Icons.logout_rounded,
                              label: 'Sign Out',
                              color: AppTheme.errorColor,
                              onTap: _logout,
                            ),
                          ],
                        ),
                      ).animate().slideY(begin: 0.2, delay: 300.ms, duration: 400.ms),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController ctrl, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.glassWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.neonGreen.withValues(alpha: 0.4)),
      ),
      child: TextField(
        controller: ctrl,
        textAlign: TextAlign.center,
        style: const TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.w700),
        decoration: InputDecoration(
          border: InputBorder.none,
          prefixIcon: Icon(icon, color: AppTheme.neonGreen, size: 20),
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildNumField(String label, TextEditingController ctrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 1)),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.glassWhite,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppTheme.glassBorder),
          ),
          child: TextField(
            controller: ctrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15, fontWeight: FontWeight.w600),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Shared Widgets ─────────────────────────────────────────────────────────────

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _StatChip({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 16)),
            Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.textSecondary, size: 18),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
          const Spacer(),
          Text(value, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
        ],
      ),
    );
  }
}

class _BmiRow extends StatelessWidget {
  final double heightCm;
  final double weightKg;
  const _BmiRow({required this.heightCm, required this.weightKg});

  @override
  Widget build(BuildContext context) {
    final heightM = heightCm / 100;
    final bmi = weightKg / (heightM * heightM);
    final label = bmi < 18.5 ? 'Underweight' : bmi < 25 ? 'Normal' : bmi < 30 ? 'Overweight' : 'Obese';
    final color = bmi < 18.5 ? AppTheme.neonBlue : bmi < 25 ? AppTheme.neonGreen : AppTheme.warningColor;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('BMI', style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
        Row(
          children: [
            Text(bmi.toStringAsFixed(1), style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 16)),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionTile({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
      title: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 15)),
      trailing: Icon(Icons.arrow_forward_ios_rounded, color: color.withValues(alpha: 0.5), size: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
