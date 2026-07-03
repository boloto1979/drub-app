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
    return StreamBuilder<PracticeGoal?>(
      stream: repository.watchGoal(goal.id),
      builder: (context, snapshot) {
        final liveGoal = snapshot.data ?? goal;
        return _buildScaffold(context, liveGoal);
      },
    );
  }

  Widget _buildScaffold(BuildContext context, PracticeGoal goal) {
    final s = S.of(context);
    final fmt = DateFormat('dd/MM/yyyy');
    final numFmt = NumberFormat.decimalPattern();
    final hasImage = goal.imagePath != null;

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.lightBackground,
          border: Border(top: BorderSide(color: AppColors.lightDivider)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
            child: Row(
              children: [
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.maroon,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () => _showAccumulateSheet(context, goal),
                    child: Text(
                      s.accumulate,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          EditPracticePage(goal: goal, repository: repository),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.maroon,
                    side: const BorderSide(color: AppColors.maroon, width: 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                  ),
                  child: Text(
                    s.edit,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            stretch: true,
            automaticallyImplyLeading: true,
            backgroundColor: AppColors.maroon,
            foregroundColor: Colors.white,
            iconTheme: const IconThemeData(color: Colors.white),
            title: null,
            actions: const [],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                goal.practiceName,
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                ),
              ),
              titlePadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              expandedTitleScale: 1.4,
              stretchModes: const [StretchMode.zoomBackground],
              background: Stack(
                fit: StackFit.expand,
                children: [
                  hasImage
                      ? Image.file(File(goal.imagePath!), fit: BoxFit.cover)
                      : Image.asset(
                          'assets/images/gura-placeholder.png',
                          fit: BoxFit.cover,
                        ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.2),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.55),
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _CountRow(
                  label: s.requiredReps,
                  value: numFmt.format(goal.targetCount),
                ),
                const SizedBox(height: 4),
                _CountRow(
                  label: s.completedReps,
                  value: numFmt.format(goal.currentCount),
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
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _showAccumulateSheet(BuildContext context, PracticeGoal liveGoal) {
    Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => _AccumulatePage(goal: liveGoal, repository: repository),
      ),
    );
  }
}


class _CountRow extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const _CountRow({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            color: AppColors.lightTextMuted,
            fontSize: 11,
            letterSpacing: 1.5,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            color: highlight ? AppColors.lightTextPrimary : AppColors.lightTextMuted,
            fontWeight: highlight ? FontWeight.w500 : FontWeight.w300,
            fontSize: 28,
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
            style: GoogleFonts.poppins(
              color: AppColors.lightTextSecondary,
              fontSize: 12,
              letterSpacing: 1,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
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

class _AccumulatePage extends StatefulWidget {
  final PracticeGoal goal;
  final PracticeRepository repository;
  const _AccumulatePage({required this.goal, required this.repository});

  @override
  State<_AccumulatePage> createState() => _AccumulatePageState();
}

class _AccumulatePageState extends State<_AccumulatePage> {
  int _count = 0; // display total (saved immediately on each tap)
  bool _saving = false;

  Future<void> _addMala() async {
    if (_saving) return;
    final toAdd = widget.goal.malaSize;
    setState(() {
      _count += toAdd;
      _saving = true;
    });
    await widget.repository.addAccumulation(widget.goal, toAdd);
    if (mounted) setState(() => _saving = false);
  }

  Future<void> _editManually() async {
    final s = S.of(context);
    final ctrl = TextEditingController(
      text: widget.goal.currentCount.toString(),
    );

    final result = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.lightBackground,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          padding: const EdgeInsets.fromLTRB(28, 16, 28, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 36,
                  height: 3,
                  decoration: BoxDecoration(
                    color: AppColors.lightDivider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Practice label
              Text(
                widget.goal.practiceName.toUpperCase(),
                style: GoogleFonts.poppins(
                  color: AppColors.lightTextMuted,
                  fontSize: 9,
                  letterSpacing: 2.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),

              // Large number input
              TextField(
                controller: ctrl,
                keyboardType: TextInputType.number,
                autofocus: true,
                textAlign: TextAlign.left,
                style: GoogleFonts.poppins(
                  fontSize: 56,
                  fontWeight: FontWeight.w300,
                  color: AppColors.lightTextPrimary,
                  height: 1.1,
                ),
                decoration: InputDecoration(
                  hintText: '0',
                  hintStyle: GoogleFonts.poppins(
                    fontSize: 56,
                    fontWeight: FontWeight.w300,
                    color: AppColors.lightTextMuted.withValues(alpha: 0.4),
                    height: 1.1,
                  ),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.lightDivider),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.maroon, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.only(bottom: 6),
                ),
              ),
              const SizedBox(height: 28),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.lightTextMuted,
                        side: const BorderSide(
                          color: AppColors.lightDivider,
                          width: 1,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        s.cancel,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        final n = int.tryParse(ctrl.text);
                        if (n != null && n >= 0) Navigator.pop(ctx, n);
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.maroon,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        'OK',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    ctrl.dispose();
    if (result == null || !mounted) return;
    final diff = result - widget.goal.currentCount;
    if (diff != 0) {
      setState(() => _saving = true);
      await widget.repository.setAccumulation(widget.goal, result);
      if (mounted) {
        setState(() {
          _count = (_count + diff).clamp(0, result);
          _saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final numFmt = NumberFormat.decimalPattern();

    return Scaffold(
        backgroundColor: AppColors.lightBackground,
        appBar: AppBar(
          backgroundColor: AppColors.maroon,
          foregroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            widget.goal.practiceName,
            style: GoogleFonts.cormorantGaramond(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.w400,
            ),
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            // Full-bleed image
            SizedBox(
              height: MediaQuery.orientationOf(context) == Orientation.landscape
                  ? 80
                  : 168,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  widget.goal.imagePath != null
                      ? Image.file(
                          File(widget.goal.imagePath!),
                          fit: BoxFit.cover,
                        )
                      : Image.asset(
                          'assets/images/gura-placeholder.png',
                          fit: BoxFit.cover,
                        ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.22),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Session count + progress
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        numFmt.format(_count),
                        style: GoogleFonts.poppins(
                          fontSize: 68,
                          fontWeight: FontWeight.w300,
                          color: AppColors.lightTextPrimary,
                          height: 1,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: _editManually,
                        child: const Padding(
                          padding: EdgeInsets.all(12),
                          child: Icon(
                            Icons.more_horiz,
                            color: AppColors.goldDim,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    s.accumulated.toUpperCase(),
                    style: GoogleFonts.poppins(
                      color: AppColors.lightTextMuted,
                      fontSize: 9,
                      letterSpacing: 2,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 14),
                  LinearProgressIndicator(
                    value: (widget.goal.currentCount / widget.goal.targetCount)
                        .clamp(0.0, 1.0),
                    backgroundColor: AppColors.lightSurfaceVariant,
                    valueColor:
                        const AlwaysStoppedAnimation(AppColors.maroon),
                    minHeight: 2,
                    borderRadius: BorderRadius.circular(1),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${numFmt.format(widget.goal.currentCount)} / ${numFmt.format(widget.goal.targetCount)}',
                    textAlign: TextAlign.end,
                    style: GoogleFonts.poppins(
                      color: AppColors.lightTextMuted,
                      fontSize: 9,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Large tap zone
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _addMala,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: _saving
                        ? AppColors.maroon.withValues(alpha: 0.7)
                        : AppColors.maroon,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.18),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          Icons.add,
                          color: Colors.white.withValues(alpha: 0.65),
                          size: 28,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        s.addMala.toUpperCase(),
                        style: GoogleFonts.poppins(
                          color: Colors.white.withValues(alpha: 0.80),
                          fontSize: 10,
                          letterSpacing: 2.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '· ${widget.goal.malaSize} ·',
                        style: GoogleFonts.poppins(
                          color: Colors.white.withValues(alpha: 0.35),
                          fontSize: 9,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
    );
  }
}
