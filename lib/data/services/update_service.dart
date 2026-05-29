import 'package:supabase_flutter/supabase_flutter.dart';

/// Current app version — bump these manually with each release.
/// The version_code MUST match what you put in pubspec.yaml build number.
const int kCurrentVersionCode = 1;
const String kCurrentVersionName = '1.0.0';

class UpdateInfo {
  final String versionName;
  final int versionCode;
  final String releaseNotes;
  final String downloadUrl;
  final bool isForceUpdate;

  const UpdateInfo({
    required this.versionName,
    required this.versionCode,
    required this.releaseNotes,
    required this.downloadUrl,
    required this.isForceUpdate,
  });
}

class UpdateService {
  final SupabaseClient _client = Supabase.instance.client;

  /// Check Supabase for the latest version. Returns [UpdateInfo] if an update
  /// is available, or null if the app is up-to-date.
  Future<UpdateInfo?> checkForUpdate() async {
    try {
      final response = await _client
          .from('app_versions')
          .select()
          .order('version_code', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response == null) return null;

      final latestCode = response['version_code'] as int? ?? 0;
      if (latestCode <= kCurrentVersionCode) return null;

      return UpdateInfo(
        versionName: response['version_name'] as String? ?? '',
        versionCode: latestCode,
        releaseNotes: response['release_notes'] as String? ?? '',
        downloadUrl: response['download_url'] as String? ?? '',
        isForceUpdate: response['is_force_update'] as bool? ?? false,
      );
    } catch (_) {
      return null;
    }
  }
}
