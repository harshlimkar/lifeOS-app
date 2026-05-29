import 'package:supabase_flutter/supabase_flutter.dart';

const String kAdminEmail = '192421216.simats@saveetha.com';

/// Service for admin-only operations.
/// Manages the allowed_emails whitelist and app_versions table.
class AdminService {
  final SupabaseClient _client = Supabase.instance.client;

  static bool isAdminEmail(String? email) => email == kAdminEmail;

  // ── Allowed Emails (Whitelist) ─────────────────────────────────────────────

  /// Get all allowed emails.
  Future<List<Map<String, dynamic>>> getAllowedEmails() async {
    try {
      final response = await _client
          .from('allowed_emails')
          .select()
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      return [];
    }
  }

  /// Add an email to the allowlist. Returns true on success.
  Future<bool> addEmail(String email) async {
    try {
      final normalized = email.trim().toLowerCase();
      await _client.from('allowed_emails').insert({
        'email': normalized,
        'added_by': kAdminEmail,
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Remove an email from the allowlist by its id.
  Future<bool> removeEmail(int id) async {
    try {
      await _client.from('allowed_emails').delete().eq('id', id);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Check if a given email is on the allowlist (called before sending OTP).
  Future<bool> isEmailAllowed(String email) async {
    try {
      final normalized = email.trim().toLowerCase();
      final response = await _client
          .from('allowed_emails')
          .select('id')
          .eq('email', normalized)
          .maybeSingle();
      return response != null;
    } catch (e) {
      return false;
    }
  }

  // ── App Version Management ─────────────────────────────────────────────────

  /// Fetch all published app versions (newest first).
  Future<List<Map<String, dynamic>>> getAppVersions() async {
    try {
      final response = await _client
          .from('app_versions')
          .select()
          .order('version_code', ascending: false);
      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      return [];
    }
  }

  /// Publish a new app version. Returns true on success.
  Future<bool> publishVersion({
    required String versionName,
    required int versionCode,
    required String releaseNotes,
    required String downloadUrl,
    required bool isForceUpdate,
  }) async {
    try {
      await _client.from('app_versions').insert({
        'version_name': versionName,
        'version_code': versionCode,
        'release_notes': releaseNotes,
        'download_url': downloadUrl,
        'is_force_update': isForceUpdate,
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Delete a version entry by id.
  Future<bool> deleteVersion(int id) async {
    try {
      await _client.from('app_versions').delete().eq('id', id);
      return true;
    } catch (e) {
      return false;
    }
  }
}
