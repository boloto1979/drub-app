import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/practice_goal.dart';
import '../../data/repositories/practice_repository.dart';
import '../pages/practice_detail_page.dart';

class PracticeGoalCard extends StatefulWidget {
  final PracticeGoal goal;
  final PracticeRepository repository;

  const PracticeGoalCard({
    super.key,
    required this.goal,
    required this.repository,
  });

  @override
  State<PracticeGoalCard> createState() => _PracticeGoalCardState();
}

class _PracticeGoalCardState extends State<PracticeGoalCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: AppColors.maroon.withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PracticeDetailPage(
                goal: widget.goal,
                repository: widget.repository,
              ),
            ),
          ),
          child: ColoredBox(
            color: AppColors.lightBackground,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ImageHeader(goal: widget.goal),
                _ProgressSection(goal: widget.goal),
                _MetaRow(goal: widget.goal),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Image / Maroon header ────────────────────────────────────────────────────

class _ImageHeader extends StatelessWidget {
  final PracticeGoal goal;
  const _ImageHeader({required this.goal});

  @override
  Widget build(BuildContext context) {
    final hasImage = goal.imagePath != null;
    final height = hasImage ? 120.0 : 90.0;

    return SizedBox(
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background
          if (hasImage)
            Image.file(File(goal.imagePath!), fit: BoxFit.cover)
          else
            Image.asset(
              'assets/images/gura-placeholder.png',
              fit: BoxFit.cover,
            ),

          // Gradient overlay — heavier at bottom so text reads clearly
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: hasImage ? 0.08 : 0.0),
                  Colors.black.withValues(alpha: 0.62),
                ],
              ),
            ),
          ),

          // Practice name — bottom left
          Positioned(
            bottom: 12,
            left: 14,
            right: 60,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  goal.practiceName,
                  style: GoogleFonts.cormorantGaramond(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.4,
                    height: 1.1,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  'Mala · ${goal.malaSize}',
                  style: GoogleFonts.poppins(
                    color: Colors.white.withValues(alpha: 0.55),
                    fontSize: 9,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Progress bar ─────────────────────────────────────────────────────────────

class _ProgressSection extends StatelessWidget {
  final PracticeGoal goal;
  const _ProgressSection({required this.goal});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.decimalPattern();
    final pct = (goal.progressPercent * 100).round();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                fmt.format(goal.currentCount),
                style: GoogleFonts.poppins(
                  color: AppColors.lightTextPrimary,
                  fontSize: 26,
                  fontWeight: FontWeight.w500,
                  height: 1,
                ),
              ),
              const Spacer(),
              Text(
                '$pct%',
                style: GoogleFonts.poppins(
                  color: AppColors.maroon.withValues(alpha: 0.6),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                fmt.format(goal.targetCount),
                style: GoogleFonts.poppins(
                  color: AppColors.lightTextMuted,
                  fontSize: 11,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: goal.progressPercent,
            backgroundColor: AppColors.lightSurfaceVariant,
            valueColor: const AlwaysStoppedAnimation(AppColors.maroon),
            minHeight: 3,
            borderRadius: BorderRadius.circular(2),
          ),
        ],
      ),
    );
  }
}

// ─── Today + remaining ────────────────────────────────────────────────────────

class _MetaRow extends StatelessWidget {
  final PracticeGoal goal;
  const _MetaRow({required this.goal});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final fmt = NumberFormat.decimalPattern();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
      child: Row(
        children: [
          _Label(s.accumulated),
          const SizedBox(width: 4),
          Text(
            fmt.format(goal.currentCount),
            style: GoogleFonts.poppins(
              color: AppColors.lightTextSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (goal.remaining > 0) ...[
            const SizedBox(width: 20),
            _Label(s.remaining),
            const SizedBox(width: 4),
            Text(
              fmt.format(goal.remaining),
              style: GoogleFonts.poppins(
                color: AppColors.lightTextSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        color: AppColors.lightTextMuted,
        fontSize: 9,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.5,
      ),
    );
  }
}

