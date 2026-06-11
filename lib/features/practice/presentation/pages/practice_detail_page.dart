import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/practice_goal.dart';
import '../../data/repositories/practice_repository.dart';
import 'edit_practice_page.dart';

class PracticeDetailPage extends StatelessWidget {
  final PracticeGoal goal;
  final PracticeRepository repository;

  const PracticeDetailPage({
    super.key,
    required this.goal,
    required this.repository,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final text = Theme.of(context).textTheme;
    final fmt = DateFormat('dd/MM/yyyy');
    final numFmt = NumberFormat.decimalPattern();

    return Scaffold(
      appBar: AppBar(
        title: Text(goal.practiceName),
        actions: [
          TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    EditPracticePage(goal: goal, repository: repository),
              ),
            ),
            child: Text(
              s.edit.toUpperCase(),
              style: GoogleFonts.raleway(
                color: AppColors.goldDim,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _ImageHeader(imagePath: goal.imagePath),
          const SizedBox(height: 28),
          _CountRow(
            label: s.requiredReps,
            value: numFmt.format(goal.targetCount),
            text: text,
          ),
          const SizedBox(height: 4),
          _CountRow(
            label: s.completedReps,
            value: numFmt.format(goal.currentCount),
            text: text,
            highlight: true,
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: goal.progressPercent,
            backgroundColor: AppColors.lightSurfaceVariant,
            valueColor: const AlwaysStoppedAnimation(AppColors.goldDim),
            minHeight: 3,
            borderRadius: BorderRadius.circular(2),
          ),
          const SizedBox(height: 28),
          const Divider(color: AppColors.lightDivider),
          const SizedBox(height: 20),
          _StatRow(label: s.started, value: fmt.format(goal.startedAt)),
          if (goal.lastAccumulatedAt != null)
            _StatRow(
              label: s.lastPractice,
              value: fmt.format(goal.lastAccumulatedAt!),
            ),
          if (goal.dailyGoal != null && goal.dailyGoal! > 0) ...[
            _StatRow(
              label: s.daily,
              value: numFmt.format(goal.dailyGoal!),
            ),
            if (goal.estimatedCompletionDate != null)
              _StatRow(
                label: s.estCompletion,
                value: fmt.format(goal.estimatedCompletionDate!),
              ),
          ],
          if (goal.remaining > 0)
            _StatRow(
              label: s.remaining,
              value: numFmt.format(goal.remaining),
            ),
          if (goal.completedAt != null)
            _StatRow(
              label: s.completed,
              value: fmt.format(goal.completedAt!),
            ),
          _StatRow(
            label: s.mala,
            value: goal.malaSize.toString(),
          ),
          const SizedBox(height: 32),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
          child: FilledButton(
            onPressed: () => _showAccumulateSheet(context),
            child: Text(s.accumulate),
          ),
        ),
      ),
    );
  }

  void _showAccumulateSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.lightBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
      ),
      builder: (ctx) => _AccumulateSheet(goal: goal, repository: repository),
    );
  }
}

class _ImageHeader extends StatelessWidget {
  final String? imagePath;
  const _ImageHeader({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    if (imagePath == null) return const SizedBox.shrink();
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Image.file(
        File(imagePath!),
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }
}

class _CountRow extends StatelessWidget {
  final String label;
  final String value;
  final TextTheme text;
  final bool highlight;

  const _CountRow({
    required this.label,
    required this.value,
    required this.text,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.raleway(
            color: AppColors.lightTextMuted,
            fontSize: 11,
            letterSpacing: 1.5,
          ),
        ),
        Text(
          value,
          style: text.headlineMedium?.copyWith(
            color:
                highlight ? AppColors.lightTextPrimary : AppColors.lightTextMuted,
            fontWeight: highlight ? FontWeight.w500 : FontWeight.w300,
          ),
        ),
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;

  const _StatRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.raleway(
              color: AppColors.lightTextSecondary,
              fontSize: 12,
              letterSpacing: 1,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.raleway(
              color: AppColors.lightTextPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _AccumulateSheet extends StatefulWidget {
  final PracticeGoal goal;
  final PracticeRepository repository;
  const _AccumulateSheet({required this.goal, required this.repository});

  @override
  State<_AccumulateSheet> createState() => _AccumulateSheetState();
}

class _AccumulateSheetState extends State<_AccumulateSheet> {
  int _malas = 1;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final count = _malas * widget.goal.malaSize;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.goal.practiceName,
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed:
                    _malas > 1 ? () => setState(() => _malas--) : null,
                icon: const Icon(Icons.remove_circle_outline),
                color: AppColors.goldDim,
                iconSize: 32,
              ),
              const SizedBox(width: 24),
              Column(
                children: [
                  Text(
                    '$_malas',
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 48,
                      fontWeight: FontWeight.w300,
                      color: AppColors.lightTextPrimary,
                    ),
                  ),
                  Text(
                    '${s.malas} · $count',
                    style: GoogleFonts.raleway(
                      color: AppColors.lightTextMuted,
                      fontSize: 10,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 24),
              IconButton(
                onPressed: () => setState(() => _malas++),
                icon: const Icon(Icons.add_circle_outline),
                color: AppColors.goldDim,
                iconSize: 32,
              ),
            ],
          ),
          const SizedBox(height: 28),
          FilledButton(
            onPressed: () async {
              await widget.repository.addAccumulation(widget.goal, count);
              if (context.mounted) Navigator.pop(context);
            },
            child: Text('${s.save}  +$count'),
          ),
        ],
      ),
    );
  }
}
