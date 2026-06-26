import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/practice_goal.dart';
import '../../data/repositories/practice_repository.dart';

class EditPracticePage extends StatefulWidget {
  final PracticeGoal goal;
  final PracticeRepository repository;

  const EditPracticePage({
    super.key,
    required this.goal,
    required this.repository,
  });

  @override
  State<EditPracticePage> createState() => _EditPracticePageState();
}

class _EditPracticePageState extends State<EditPracticePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _targetCtrl;
  late final TextEditingController _dailyCtrl;
  late final TextEditingController _malaCtrl;

  String? _imagePath;
  bool _saving = false;
  DateTime? _completionDate;
  bool _updatingInternally = false;

  int get _remaining {
    final target = int.tryParse(_targetCtrl.text) ?? widget.goal.targetCount;
    return (target - widget.goal.currentCount).clamp(0, target);
  }

  void _onFieldsChanged() {
    if (_updatingInternally) return;
    final daily = int.tryParse(_dailyCtrl.text);
    final remaining = _remaining;
    DateTime? newDate;
    if (daily != null && daily > 0 && remaining > 0) {
      newDate = DateTime.now().add(Duration(days: (remaining / daily).ceil()));
    }
    if (mounted) setState(() => _completionDate = newDate);
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final initial = _completionDate ?? now.add(const Duration(days: 30));
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: now.add(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 365 * 10)),
    );
    if (picked == null || !mounted) return;
    final days = picked.difference(now).inDays;
    if (days > 0 && _remaining > 0) {
      final daily = (_remaining / days).ceil();
      _updatingInternally = true;
      _dailyCtrl.text = daily.toString();
      _updatingInternally = false;
    }
    setState(() => _completionDate = picked);
  }

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.goal.practiceName);
    _targetCtrl =
        TextEditingController(text: widget.goal.targetCount.toString());
    _dailyCtrl = TextEditingController(
        text: widget.goal.dailyGoal?.toString() ?? '');
    _malaCtrl =
        TextEditingController(text: widget.goal.malaSize.toString());
    _imagePath = widget.goal.imagePath;
    _completionDate = widget.goal.estimatedCompletionDate;
    _dailyCtrl.addListener(_onFieldsChanged);
    _targetCtrl.addListener(_onFieldsChanged);
  }

  @override
  void dispose() {
    _dailyCtrl.removeListener(_onFieldsChanged);
    _targetCtrl.removeListener(_onFieldsChanged);
    _nameCtrl.dispose();
    _targetCtrl.dispose();
    _dailyCtrl.dispose();
    _malaCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: AppColors.maroon,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        title: Text(
          s.editPractice,
          style: GoogleFonts.cormorantGaramond(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w400,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            _ImagePicker(
              imagePath: _imagePath,
              label: s.addImage,
              onPicked: (path) => setState(() => _imagePath = path),
            ),
            const SizedBox(height: 28),
            _label(s.practiceName),
            const SizedBox(height: 8),
            _field(
              controller: _nameCtrl,
              hint: 'e.g. Guru Yoga',
              validator: (v) =>
                  v == null || v.trim().isEmpty ? s.fieldRequired : null,
            ),
            const SizedBox(height: 20),
            _label(s.targetCount),
            const SizedBox(height: 8),
            _field(
              controller: _targetCtrl,
              hint: '100000',
              keyboardType: TextInputType.number,
              validator: (v) {
                final n = int.tryParse(v ?? '');
                return (n == null || n <= 0) ? s.fieldInvalidNumber : null;
              },
            ),
            const SizedBox(height: 20),
            _label(s.dailyGoal),
            const SizedBox(height: 8),
            _field(
              controller: _dailyCtrl,
              hint: '1000',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            _label(s.scheduledCompletion),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: AppColors.lightDivider),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _completionDate != null
                            ? '${_completionDate!.day.toString().padLeft(2, '0')}/'
                              '${_completionDate!.month.toString().padLeft(2, '0')}/'
                              '${_completionDate!.year}'
                            : '—',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 16,
                      color: AppColors.goldDim,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            _label(s.malaSize),
            const SizedBox(height: 8),
            _MalaSizeField(controller: _malaCtrl),
            const SizedBox(height: 48),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.maroon,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: _saving ? null : _submit,
              child: Text(
                _saving ? s.saving : s.save,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                  fontSize: 11,
                ),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => _confirmDelete(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.maroon,
                side: const BorderSide(color: AppColors.maroon, width: 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              icon: const Icon(Icons.delete_outline, size: 16),
              label: Text(
                s.delete,
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
    );
  }

  Widget _label(String text) => Text(
        text,
        style: GoogleFonts.poppins(
          color: AppColors.goldDim,
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 2,
        ),
      );

  Widget _field({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) =>
      TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        style: Theme.of(context).textTheme.bodyLarge,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.lightTextMuted),
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.lightDivider),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.goldDim),
          ),
          errorBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.maroon),
          ),
          focusedErrorBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.maroon),
          ),
        ),
      );

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    widget.goal
      ..practiceName = _nameCtrl.text.trim()
      ..targetCount = int.parse(_targetCtrl.text.trim())
      ..malaSize = int.tryParse(_malaCtrl.text.trim()) ?? 108
      ..dailyGoal = int.tryParse(_dailyCtrl.text.trim())
      ..imagePath = _imagePath;

    await widget.repository.addGoal(widget.goal);
    if (mounted) Navigator.pop(context);
  }

  void _confirmDelete(BuildContext context) {
    final s = S.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.lightBackground,
        title: Text(s.deleteConfirmTitle,
            style: Theme.of(context).textTheme.titleLarge),
        content: Text(s.deleteConfirmMessage,
            style: Theme.of(context).textTheme.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              s.cancel,
              style: GoogleFonts.poppins(
                color: AppColors.lightTextSecondary,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
                fontSize: 11,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              await widget.repository.deleteGoal(widget.goal.id);
              if (ctx.mounted) Navigator.pop(ctx);
              if (mounted) {
                Navigator.pop(context);
                Navigator.pop(context);
              }
            },
            child: Text(
              s.confirm,
              style: GoogleFonts.poppins(
                color: AppColors.maroon,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ImagePicker extends StatelessWidget {
  final String? imagePath;
  final String label;
  final ValueChanged<String> onPicked;

  const _ImagePicker({
    required this.imagePath,
    required this.label,
    required this.onPicked,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _pick(context),
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.lightDivider),
          borderRadius: BorderRadius.circular(4),
        ),
        child: imagePath != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.file(
                  File(imagePath!),
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add_photo_alternate_outlined,
                      color: AppColors.lightTextMuted, size: 32),
                  const SizedBox(height: 8),
                  Text(label,
                      style: GoogleFonts.poppins(
                          color: AppColors.lightTextMuted,
                          fontSize: 10,
                          letterSpacing: 2)),
                ],
              ),
      ),
    );
  }

  Future<void> _pick(BuildContext context) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    final dir = await getApplicationDocumentsDirectory();
    final dest = p.join(dir.path, 'practice_images', p.basename(picked.path));
    await Directory(p.dirname(dest)).create(recursive: true);
    await File(picked.path).copy(dest);
    onPicked(dest);
  }
}

class _MalaSizeField extends StatelessWidget {
  final TextEditingController controller;
  const _MalaSizeField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: controller,
            keyboardType: TextInputType.number,
            style: Theme.of(context).textTheme.bodyLarge,
            decoration: const InputDecoration(
              hintText: '108',
              hintStyle: TextStyle(color: AppColors.lightTextMuted),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.lightDivider),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.goldDim),
              ),
            ),
          ),
        ),
        for (final size in [108, 111, 116])
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: GestureDetector(
              onTap: () => controller.text = size.toString(),
              child: Text(
                '$size',
                style: GoogleFonts.poppins(
                  color: AppColors.goldDim,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
