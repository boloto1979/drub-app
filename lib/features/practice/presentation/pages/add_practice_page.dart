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
  bool _saving = false;

  @override
  void dispose() {
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
      appBar: AppBar(
        title: Text(s.newPractice),
        leading: IconButton(
          icon: const Icon(Icons.close),
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
            _label(s.malaSize),
            const SizedBox(height: 8),
            _MalaSizeField(controller: _malaCtrl),
            const SizedBox(height: 40),
            FilledButton(
              onPressed: _saving ? null : _submit,
              child: Text(_saving ? s.saving : s.addPractice),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Text(
        text,
        style: GoogleFonts.raleway(
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
                      style: GoogleFonts.raleway(
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
                style: GoogleFonts.raleway(
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
