import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/providers/locale_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = S.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(s.navSettings)),
      body: ListView(
        children: [
          _SettingsTile(
            icon: Icons.language_outlined,
            label: s.chooseLanguage,
            onTap: () => ref.read(onboardingNotifierProvider.notifier).reset(),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.goldDim, size: 20),
      title: Text(
        label,
        style: GoogleFonts.raleway(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.5,
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
