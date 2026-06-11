import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/providers/locale_provider.dart';
import '../../../../shared/widgets/mantra_banner.dart';

class LanguageSelectionPage extends ConsumerStatefulWidget {
  const LanguageSelectionPage({super.key});

  @override
  ConsumerState<LanguageSelectionPage> createState() =>
      _LanguageSelectionPageState();
}

class _LanguageSelectionPageState
    extends ConsumerState<LanguageSelectionPage> {
  Locale _selected = const Locale('en');

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;
    final mutedColor =
        isDark ? AppColors.textSecondary : AppColors.lightTextSecondary;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 2),
              const MantraBanner(height: 44),
              const SizedBox(height: 32),
              Text(
                'Drub',
                textAlign: TextAlign.center,
                style: GoogleFonts.cormorantGaramond(
                  color: textColor,
                  fontSize: 40,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 6,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'PRACTICE · LIBRARY · CALENDAR',
                textAlign: TextAlign.center,
                style: GoogleFonts.raleway(
                  color: AppColors.gold,
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 3,
                ),
              ),
              const Spacer(flex: 2),
              Text(
                'CHOOSE LANGUAGE',
                textAlign: TextAlign.center,
                style: GoogleFonts.raleway(
                  color: mutedColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2.5,
                ),
              ),
              const SizedBox(height: 20),
              _LanguageOption(
                label: 'English',
                locale: const Locale('en'),
                selected: _selected,
                onTap: (l) => setState(() => _selected = l),
              ),
              const SizedBox(height: 12),
              _LanguageOption(
                label: 'Português',
                locale: const Locale('pt'),
                selected: _selected,
                onTap: (l) => setState(() => _selected = l),
              ),
              const Spacer(flex: 3),
              FilledButton(
                onPressed: _confirm,
                child: const Text('CONTINUE'),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirm() async {
    await ref.read(localeNotifierProvider.notifier).setLocale(_selected);
    await ref.read(onboardingNotifierProvider.notifier).complete();
    if (mounted) context.go(AppRoutes.practice);
  }
}

class _LanguageOption extends StatelessWidget {
  final String label;
  final Locale locale;
  final Locale selected;
  final ValueChanged<Locale> onTap;

  const _LanguageOption({
    required this.label,
    required this.locale,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = locale == selected;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final borderColor = isSelected
        ? AppColors.gold
        : (isDark ? AppColors.divider : AppColors.lightDivider);
    final textColor = isSelected
        ? AppColors.gold
        : (isDark ? AppColors.textSecondary : AppColors.lightTextSecondary);

    return GestureDetector(
      onTap: () => onTap(locale),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: borderColor, width: isSelected ? 1.5 : 1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.cormorantGaramond(
            color: textColor,
            fontSize: 18,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}
