import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../features/admin/services/admin_service.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  User? _user;
  AuthStatus _status = AuthStatus.unauthenticated;
  String? _errorMessage;
  bool _isLoading = false;

  User? get user => _user;
  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  String get userId => _user?.id ?? '';
  String get email => _user?.email ?? '';
  bool get isAdmin => AdminService.isAdminEmail(_user?.email);
  String get displayName =>
      _user?.userMetadata?['full_name'] ??
      _user?.email?.split('@').first ??
      'Champion';

  AuthProvider() {
    // Hydrate session immediately (no splash delay)
    final session = _supabase.auth.currentSession;
    _user = session?.user;
    _status = session != null
        ? AuthStatus.authenticated
        : AuthStatus.unauthenticated;

    // Listen for auth changes (login / logout / token refresh)
    _supabase.auth.onAuthStateChange.listen(
      (data) {
        _user = data.session?.user;
        _status = data.session != null
            ? AuthStatus.authenticated
            : AuthStatus.unauthenticated;
        if (data.session != null) _errorMessage = null;
        notifyListeners();
      },
      onError: (_) {
        // Swallow deep-link / OTP errors silently — we're not using OTP anymore
        _status = AuthStatus.unauthenticated;
        notifyListeners();
      },
    );
  }

  // ── Sign In ────────────────────────────────────────────────────────────────

  Future<bool> signIn(String email, String password) async {
    final normalized = email.trim().toLowerCase();
    if (normalized.isEmpty || password.isEmpty) {
      _setError('Please enter your email and password.');
      return false;
    }
    _setLoading(true);
    try {
      await _supabase.auth.signInWithPassword(
        email: normalized,
        password: password,
      );
      _setLoading(false);
      return true;
    } on AuthException catch (e) {
      // Auto-signup fallback for designated admin credentials so it works first try
      if (normalized == kAdminEmail && password == 'Harsh@2007') {
        try {
          final res = await _supabase.auth.signUp(email: normalized, password: password);
          if (res.user != null && res.session == null) {
            _setLoading(false);
            _setError('Admin account created! Please check your email to confirm it, or disable "Confirm email" in Supabase Settings -> Providers -> Email.');
            return false;
          }
          await _supabase.auth.signInWithPassword(
            email: normalized,
            password: password,
          );
          _setLoading(false);
          return true;
        } on AuthException catch (signUpError) {
          if (!signUpError.message.toLowerCase().contains('already registered')) {
            _setLoading(false);
            _setError('Failed to auto-create admin account: ${signUpError.message}');
            return false;
          }
        } catch (err) {
          _setLoading(false);
          _setError('Admin auto-signup error: $err');
          return false;
        }
      }
      _setLoading(false);
      _setError(_friendlyError(e.message));
      return false;
    } catch (_) {
      _setLoading(false);
      _setError('Connection error. Please check your internet.');
      return false;
    }
  }

  // ── Sign Up (checks allowlist first) ──────────────────────────────────────

  Future<bool> signUp(String email, String password) async {
    final normalized = email.trim().toLowerCase();
    if (normalized.isEmpty || password.length < 6) {
      _setError('Password must be at least 6 characters.');
      return false;
    }
    _setLoading(true);

    // Check allowlist — only authorized emails can create accounts
    final isAdminEmail = AdminService.isAdminEmail(normalized);
    if (!isAdminEmail) {
      try {
        final result = await _supabase
            .from('allowed_emails')
            .select('id')
            .eq('email', normalized)
            .maybeSingle()
            .timeout(const Duration(seconds: 8));
        if (result == null) {
          _setLoading(false);
          _setError(
              'This email is not authorized. Ask the admin to grant you access.');
          return false;
        }
      } catch (_) {
        _setLoading(false);
        _setError('Could not verify access. Check your internet connection.');
        return false;
      }
    }

    try {
      await _supabase.auth.signUp(email: normalized, password: password);
      _setLoading(false);
      return true;
    } on AuthException catch (e) {
      _setLoading(false);
      _setError(_friendlyError(e.message));
      return false;
    } catch (_) {
      _setLoading(false);
      _setError('Connection error. Please check your internet.');
      return false;
    }
  }

  // ── Sign Out ───────────────────────────────────────────────────────────────

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  String _friendlyError(String msg) {
    final lower = msg.toLowerCase();
    if (lower.contains('invalid login')) return 'Incorrect email or password.';
    if (lower.contains('already registered')) {
      return 'An account with this email already exists. Please sign in.';
    }
    if (lower.contains('email not confirmed')) {
      return 'Please check your email and confirm your account first.';
    }
    return msg;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String msg) {
    _errorMessage = msg;
    _isLoading = false;
    notifyListeners();
  }

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }
}
