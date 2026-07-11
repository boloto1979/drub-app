import 'package:isar/isar.dart';

part 'practice_group.g.dart';

@collection
class PracticeGroup {
  Id id = Isar.autoIncrement;

  late String name;

  int sortOrder = 0;
}
