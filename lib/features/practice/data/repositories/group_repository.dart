import 'package:isar/isar.dart';

import '../models/practice_goal.dart';
import '../models/practice_group.dart';

class GroupRepository {
  GroupRepository(this._isar);

  final Isar _isar;

  Stream<List<PracticeGroup>> watchAll() => _isar.practiceGroups
      .where()
      .watch(fireImmediately: true)
      .map((list) => list..sort((a, b) => a.sortOrder.compareTo(b.sortOrder)));

  Future<List<PracticeGroup>> getAll() async {
    final list = await _isar.practiceGroups.where().findAll();
    list.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return list;
  }

  Future<void> addGroup(String name) async {
    final existing = await getAll();
    final nextOrder = existing.isEmpty ? 0 : existing.last.sortOrder + 1;
    final group = PracticeGroup()
      ..name = name
      ..sortOrder = nextOrder;
    await _isar.writeTxn(() => _isar.practiceGroups.put(group));
  }

  Future<void> renameGroup(int id, String name) async {
    await _isar.writeTxn(() async {
      final group = await _isar.practiceGroups.get(id);
      if (group == null) return;
      group.name = name;
      await _isar.practiceGroups.put(group);
    });
  }

  Future<void> deleteGroup(int id) async {
    await _isar.writeTxn(() async {
      final practices = await _isar.practiceGoals.where().findAll();
      final toUpdate = practices.where((p) => p.groupId == id).toList();
      for (final practice in toUpdate) {
        practice.groupId = null;
      }
      if (toUpdate.isNotEmpty) {
        await _isar.practiceGoals.putAll(toUpdate);
      }
      await _isar.practiceGroups.delete(id);
    });
  }

  Future<void> reorder(List<PracticeGroup> ordered) async {
    await _isar.writeTxn(() async {
      for (var i = 0; i < ordered.length; i++) {
        ordered[i].sortOrder = i;
      }
      await _isar.practiceGroups.putAll(ordered);
    });
  }

  Future<void> assignGroup(PracticeGoal goal, int? groupId) async {
    await _isar.writeTxn(() async {
      goal.groupId = groupId;
      await _isar.practiceGoals.put(goal);
    });
  }
}
