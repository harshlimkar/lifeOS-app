import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/providers/auth_provider.dart' as app_auth;

class PendingApprovalScreen extends StatelessWidget {
  const PendingApprovalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<app_auth.AuthProvider>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF8B5CF6).withOpacity(0.35),
                        blurRadius: 30,
                        spreadRadius: 4,
                      )
                    ],
                  ),
                  child: const Center(
                    child: Text('⏳', style: TextStyle(fontSize: 52)),
                  ),
                )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .scale(
                      begin: const Offset(0.95, 0.95),
                      end: const Offset(1.05, 1.05),
                      duration: const Duration(milliseconds: 1200),
                      curve: Curves.easeInOut,
                    ),

                const SizedBox(height: 36),

                // Title
                const Text(
                  'Awaiting Approval',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                    letterSpacing: 0.5,
                  ),
                ).animate().fadeIn(delay: 150.ms),

                const SizedBox(height: 14),

                // Body text
                Text(
                  'Your account (${auth.email}) has been created successfully.\n\nThe admin needs to approve you before you can access LifeOS. This usually takes a short while.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 15,
                    height: 1.6,
                  ),
                ).animate().fadeIn(delay: 300.ms),

                const SizedBox(height: 48),

                // Status pill
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(
                        color: const Color(0xFF8B5CF6).withOpacity(0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFF8B5CF6),
                          shape: BoxShape.circle,
                        ),
                      )
                          .animate(onPlay: (c) => c.repeat())
                          .fadeOut(duration: 800.ms)
                          .then()
                          .fadeIn(duration: 800.ms),
                      const SizedBox(width: 10),
                      const Text(
                        'PENDING APPROVAL',
                        style: TextStyle(
                          color: Color(0xFF8B5CF6),
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 450.ms).scale(begin: const Offset(0.8, 0.8)),

                const SizedBox(height: 60),

                // Info card
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline,
                          color: AppTheme.neonBlue, size: 20),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Contact the admin at 192421216.simats@saveetha.com to speed up your approval.',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 600.ms),

                const Spacer(),

                // Logout button
                TextButton.icon(
                  onPressed: () => context.read<app_auth.AuthProvider>().signOut(),
                  icon: const Icon(Icons.logout, size: 18, color: AppTheme.textMuted),
                  label: const Text(
                    'Sign out',
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 14),
                  ),
                ).animate().fadeIn(delay: 800.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
