import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/mantra_banner.dart';
import '../../../../shared/widgets/quote_widget.dart';
import '../../providers/practice_providers.dart';
import '../widgets/practice_goal_card.dart';
import 'add_practice_page.dart';

class PracticePage extends ConsumerWidget {
  const PracticePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(practiceGoalsProvider);
    final repoAsync = ref.watch(practiceRepositoryProvider);

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: goalsAsync.when(
        data: (goals) => repoAsync.when(
          data: (repo) => CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(child: _PageHeader()),
              if (goals.isEmpty)
                SliverFillRemaining(
                  child: _EmptyState(onAdd: () => _openAddPage(context)),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 120),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) => PracticeGoalCard(
                        goal: goals[i],
                        repository: repo,
                      ),
                      childCount: goals.length,
                    ),
                  ),
                ),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('$e')),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
      ),
      floatingActionButton: _SpeedDial(
        onSettings: () => context.push(AppRoutes.settings),
        onAddPractice: () => _openAddPage(context),
      ),
    );
  }

  void _openAddPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddPracticePage()),
    );
  }
}

// ─── Speed Dial ───────────────────────────────────────────────────────────────

class _SpeedDial extends StatefulWidget {
  final VoidCallback onSettings;
  final VoidCallback onAddPractice;

  const _SpeedDial({
    required this.onSettings,
    required this.onAddPractice,
  });

  @override
  State<_SpeedDial> createState() => _SpeedDialState();
}

class _SpeedDialState extends State<_SpeedDial>
    with SingleTickerProviderStateMixin {
  bool _open = false;
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _open = !_open);
    if (_open) {
      _ctrl.forward();
    } else {
      _ctrl.reverse();
    }
  }

  void _close() {
    setState(() => _open = false);
    _ctrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Options — animate in above FAB
        FadeTransition(
          opacity: _fade,
          child: SlideTransition(
            position: _slide,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _DialOption(
                  label: s.navSettings.toUpperCase(),
                  icon: Icons.settings_outlined,
                  onTap: () {
                    _close();
                    widget.onSettings();
                  },
                ),
                const SizedBox(height: 10),
                _DialOption(
                  label: s.addPractice,
                  icon: Icons.add,
                  onTap: () {
                    _close();
                    widget.onAddPractice();
                  },
                ),
                const SizedBox(height: 18),
              ],
            ),
          ),
        ),
        // Main trigger
        GestureDetector(
          onTap: _toggle,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: _open
                  ? AppColors.maroon.withValues(alpha: 0.75)
                  : AppColors.maroon,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(
              _open ? Icons.close : Icons.more_horiz,
              color: Colors.white,
              size: 22,
            ),
          ),
        ),
      ],
    );
  }
}

class _DialOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _DialOption({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.lightBackground,
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: AppColors.maroon.withValues(alpha: 0.14),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                color: AppColors.lightTextPrimary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(width: 14),
            Icon(icon, color: AppColors.maroon, size: 16),
          ],
        ),
      ),
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────

class _PageHeader extends StatelessWidget {
  const _PageHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.maroon,
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MantraBanner(height: 26, color: Color(0x1FFFFFFF)),
          SizedBox(height: 22),
          _HeaderTitle(),
          SizedBox(height: 22),
          _Divider(),
          SizedBox(height: 20),
          QuoteWidget(),
        ],
      ),
    );
  }
}

class _HeaderTitle extends StatelessWidget {
  const _HeaderTitle();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'སྒྲུབ།',
          style: GoogleFonts.cormorantGaramond(
            color: Colors.white,
            fontSize: 44,
            fontWeight: FontWeight.w300,
            letterSpacing: 3,
            height: 1,
          ),
        ),
        const SizedBox(width: 14),
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(
            S.of(context).accumulations,
            style: GoogleFonts.poppins(
              color: Colors.white.withValues(alpha: 0.35),
              fontSize: 9,
              fontWeight: FontWeight.w600,
              letterSpacing: 3,
            ),
          ),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.25),
            Colors.white.withValues(alpha: 0.0),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.self_improvement_outlined,
              size: 40, color: AppColors.lightTextMuted),
          const SizedBox(height: 16),
          Text(s.noPractices, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 24),
          TextButton(
            onPressed: onAdd,
            child: Text(
              s.addPractice,
              style: GoogleFonts.poppins(
                color: AppColors.goldDim,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
