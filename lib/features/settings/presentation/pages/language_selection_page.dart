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

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.sizeOf(context).height -
                  MediaQuery.paddingOf(context).top -
                  MediaQuery.paddingOf(context).bottom,
            ),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
              const Spacer(flex: 3),

              // ── Tibetan script ──────────────────────────────────────────
              Text(
                'སྒྲུབ།',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.goldDim,
                  fontSize: 72,
                  height: 1,
                ),
              ),
              const SizedBox(height: 8),

              // ── App name ────────────────────────────────────────────────
              Text(
                'Drub',
                textAlign: TextAlign.center,
                style: GoogleFonts.cormorantGaramond(
                  color: AppColors.lightTextPrimary,
                  fontSize: 36,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 12,
                ),
              ),
              const SizedBox(height: 24),

              // ── Divider ─────────────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: AppColors.goldDim.withValues(alpha: 0.4),
                      thickness: 0.5,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
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
              const SizedBox(height: 18),

              // ── Subtitle ────────────────────────────────────────────────
              Text(
                s.practiceAccumulation,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: AppColors.goldDim,
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 3.5,
                ),
              ),

              const Spacer(flex: 3),

              // ── Language label ──────────────────────────────────────────
              Text(
                s.language.toUpperCase(),
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: AppColors.lightTextMuted,
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 16),

              // ── Language options ────────────────────────────────────────
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
              const SizedBox(height: 20),

              // ── Continue button ─────────────────────────────────────────
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.maroon,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                onPressed: _confirm,
                child: Text(
                  s.continueBtn.toUpperCase(),
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                    letterSpacing: 2.5,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
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

    return GestureDetector(
      onTap: () => onTap(locale),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppColors.maroon : AppColors.lightDivider,
            width: isSelected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.cormorantGaramond(
            color: isSelected
                ? AppColors.maroon
                : AppColors.lightTextSecondary,
            fontSize: 18,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}
