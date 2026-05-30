import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'core/theme/app_theme.dart';
import 'data/providers/lifeos_provider.dart';
import 'data/services/update_service.dart';
import 'features/auth/providers/auth_provider.dart' as app_auth;
import 'features/auth/screens/login_screen.dart';
import 'features/onboarding/screens/onboarding_screen.dart';
import 'features/home/screens/home_screen.dart';
import 'features/admin/screens/admin_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://broidtyxclxtefdlfwad.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJyb2lkdHl4Y2x4dGVmZGxmd2FkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzk4MDgyMzgsImV4cCI6MjA5NTM4NDIzOH0.Zn_Voji28tLoeR11PUKnF0oYGUQ9F2R9YXhyr6tTzWE',
    debug: false,
  );

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: AppTheme.background,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  Animate.defaultDuration = const Duration(milliseconds: 400);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => app_auth.AuthProvider()),
        ChangeNotifierProvider(create: (_) => LifeOSProvider()),
      ],
      child: const LifeOSApp(),
    ),
  );
}

class LifeOSApp extends StatelessWidget {
  const LifeOSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LifeOS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const _AppRoot(),
    );
  }
}

class _AppRoot extends StatefulWidget {
  const _AppRoot();

  @override
  State<_AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<_AppRoot> {
  String? _lastUserId;
  bool _updateChecked = false;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<app_auth.AuthProvider>();
    final provider = context.watch<LifeOSProvider>();

    // Auth state is hydrated synchronously in AuthProvider constructor —
    // we only show splash if data is still loading from Supabase after login.

    // Not signed in → login
    if (!auth.isAuthenticated) {
      if (_lastUserId != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.read<LifeOSProvider>().reset();
        });
        _lastUserId = null;
        _updateChecked = false;
      }
      return const LoginScreen();
    }

    // Admin → Admin Dashboard (no data load needed)
    if (auth.isAdmin) {
      return const AdminDashboard();
    }

    // Regular user → init data immediately (no postFrameCallback delay)
    final uid = auth.userId;
    if (_lastUserId != uid) {
      _lastUserId = uid;
      // Fire-and-forget — captures provider before async gap
      final lifeosProvider = context.read<LifeOSProvider>();
      Future.microtask(() => lifeosProvider.init(uid));
    }

    if (!provider.isInitialized) {
      return const _SplashScreen();
    }

    // Check for app updates once after login
    if (!_updateChecked) {
      _updateChecked = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkForUpdate(context);
      });
    }

    // Onboarding
    if (!provider.onboardingComplete) {
      return const OnboardingScreen();
    }

    return const HomeScreen();
  }

  Future<void> _checkForUpdate(BuildContext context) async {
    final svc = UpdateService();
    final info = await svc.checkForUpdate();
    if (info == null) return;
    if (!context.mounted) return;

    await showDialog(
      context: context,
      barrierDismissible: !info.isForceUpdate,
      barrierColor: Colors.black87,
      builder: (_) => _UpdateDialog(info: info),
    );
  }
}

// ── Update Dialog ─────────────────────────────────────────────────────────────

class _UpdateDialog extends StatelessWidget {
  final UpdateInfo info;
  const _UpdateDialog({required this.info});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppTheme.neonGreen.withOpacity(0.35), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: AppTheme.neonGreen.withOpacity(0.08),
              blurRadius: 40,
              spreadRadius: 4,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppTheme.neonGreenGradient,
                boxShadow: AppTheme.neonGlow,
              ),
              child: const Center(
                child: Text('⬆', style: TextStyle(fontSize: 34)),
              ),
            ).animate().scale(begin: const Offset(0.7, 0.7), curve: Curves.elasticOut),

            const SizedBox(height: 16),

            Text(
              'Update Available',
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ).animate().fadeIn(delay: 100.ms),

            const SizedBox(height: 4),

            Text(
              'Version ${info.versionName}',
              style: const TextStyle(
                color: AppTheme.neonGreen,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ).animate().fadeIn(delay: 150.ms),

            if (info.releaseNotes.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "WHAT'S NEW",
                      style: TextStyle(
                        color: AppTheme.neonGreen,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      info.releaseNotes,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 200.ms),
            ],

            const SizedBox(height: 20),

            // Update Now
            GestureDetector(
              onTap: () async {
                final uri = Uri.tryParse(info.downloadUrl);
                if (uri != null && await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
              child: Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  gradient: AppTheme.neonGreenGradient,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: AppTheme.neonGlow,
                ),
                child: const Center(
                  child: Text(
                    'Update Now',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ).animate().fadeIn(delay: 300.ms),

            // Later (only if not force)
            if (!info.isForceUpdate) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Later',
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 14),
                ),
              ).animate().fadeIn(delay: 350.ms),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Splash Screen ─────────────────────────────────────────────────────────────

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
              const SizedBox(height: 24),
              const Text(
                'LifeOS',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                  letterSpacing: 2,
                ),
              ).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 8),
              const Text(
                'Your Self-Improvement OS',
                style: TextStyle(
                  color: AppTheme.neonGreen,
                  fontSize: 14,
                  letterSpacing: 3,
                  fontWeight: FontWeight.w500,
                ),
              ).animate().fadeIn(delay: 400.ms),
              const SizedBox(height: 48),
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppTheme.neonGreen),
                  strokeWidth: 2,
                ),
              ).animate().fadeIn(delay: 600.ms),
            ],
          ),
        ),
      ),
    );
  }
}
