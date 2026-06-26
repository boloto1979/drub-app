import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../practice/data/models/practice_entry.dart';
import '../../practice/data/models/practice_goal.dart';

enum ImportResult { success, cancelled, error, versionMismatch }

class BackupService {
  BackupService(this._isar);

  final Isar _isar;

  Future<void> exportBackup() async {
    final goals = await _isar.practiceGoals.where().findAll();
    final entries = await _isar.practiceEntrys.where().findAll();

    final data = {
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'goals': goals.map(_goalToJson).toList(),
      'entries': entries.map(_entryToJson).toList(),
    };

    final json = const JsonEncoder.withIndent('  ').convert(data);
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/drub_backup.json');
    await file.writeAsString(json);

    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'application/json')],
      subject: 'Drub Backup',
    );
  }

  Future<ImportResult> importBackup() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result == null || result.files.isEmpty) return ImportResult.cancelled;

    final path = result.files.first.path;
    if (path == null) return ImportResult.error;

    final String raw;
    try {
      raw = await File(path).readAsString();
    } catch (_) {
      return ImportResult.error;
    }

    final Map<String, dynamic> data;
    try {
      data = jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return ImportResult.error;
    }

    if (data['version'] != 1) return ImportResult.versionMismatch;

    try {
      final goalsList = (data['goals'] as List)
          .map((g) => _goalFromJson(g as Map<String, dynamic>))
          .toList();
      final entriesList = (data['entries'] as List)
          .map((e) => _entryFromJson(e as Map<String, dynamic>))
          .toList();

      final existing = await _isar.practiceGoals.where().findAll();
      final existingNames = existing.map((g) => g.practiceName).toSet();

      final newGoals = goalsList
          .where((g) => !existingNames.contains(g.practiceName))
          .toList();
      final newNames = newGoals.map((g) => g.practiceName).toSet();
      final newEntries = entriesList
          .where((e) => newNames.contains(e.practiceName))
          .toList();

      if (newGoals.isNotEmpty) {
        await _isar.writeTxn(() async {
          await _isar.practiceGoals.putAll(newGoals);
          await _isar.practiceEntrys.putAll(newEntries);
        });
      }
    } catch (_) {
      return ImportResult.error;
    }

    return ImportResult.success;
  }

  Map<String, dynamic> _goalToJson(PracticeGoal g) => {
        'practiceName': g.practiceName,
        'targetCount': g.targetCount,
        'currentCount': g.currentCount,
        'malaSize': g.malaSize,
        'dailyGoal': g.dailyGoal,
        'imagePath': g.imagePath,
        'startedAt': g.startedAt.toIso8601String(),
        'lastAccumulatedAt': g.lastAccumulatedAt?.toIso8601String(),
        'completedAt': g.completedAt?.toIso8601String(),
      };

  PracticeGoal _goalFromJson(Map<String, dynamic> j) => PracticeGoal()
    ..practiceName = j['practiceName'] as String
    ..targetCount = j['targetCount'] as int
    ..currentCount = j['currentCount'] as int
    ..malaSize = (j['malaSize'] as int?) ?? 108
    ..dailyGoal = j['dailyGoal'] as int?
    ..imagePath = j['imagePath'] as String?
    ..startedAt = DateTime.parse(j['startedAt'] as String)
    ..lastAccumulatedAt = j['lastAccumulatedAt'] != null
        ? DateTime.parse(j['lastAccumulatedAt'] as String)
        : null
    ..completedAt = j['completedAt'] != null
        ? DateTime.parse(j['completedAt'] as String)
        : null;

  Map<String, dynamic> _entryToJson(PracticeEntry e) => {
        'practiceName': e.practiceName,
        'count': e.count,
        'date': e.date.toIso8601String(),
        'notes': e.notes,
      };

  PracticeEntry _entryFromJson(Map<String, dynamic> j) => PracticeEntry()
    ..practiceName = j['practiceName'] as String
    ..count = j['count'] as int
    ..date = DateTime.parse(j['date'] as String)
    ..notes = j['notes'] as String?;
}
