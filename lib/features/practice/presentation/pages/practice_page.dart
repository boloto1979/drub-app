import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/mantra_banner.dart';
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
      appBar: AppBar(
        title: const Text('སྒྲུབ'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.lightDivider),
        ),
      ),
      body: goalsAsync.when(
        data: (goals) => repoAsync.when(
          data: (repo) => goals.isEmpty
              ? _EmptyState(onAdd: () => _openAddPage(context))
              : ListView(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
                  children: [
                    const MantraBanner(height: 44),
                    const SizedBox(height: 24),
                    Text(
                      'ACCUMULATIONS',
                      style: GoogleFonts.raleway(
                        color: AppColors.goldDim,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 3,
                      ),
                    ),
                    const SizedBox(height: 16),
                    for (final goal in goals)
                      PracticeGoalCard(goal: goal, repository: repo),
                  ],
                ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.goldDim,
        foregroundColor: AppColors.lightBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        onPressed: () => _openAddPage(context),
        child: const Icon(Icons.add),
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

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const MantraBanner(height: 44),
          const SizedBox(height: 48),
          Icon(Icons.self_improvement_outlined,
              size: 48, color: AppColors.lightTextMuted),
          const SizedBox(height: 16),
          Text('No practices yet.', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 24),
          TextButton(
            onPressed: onAdd,
            child: Text(
              'ADD PRACTICE',
              style: GoogleFonts.raleway(
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
