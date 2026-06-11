import 'package:isar/isar.dart';

part 'practice_goal.g.dart';

@collection
class PracticeGoal {
  Id id = Isar.autoIncrement;

  late String practiceName;

  late int targetCount;

  late int currentCount;

  int malaSize = 108;

  int? dailyGoal;

  String? imagePath;

  @Index()
  late DateTime startedAt;

  DateTime? lastAccumulatedAt;

  DateTime? completedAt;

  int get remaining => (targetCount - currentCount).clamp(0, targetCount);

  double get progressPercent =>
      targetCount > 0 ? (currentCount / targetCount).clamp(0.0, 1.0) : 0;

  DateTime? get estimatedCompletionDate {
    if (dailyGoal == null || dailyGoal! <= 0) return null;
    if (remaining == 0) return completedAt;
    final daysLeft = (remaining / dailyGoal!).ceil();
    return DateTime.now().add(Duration(days: daysLeft));
  }
}
