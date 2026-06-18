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
    final text = Theme.of(context).textTheme;
    final fmt = DateFormat('dd/MM/yyyy');
    final numFmt = NumberFormat.decimalPattern();
    final hasImage = goal.imagePath != null;

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
          child: Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: () => _showAccumulateSheet(context, goal),
                  child: Text(s.accumulate),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          EditPracticePage(goal: goal, repository: repository),
                    ),
                  ),
                  child: Text(s.edit),
                ),
              ),
            ],
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: hasImage ? 300 : null,
            pinned: true,
            stretch: true,
            automaticallyImplyLeading: false,
            backgroundColor: AppColors.lightBackground,
            title: hasImage ? null : Text(goal.practiceName),
            actions: const [],
            flexibleSpace: hasImage
                ? FlexibleSpaceBar(
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
                        Image.file(
                          File(goal.imagePath!),
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
                  )
                : null,
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
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
      text: _count > 0 ? _count.toString() : '',
    );
    final result = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.lightBackground,
        title: Text(
          widget.goal.practiceName,
          style: GoogleFonts.raleway(
            fontSize: 11,
            letterSpacing: 2,
            color: AppColors.goldDim,
          ),
        ),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          autofocus: true,
          style: GoogleFonts.cormorantGaramond(
            fontSize: 40,
            color: AppColors.lightTextPrimary,
          ),
          decoration: const InputDecoration(
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.lightDivider),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.goldDim),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              s.cancel,
              style: GoogleFonts.raleway(
                color: AppColors.lightTextMuted,
                fontSize: 11,
                letterSpacing: 1.5,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              final n = int.tryParse(ctrl.text);
              if (n != null && n >= 0) Navigator.pop(ctx, n);
            },
            child: Text(
              'OK',
              style: GoogleFonts.raleway(
                color: AppColors.goldDim,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
    ctrl.dispose();
    if (result == null || !mounted) return;
    final diff = result - _count;
    if (diff > 0) {
      setState(() => _saving = true);
      await widget.repository.addAccumulation(widget.goal, diff);
      if (mounted) setState(() => _saving = false);
    }
    if (mounted) setState(() => _count = result);
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final numFmt = NumberFormat.decimalPattern();

    return Scaffold(
        backgroundColor: AppColors.lightBackground,
        appBar: AppBar(
          backgroundColor: AppColors.lightBackground,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: AppColors.lightTextPrimary),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            widget.goal.practiceName,
            style: GoogleFonts.cormorantGaramond(
              fontSize: 20,
              color: AppColors.lightTextPrimary,
              fontWeight: FontWeight.w400,
            ),
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            if (widget.goal.imagePath != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.file(
                    File(widget.goal.imagePath!),
                    height: 140,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    numFmt.format(_count),
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 80,
                      fontWeight: FontWeight.w300,
                      color: AppColors.lightTextPrimary,
                      height: 1,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _editManually,
                    child: const Icon(
                      Icons.more_horiz,
                      color: AppColors.goldDim,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _addMala,
                child: Container(
                  width: double.infinity,
                  color: AppColors.lightSurfaceVariant,
                  child: Center(
                    child: Text(
                      '${s.addMala} (${widget.goal.malaSize})',
                      style: GoogleFonts.raleway(
                        color: AppColors.lightTextMuted,
                        fontSize: 11,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
    );
  }
}
