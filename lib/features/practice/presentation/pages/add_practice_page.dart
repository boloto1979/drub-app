import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/practice_goal.dart';
import '../../data/models/practice_group.dart';
import '../../providers/practice_providers.dart';

class AddPracticePage extends ConsumerStatefulWidget {
  const AddPracticePage({super.key});

  @override
  ConsumerState<AddPracticePage> createState() => _AddPracticePageState();
}

class _AddPracticePageState extends ConsumerState<AddPracticePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _targetCtrl = TextEditingController();
  final _dailyCtrl = TextEditingController();
  final _malaCtrl = TextEditingController(text: '108');

  String? _imagePath;
  int? _groupId;
  bool _saving = false;
  DateTime? _completionDate;
  bool _updatingInternally = false;

  int get _remaining => int.tryParse(_targetCtrl.text) ?? 0;

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

  String _groupLabel(List<PracticeGroup> groups, S s) {
    if (_groupId == null) return s.noGroup;
    for (final g in groups) {
      if (g.id == _groupId) return g.name;
    }
    return s.noGroup;
  }

  Future<void> _pickGroup(BuildContext context, List<PracticeGroup> groups) async {
    final s = S.of(context);
    final result = await showModalBottomSheet<int?>(
      context: context,
      backgroundColor: AppColors.lightBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 32,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.lightDivider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              title: Text(s.noGroup, style: GoogleFonts.poppins(fontSize: 13)),
              trailing: _groupId == null
                  ? const Icon(Icons.check, color: AppColors.maroon, size: 18)
                  : null,
              onTap: () => Navigator.pop(ctx, -1),
            ),
            for (final g in groups)
              ListTile(
                title: Text(g.name, style: GoogleFonts.poppins(fontSize: 13)),
                trailing: _groupId == g.id
                    ? const Icon(Icons.check, color: AppColors.maroon, size: 18)
                    : null,
                onTap: () => Navigator.pop(ctx, g.id),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (result == null) return;
    setState(() => _groupId = result == -1 ? null : result);
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final groups = ref.watch(practiceGroupsProvider).valueOrNull ?? [];

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: AppColors.maroon,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        title: Text(
          s.newPractice,
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
                padding: const EdgeInsets.symmetric(vertical: 16),
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
            const SizedBox(height: 20),
            _label(s.group),
            const SizedBox(height: 8),
            _GroupPickerRow(
              label: _groupLabel(groups, s),
              onTap: () => _pickGroup(context, groups),
            ),
            const SizedBox(height: 40),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.maroon,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: _saving ? null : _submit,
              child: Text(
                _saving ? s.saving : s.addPractice,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                  fontSize: 11,
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

    final goal = PracticeGoal()
      ..practiceName = _nameCtrl.text.trim()
      ..targetCount = int.parse(_targetCtrl.text.trim())
      ..currentCount = 0
      ..malaSize = int.tryParse(_malaCtrl.text.trim()) ?? 108
      ..dailyGoal = int.tryParse(_dailyCtrl.text.trim())
      ..imagePath = _imagePath
      ..groupId = _groupId
      ..startedAt = DateTime.now();

    final repo = await ref.read(practiceRepositoryProvider.future);
    await repo.addGoal(goal);

    if (mounted) Navigator.pop(context);
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
        height: 120,
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

class _GroupPickerRow extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _GroupPickerRow({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.lightDivider)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(label, style: Theme.of(context).textTheme.bodyLarge),
            ),
            const Icon(Icons.expand_more, size: 16, color: AppColors.goldDim),
          ],
        ),
      ),
    );
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
          GestureDetector(
            onTap: () => controller.text = size.toString(),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 4, 16),
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
