import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/providers/isar_provider.dart';
import '../../../../shared/providers/locale_provider.dart';
import '../../../practice/presentation/pages/manage_groups_page.dart';
import '../../data/backup_service.dart';

const _stripeUrl = 'https://buy.stripe.com/PLACEHOLDER';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: AppColors.maroon,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        title: Text(
          s.navSettings,
          style: GoogleFonts.cormorantGaramond(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w400,
            letterSpacing: 1,
          ),
        ),
      ),
      bottomNavigationBar: _ContributeCard(onTap: _openStripe),
      body: Stack(
        children: [
          ListView(
            children: [
              _SectionLabel(s.language),
              _SettingsTile(
                icon: Icons.language_outlined,
                label: s.chooseLanguage,
                onTap: () =>
                    ref.read(onboardingNotifierProvider.notifier).reset(),
              ),
              _SectionLabel(s.groups),
              _SettingsTile(
                icon: Icons.folder_outlined,
                label: s.manageGroups,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ManageGroupsPage(),
                  ),
                ),
              ),
              _SectionLabel(s.dataBackup),
              _SettingsTile(
                icon: Icons.upload_outlined,
                label: s.exportData,
                onTap: _busy ? null : _export,
              ),
              _SettingsTile(
                icon: Icons.download_outlined,
                label: s.importData,
                onTap: _busy ? null : _import,
              ),
            ],
          ),
          if (_busy)
            const ColoredBox(
              color: Color(0x33000000),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Future<void> _export() async {
    setState(() => _busy = true);
    try {
      final isar = await ref.read(isarProvider.future);
      await BackupService(isar).exportBackup();
    } catch (_) {
      if (mounted) {
        _showSnack(S.of(context).importError);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _import() async {
    final s = S.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.lightBackground,
        title: Text(
          s.importConfirmTitle,
          style: GoogleFonts.cormorantGaramond(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.lightTextPrimary,
          ),
        ),
        content: Text(
          s.importConfirmMessage,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: AppColors.lightTextSecondary,
            height: 1.6,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              s.cancel,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
                color: AppColors.lightTextMuted,
              ),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.maroon,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              s.importBtn,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _busy = true);
    try {
      final isar = await ref.read(isarProvider.future);
      final result = await BackupService(isar).importBackup();

      if (!mounted) return;
      switch (result) {
        case ImportResult.success:
          _showSnack(S.of(context).importSuccess);
        case ImportResult.cancelled:
          break;
        case ImportResult.versionMismatch:
          _showSnack(S.of(context).importVersionError);
        case ImportResult.error:
          _showSnack(S.of(context).importError);
      }
    } catch (_) {
      if (mounted) _showSnack(S.of(context).importError);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _openStripe() async {
    final uri = Uri.parse(_stripeUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.poppins(fontSize: 12),
        ),
        backgroundColor: AppColors.maroon,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
    );
  }
}

class _ContributeCard extends StatelessWidget {
  final VoidCallback onTap;
  const _ContributeCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.maroon,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.favorite_outline, color: Colors.white, size: 20),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        s.contributeLabel,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        s.contributeSubtitle,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 10,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.open_in_new, color: Colors.white, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      child: Text(
        text.toUpperCase(),
        style: GoogleFonts.poppins(
          color: AppColors.lightTextMuted,
          fontSize: 9,
          fontWeight: FontWeight.w600,
          letterSpacing: 2.5,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 2),
      leading: Icon(icon, color: AppColors.maroon, size: 20),
      title: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 1,
          color: AppColors.lightTextPrimary,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: AppColors.lightTextMuted,
        size: 18,
      ),
      onTap: onTap,
    );
  }
}
