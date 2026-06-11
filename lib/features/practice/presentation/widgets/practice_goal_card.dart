import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/practice_goal.dart';
import '../../data/repositories/practice_repository.dart';
import '../pages/practice_detail_page.dart';

class PracticeGoalCard extends StatelessWidget {
  final PracticeGoal goal;
  final PracticeRepository repository;

  const PracticeGoalCard({
    super.key,
    required this.goal,
    required this.repository,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PracticeDetailPage(
            goal: goal,
            repository: repository,
          ),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.lightDivider),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Header(goal: goal),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: _ProgressBar(goal: goal),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
              child: _Stats(goal: goal, text: text),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final PracticeGoal goal;
  const _Header({required this.goal});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _PracticeImage(imagePath: goal.imagePath),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                goal.practiceName,
                style: Theme.of(context).textTheme.titleLarge,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                'Mala: ${goal.malaSize}',
                style: GoogleFonts.raleway(
                  color: AppColors.lightTextMuted,
                  fontSize: 10,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
        if (goal.completedAt != null)
          const Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(
              Icons.check_circle_outline,
              color: AppColors.goldDim,
              size: 20,
            ),
          ),
      ],
    );
  }
}

class _PracticeImage extends StatelessWidget {
  final String? imagePath;
  const _PracticeImage({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(4),
        bottomLeft: Radius.circular(4),
      ),
      child: imagePath != null
          ? Image.file(
              File(imagePath!),
              width: 64,
              height: 72,
              fit: BoxFit.cover,
            )
          : Container(
              width: 64,
              height: 72,
              color: AppColors.lightSurfaceVariant,
              child: const Icon(
                Icons.self_improvement_outlined,
                color: AppColors.lightTextMuted,
                size: 28,
              ),
            ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final PracticeGoal goal;
  const _ProgressBar({required this.goal});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _fmt(goal.currentCount),
              style: GoogleFonts.raleway(
                color: AppColors.goldDim,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
            Text(
              _fmt(goal.targetCount),
              style: GoogleFonts.raleway(
                color: AppColors.lightTextMuted,
                fontSize: 11,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: goal.progressPercent,
          backgroundColor: AppColors.lightSurfaceVariant,
          valueColor: const AlwaysStoppedAnimation(AppColors.goldDim),
          minHeight: 2,
          borderRadius: BorderRadius.circular(1),
        ),
      ],
    );
  }

  String _fmt(int n) => NumberFormat.decimalPattern().format(n);
}

class _Stats extends StatelessWidget {
  final PracticeGoal goal;
  final TextTheme text;
  const _Stats({required this.goal, required this.text});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final fmt = DateFormat('dd/MM/yyyy');

    return Wrap(
      spacing: 20,
      runSpacing: 6,
      children: [
        if (goal.lastAccumulatedAt != null)
          _Stat(
            label: s.lastPractice,
            value: fmt.format(goal.lastAccumulatedAt!),
          ),
        if (goal.dailyGoal != null && goal.dailyGoal! > 0) ...[
          _Stat(
            label: s.daily,
            value: _fmt(goal.dailyGoal!),
          ),
          if (goal.estimatedCompletionDate != null)
            _Stat(
              label: s.estCompletion,
              value: fmt.format(goal.estimatedCompletionDate!),
            ),
          if (goal.remaining > 0)
            _Stat(
              label: s.remaining,
              value: _fmt(goal.remaining),
            ),
        ],
      ],
    );
  }

  String _fmt(int n) => NumberFormat.decimalPattern().format(n);
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.raleway(
            color: AppColors.lightTextMuted,
            fontSize: 9,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.raleway(
            color: AppColors.lightTextSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
