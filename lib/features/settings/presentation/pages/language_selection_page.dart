import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/providers/locale_provider.dart';

class LanguageSelectionPage extends ConsumerStatefulWidget {
  const LanguageSelectionPage({super.key});

  @override
  ConsumerState<LanguageSelectionPage> createState() =>
      _LanguageSelectionPageState();
}

class _LanguageSelectionPageState
    extends ConsumerState<LanguageSelectionPage> {
  Locale _selected = const Locale('pt');

  @override
  Widget build(BuildContext context) {
    final s = S.forLocale(_selected);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;
    final mutedColor =
        isDark ? AppColors.textSecondary : AppColors.lightTextSecondary;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 3),
              Text(
                'སྒྲུབ',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.goldDim,
                  fontSize: 72,
                  height: 1,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Drub',
                textAlign: TextAlign.center,
                style: GoogleFonts.cormorantGaramond(
                  color: textColor,
                  fontSize: 36,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 10,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: AppColors.goldDim.withValues(alpha: 0.4),
                      thickness: 0.5,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      '·',
                      style: TextStyle(
                        color: AppColors.goldDim.withValues(alpha: 0.6),
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: AppColors.goldDim.withValues(alpha: 0.4),
                      thickness: 0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                s.practiceAccumulation,
                textAlign: TextAlign.center,
                style: GoogleFonts.raleway(
                  color: AppColors.goldDim,
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 3,
                ),
              ),
              const Spacer(flex: 3),
              Text(
                s.language,
                textAlign: TextAlign.center,
                style: GoogleFonts.raleway(
                  color: mutedColor,
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _LanguageOption(
                      label: 'English',
                      locale: const Locale('en'),
                      selected: _selected,
                      onTap: (l) => setState(() => _selected = l),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _LanguageOption(
                      label: 'Português',
                      locale: const Locale('pt'),
                      selected: _selected,
                      onTap: (l) => setState(() => _selected = l),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _confirm,
                child: Text(s.continueBtn),
              ),
              const SizedBox(height: 48),
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
