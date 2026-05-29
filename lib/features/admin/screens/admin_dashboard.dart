import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/providers/auth_provider.dart' as app_auth;
import '../services/admin_service.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final AdminService _adminService = AdminService();

  List<Map<String, dynamic>> _allowedEmails = [];
  List<Map<String, dynamic>> _versions = [];

  bool _loadingEmails = true;
  bool _loadingVersions = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    await Future.wait([_loadEmails(), _loadVersions()]);
  }

  Future<void> _loadEmails() async {
    setState(() => _loadingEmails = true);
    final emails = await _adminService.getAllowedEmails();
    if (mounted) setState(() {
      _allowedEmails = emails;
      _loadingEmails = false;
    });
  }

  Future<void> _loadVersions() async {
    setState(() => _loadingVersions = true);
    final versions = await _adminService.getAppVersions();
    if (mounted) setState(() {
      _versions = versions;
      _loadingVersions = false;
    });
  }

  Future<void> _removeEmail(int id, String email) async {
    final ok = await _adminService.removeEmail(id);
    if (ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$email removed from access list.'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      await _loadEmails();
    }
  }

  void _showAddEmailDialog() {
    final ctrl = TextEditingController();
    bool adding = false;

    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) => AlertDialog(
          backgroundColor: AppTheme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            '✉️  Grant Access',
            style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w800),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter the email address. That person can then log in with an OTP code sent to their inbox.',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, height: 1.5),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: ctrl,
                keyboardType: TextInputType.emailAddress,
                autofocus: true,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: InputDecoration(
                  hintText: 'user@example.com',
                  hintStyle: const TextStyle(color: AppTheme.textMuted),
                  prefixIcon: const Icon(Icons.email_outlined, color: AppTheme.neonGreen, size: 20),
                  filled: true,
                  fillColor: AppTheme.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.white12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.white12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.neonGreen, width: 1.5),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: AppTheme.textMuted)),
            ),
            StatefulBuilder(
              builder: (ctx2, setBtn) => GestureDetector(
                onTap: adding
                    ? null
                    : () async {
                        final email = ctrl.text.trim().toLowerCase();
                        if (email.isEmpty || !email.contains('@')) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please enter a valid email.')),
                          );
                          return;
                        }
                        setBtn(() => adding = true);
                        final ok = await _adminService.addEmail(email);
                        if (ok && mounted) {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('✅ $email can now log in!'),
                              backgroundColor: AppTheme.neonGreenDim,
                            ),
                          );
                          await _loadEmails();
                        } else {
                          setBtn(() => adding = false);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Failed — email may already be in the list.'),
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                        }
                      },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: adding ? null : AppTheme.neonGreenGradient,
                    color: adding ? AppTheme.surface : null,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: adding
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.neonGreen),
                        )
                      : const Text('Grant Access',
                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w800)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPublishVersionDialog() {
    final vNameCtrl = TextEditingController();
    final vCodeCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    final urlCtrl = TextEditingController();
    bool isForce = false;

    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) => AlertDialog(
          backgroundColor: AppTheme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            '🚀  Publish New Version',
            style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w800),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dlgField(vNameCtrl, 'Version Name (e.g. 1.2.0)'),
                const SizedBox(height: 10),
                _dlgField(vCodeCtrl, 'Version Code (e.g. 2)',
                    type: TextInputType.number),
                const SizedBox(height: 10),
                _dlgField(notesCtrl, 'Release Notes', maxLines: 4),
                const SizedBox(height: 10),
                _dlgField(urlCtrl, 'Download URL (APK / Play Store)'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Switch(
                      value: isForce,
                      activeColor: AppTheme.neonGreen,
                      onChanged: (v) => setDlg(() => isForce = v),
                    ),
                    const SizedBox(width: 8),
                    const Text('Force Update',
                        style: TextStyle(color: AppTheme.textSecondary)),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: AppTheme.textMuted)),
            ),
            GestureDetector(
              onTap: () async {
                final vCode = int.tryParse(vCodeCtrl.text.trim());
                if (vCode == null || vNameCtrl.text.isEmpty || urlCtrl.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all required fields.')),
                  );
                  return;
                }
                Navigator.pop(ctx);
                final ok = await _adminService.publishVersion(
                  versionName: vNameCtrl.text.trim(),
                  versionCode: vCode,
                  releaseNotes: notesCtrl.text.trim(),
                  downloadUrl: urlCtrl.text.trim(),
                  isForceUpdate: isForce,
                );
                if (ok && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('✅ v${vNameCtrl.text.trim()} published!'),
                      backgroundColor: AppTheme.neonGreenDim,
                    ),
                  );
                  await _loadVersions();
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  gradient: AppTheme.neonGreenGradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text('Publish',
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.w800)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dlgField(TextEditingController ctrl, String hint,
      {TextInputType type = TextInputType.text, int maxLines = 1}) {
    return TextField(
      controller: ctrl,
      keyboardType: type,
      maxLines: maxLines,
      style: const TextStyle(color: AppTheme.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppTheme.textMuted),
        filled: true,
        fillColor: AppTheme.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.white12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.white12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppTheme.neonGreen, width: 1.5),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<app_auth.AuthProvider>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              // ── Header ────────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 12, 0),
                child: Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF6B35), Color(0xFFFF3D00)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF6B35).withOpacity(0.4),
                            blurRadius: 16,
                          ),
                        ],
                      ),
                      child: const Center(
                          child: Text('👑', style: TextStyle(fontSize: 22))),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Admin Dashboard',
                            style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            auth.email,
                            style: const TextStyle(
                                color: AppTheme.textMuted, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh,
                          color: AppTheme.textSecondary),
                      onPressed: _loadData,
                      tooltip: 'Refresh',
                    ),
                    IconButton(
                      icon: const Icon(Icons.logout,
                          color: AppTheme.textMuted, size: 20),
                      onPressed: () =>
                          context.read<app_auth.AuthProvider>().signOut(),
                      tooltip: 'Sign out',
                    ),
                  ],
                ),
              ).animate().fadeIn().slideY(begin: -0.2),

              const SizedBox(height: 6),

              // ── Stats chips ───────────────────────────────────────────────
              if (!_loadingEmails)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      _StatChip(
                        label: 'Authorized',
                        count: _allowedEmails.length,
                        color: AppTheme.neonGreen,
                        icon: '✅',
                      ),
                      const SizedBox(width: 8),
                      _StatChip(
                        label: 'Versions',
                        count: _versions.length,
                        color: AppTheme.neonBlue,
                        icon: '🚀',
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 120.ms),

              const SizedBox(height: 4),

              // ── Tab Bar ───────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      gradient: AppTheme.neonGreenGradient,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: Colors.black,
                    unselectedLabelColor: AppTheme.textSecondary,
                    labelStyle: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 13),
                    dividerColor: Colors.transparent,
                    tabs: const [
                      Tab(text: '✉️  Access List'),
                      Tab(text: '🚀  Updates'),
                    ],
                  ),
                ),
              ),

              // ── Tab Views ─────────────────────────────────────────────────
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // ── Access List Tab ──────────────────────────────────────
                    _loadingEmails
                        ? const Center(
                            child: CircularProgressIndicator(
                                color: AppTheme.neonGreen))
                        : RefreshIndicator(
                            color: AppTheme.neonGreen,
                            backgroundColor: AppTheme.surface,
                            onRefresh: _loadEmails,
                            child: ListView(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 8),
                              children: [
                                // Add button
                                GestureDetector(
                                  onTap: _showAddEmailDialog,
                                  child: Container(
                                    height: 52,
                                    margin: const EdgeInsets.only(bottom: 16),
                                    decoration: BoxDecoration(
                                      gradient: AppTheme.neonGreenGradient,
                                      borderRadius: BorderRadius.circular(14),
                                      boxShadow: AppTheme.neonGlow,
                                    ),
                                    child: const Center(
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.person_add_alt_1_rounded,
                                              color: Colors.black, size: 20),
                                          SizedBox(width: 8),
                                          Text(
                                            'Grant Access to New User',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w800,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ).animate().fadeIn().slideY(begin: 0.2),

                                if (_allowedEmails.isEmpty)
                                  Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(40),
                                      child: Column(
                                        children: const [
                                          Text('📭',
                                              style: TextStyle(fontSize: 40)),
                                          SizedBox(height: 12),
                                          Text(
                                            'No users authorized yet.\nTap above to grant access.',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: AppTheme.textMuted,
                                                height: 1.5),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                else
                                  ..._allowedEmails.asMap().entries.map((e) {
                                    final idx = e.key;
                                    final item = e.value;
                                    return _EmailCard(
                                      email: item['email'] as String,
                                      addedAt: item['created_at'] as String?,
                                      onRemove: () => showDialog(
                                        context: context,
                                        builder: (_) => AlertDialog(
                                          backgroundColor: AppTheme.surface,
                                          title: const Text('Remove Access?',
                                              style: TextStyle(
                                                  color:
                                                      AppTheme.textPrimary)),
                                          content: Text(
                                            '${item['email']} will no longer be able to log in.',
                                            style: const TextStyle(
                                                color: AppTheme.textSecondary),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                              child: const Text('Cancel',
                                                  style: TextStyle(
                                                      color:
                                                          AppTheme.textMuted)),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                                _removeEmail(
                                                    item['id'] as int,
                                                    item['email'] as String);
                                              },
                                              child: const Text('Remove',
                                                  style: TextStyle(
                                                      color: AppTheme
                                                          .errorColor)),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ).animate().fadeIn(
                                        delay: Duration(
                                            milliseconds: 50 * idx));
                                  }),
                              ],
                            ),
                          ),

                    // ── Updates Tab ──────────────────────────────────────────
                    _loadingVersions
                        ? const Center(
                            child: CircularProgressIndicator(
                                color: AppTheme.neonGreen))
                        : RefreshIndicator(
                            color: AppTheme.neonGreen,
                            backgroundColor: AppTheme.surface,
                            onRefresh: _loadVersions,
                            child: ListView(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 8),
                              children: [
                                GestureDetector(
                                  onTap: _showPublishVersionDialog,
                                  child: Container(
                                    height: 52,
                                    margin: const EdgeInsets.only(bottom: 16),
                                    decoration: BoxDecoration(
                                      gradient: AppTheme.neonGreenGradient,
                                      borderRadius: BorderRadius.circular(14),
                                      boxShadow: AppTheme.neonGlow,
                                    ),
                                    child: const Center(
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.rocket_launch_rounded,
                                              color: Colors.black, size: 20),
                                          SizedBox(width: 8),
                                          Text(
                                            'Publish New Version',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w800,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ).animate().fadeIn().slideY(begin: 0.2),

                                ..._versions.asMap().entries.map((entry) {
                                  final idx = entry.key;
                                  final v = entry.value;
                                  return _VersionCard(
                                    version: v,
                                    isLatest: idx == 0,
                                    onDelete: () async {
                                      await _adminService
                                          .deleteVersion(v['id'] as int);
                                      await _loadVersions();
                                    },
                                  ).animate().fadeIn(
                                      delay: Duration(
                                          milliseconds: 60 * idx));
                                }),

                                if (_versions.isEmpty)
                                  const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(40),
                                      child: Text(
                                          'No versions published yet.',
                                          style: TextStyle(
                                              color: AppTheme.textMuted)),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Helper Widgets ────────────────────────────────────────────────────────────

class _StatChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final String icon;

  const _StatChip({
    required this.label,
    required this.count,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(icon, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$count',
                  style: TextStyle(
                      color: color,
                      fontSize: 22,
                      fontWeight: FontWeight.w800),
                ),
                Text(
                  label,
                  style: TextStyle(
                      color: color.withOpacity(0.7),
                      fontSize: 11,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmailCard extends StatelessWidget {
  final String email;
  final String? addedAt;
  final VoidCallback onRemove;

  const _EmailCard(
      {required this.email, this.addedAt, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    String? dateStr;
    if (addedAt != null) {
      try {
        final dt = DateTime.parse(addedAt!).toLocal();
        dateStr =
            '${dt.day}/${dt.month}/${dt.year}  ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      } catch (_) {}
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.neonGreen.withOpacity(0.1),
              border: Border.all(
                  color: AppTheme.neonGreen.withOpacity(0.3)),
            ),
            child: const Center(
              child: Icon(Icons.check_rounded,
                  color: AppTheme.neonGreen, size: 18),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  email,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                if (dateStr != null)
                  Text(
                    'Added $dateStr',
                    style: const TextStyle(
                        color: AppTheme.textMuted, fontSize: 11),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.remove_circle_outline,
                color: AppTheme.errorColor, size: 20),
            onPressed: onRemove,
            tooltip: 'Remove access',
          ),
        ],
      ),
    );
  }
}

class _VersionCard extends StatelessWidget {
  final Map<String, dynamic> version;
  final bool isLatest;
  final VoidCallback onDelete;

  const _VersionCard(
      {required this.version, required this.isLatest, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final isForce = version['is_force_update'] as bool? ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isLatest
              ? AppTheme.neonGreen.withOpacity(0.3)
              : Colors.white10,
          width: isLatest ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'v${version['version_name']}',
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 8),
              if (isLatest)
                _Pill('LATEST', AppTheme.neonGreen),
              if (isForce) ...[
                const SizedBox(width: 6),
                _Pill('FORCE', AppTheme.errorColor),
              ],
              const Spacer(),
              Text(
                'Build ${version['version_code']}',
                style: const TextStyle(
                    color: AppTheme.textMuted, fontSize: 12),
              ),
            ],
          ),
          if ((version['release_notes'] as String? ?? '').isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              version['release_notes'] as String,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.link, size: 12, color: AppTheme.neonBlue),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  version['download_url'] as String? ?? '-',
                  style: const TextStyle(
                      color: AppTheme.neonBlue, fontSize: 11),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline,
                    color: AppTheme.errorColor, size: 18),
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    backgroundColor: AppTheme.surface,
                    title: const Text('Delete Version?',
                        style: TextStyle(color: AppTheme.textPrimary)),
                    content: const Text(
                      'This version record will be removed.',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel',
                            style: TextStyle(color: AppTheme.textMuted)),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          onDelete();
                        },
                        child: const Text('Delete',
                            style: TextStyle(color: AppTheme.errorColor)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final Color color;
  const _Pill(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 1,
        ),
      ),
    );
  }
}
