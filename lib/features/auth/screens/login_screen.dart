import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/auth_provider.dart' as app_auth;
import '../../../core/theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController(text: '192421216.simats@saveetha.com');
  final _passCtrl = TextEditingController(text: 'Harsh@2007');
  bool _isSignUp = false;
  bool _showPassword = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit(app_auth.AuthProvider auth) async {
    auth.clearError();
    bool ok;
    if (_isSignUp) {
      ok = await auth.signUp(_emailCtrl.text, _passCtrl.text);
      if (ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
                '✅ Account created! Check your email to confirm, then sign in.'),
            backgroundColor: AppTheme.neonGreenDim,
            duration: const Duration(seconds: 5),
          ),
        );
        setState(() => _isSignUp = false);
      }
    } else {
      ok = await auth.signIn(_emailCtrl.text, _passCtrl.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<app_auth.AuthProvider>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Container(
        decoration:
            const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),

                  // ── Logo ─────────────────────────────────────────────────
                  // ── Logo ─────────────────────────────────────────────────
                  Image.asset(
                    'assets/images/logo.png',
                    width: 160,
                    height: 160,
                    fit: BoxFit.contain,
                  )
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .scale(
                        begin: const Offset(0.96, 0.96),
                        end: const Offset(1.04, 1.04),
                        duration: const Duration(milliseconds: 1500),
                        curve: Curves.easeInOut,
                      ),

                  const SizedBox(height: 28),

                  const Text(
                    'LifeOS',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.textPrimary,
                      letterSpacing: 3,
                    ),
                  ).animate().fadeIn(delay: 100.ms),

                  const SizedBox(height: 6),

                  const Text(
                    'YOUR SELF-IMPROVEMENT OS',
                    style: TextStyle(
                      color: AppTheme.neonGreen,
                      fontSize: 11,
                      letterSpacing: 4,
                      fontWeight: FontWeight.w600,
                    ),
                  ).animate().fadeIn(delay: 200.ms),

                  const SizedBox(height: 40),

                  // ── Card ─────────────────────────────────────────────────
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Container(
                      key: ValueKey(_isSignUp),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.03),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: Colors.white10),
                      ),
                      padding: const EdgeInsets.all(22),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isSignUp ? 'Create Account' : 'Welcome Back',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _isSignUp
                                ? 'Your email must be authorized by the admin.'
                                : 'Sign in to continue your grind.',
                            style: const TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 13,
                                height: 1.5),
                          ),

                          const SizedBox(height: 22),

                          // Error banner
                          if (auth.errorMessage != null)
                            _ErrorBanner(auth.errorMessage!),

                          // Email
                          _TextField(
                            controller: _emailCtrl,
                            hint: 'Email address',
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                          ).animate().fadeIn(delay: 50.ms).slideY(begin: 0.2),

                          const SizedBox(height: 12),

                          // Password
                          _PasswordField(
                            controller: _passCtrl,
                            hint: _isSignUp
                                ? 'Create password (min 6 chars)'
                                : 'Password',
                            showPassword: _showPassword,
                            onToggle: () =>
                                setState(() => _showPassword = !_showPassword),
                            onSubmit: () => _submit(auth),
                          ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2),

                          const SizedBox(height: 20),

                          // Submit button
                          _GlowButton(
                            label: _isSignUp ? 'Create Account' : 'Sign In',
                            icon: _isSignUp
                                ? Icons.person_add_rounded
                                : Icons.login_rounded,
                            isLoading: auth.isLoading,
                            onTap: () => _submit(auth),
                          ).animate().fadeIn(delay: 150.ms),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: 300.ms),

                  const SizedBox(height: 20),

                  // ── Toggle sign in / sign up ──────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _isSignUp
                            ? 'Already have an account? '
                            : "Don't have an account? ",
                        style: const TextStyle(
                            color: AppTheme.textMuted, fontSize: 13),
                      ),
                      GestureDetector(
                        onTap: () {
                          auth.clearError();
                          setState(() => _isSignUp = !_isSignUp);
                        },
                        child: Text(
                          _isSignUp ? 'Sign In' : 'Sign Up',
                          style: const TextStyle(
                            color: AppTheme.neonGreen,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 400.ms),

                  const SizedBox(height: 16),

                  // Info note
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.neonBlue.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: AppTheme.neonBlue.withValues(alpha: 0.2)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.lock_outline,
                            color: AppTheme.neonBlue, size: 18),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Access is invite-only. Contact the admin if you need access.',
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 12,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 500.ms),

                  const SizedBox(height: 40),

                  Text(
                    'Track. Improve. Dominate.',
                    style: TextStyle(
                      color:
                          AppTheme.textSecondary.withValues(alpha: 0.4),
                      fontSize: 12,
                      letterSpacing: 2,
                    ),
                  ).animate().fadeIn(delay: 600.ms),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Shared Widgets ────────────────────────────────────────────────────────────

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner(this.message);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.errorColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: AppTheme.errorColor.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline,
              color: AppTheme.errorColor, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                  color: AppTheme.errorColor, fontSize: 13, height: 1.4),
            ),
          ),
        ],
      ),
    ).animate().fadeIn().shake();
  }
}

class _TextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;

  const _TextField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style:
            const TextStyle(color: AppTheme.textPrimary, fontSize: 15),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle:
              const TextStyle(color: AppTheme.textMuted),
          prefixIcon: Icon(icon, color: Colors.white38, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool showPassword;
  final VoidCallback onToggle;
  final VoidCallback onSubmit;

  const _PasswordField({
    required this.controller,
    required this.hint,
    required this.showPassword,
    required this.onToggle,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: TextField(
        controller: controller,
        obscureText: !showPassword,
        onSubmitted: (_) => onSubmit(),
        style:
            const TextStyle(color: AppTheme.textPrimary, fontSize: 15),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle:
              const TextStyle(color: AppTheme.textMuted),
          prefixIcon: const Icon(Icons.lock_outline,
              color: Colors.white38, size: 20),
          suffixIcon: IconButton(
            icon: Icon(
              showPassword
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: Colors.white38,
              size: 20,
            ),
            onPressed: onToggle,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}

class _GlowButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isLoading;
  final VoidCallback? onTap;

  const _GlowButton({
    required this.label,
    required this.icon,
    required this.isLoading,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 54,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: isLoading
              ? const LinearGradient(
                  colors: [Color(0xFF1A2A1A), Color(0xFF1A2A1A)])
              : AppTheme.neonGreenGradient,
          borderRadius: BorderRadius.circular(14),
          boxShadow: isLoading ? [] : AppTheme.neonGlow,
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor:
                        AlwaysStoppedAnimation(Colors.black54),
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, color: Colors.black, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      label,
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
