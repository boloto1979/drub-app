import 'package:isar/isar.dart';

import '../models/practice_goal.dart';
import '../models/practice_entry.dart';

class PracticeRepository {
  PracticeRepository(this._isar);

  final Isar _isar;

  Stream<List<PracticeGoal>> watchAll() =>
      _isar.practiceGoals.where().watch(fireImmediately: true);

  Stream<PracticeGoal?> watchGoal(int id) =>
      _isar.practiceGoals.watchObject(id, fireImmediately: true);

  Future<List<PracticeGoal>> getAll() =>
      _isar.practiceGoals.where().findAll();

  Future<void> addGoal(PracticeGoal goal) =>
      _isar.writeTxn(() => _isar.practiceGoals.put(goal));

  Future<void> deleteGoal(int id) =>
      _isar.writeTxn(() => _isar.practiceGoals.delete(id));

  Future<int> getTodayCount(String practiceName) async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    final entries = await _isar.practiceEntrys
        .filter()
        .practiceNameEqualTo(practiceName)
        .dateBetween(startOfDay, endOfDay)
        .findAll();
    return entries.fold<int>(0, (sum, e) => sum + e.count);
  }

  Future<void> addAccumulation(PracticeGoal goal, int count) async {
    await _isar.writeTxn(() async {
      goal.currentCount += count;
      goal.lastAccumulatedAt = DateTime.now();

      if (goal.currentCount >= goal.targetCount) {
        goal.completedAt = DateTime.now();
      }

      await _isar.practiceGoals.put(goal);

      await _isar.practiceEntrys.put(
        PracticeEntry()
          ..practiceName = goal.practiceName
          ..count = count
          ..date = DateTime.now(),
      );
    });
  }

  Future<void> setAccumulation(PracticeGoal goal, int newTotal) async {
    await _isar.writeTxn(() async {
      final diff = newTotal - goal.currentCount;
      goal.currentCount = newTotal;
      goal.lastAccumulatedAt = DateTime.now();

      if (newTotal >= goal.targetCount) {
        goal.completedAt = DateTime.now();
      } else {
        goal.completedAt = null;
      }

      await _isar.practiceGoals.put(goal);

      if (diff != 0) {
        await _isar.practiceEntrys.put(
          PracticeEntry()
            ..practiceName = goal.practiceName
            ..count = diff
            ..date = DateTime.now(),
        );
      }
    });
  }
}
