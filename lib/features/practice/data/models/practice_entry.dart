import 'package:isar/isar.dart';

part 'practice_entry.g.dart';

@collection
class PracticeEntry {
  Id id = Isar.autoIncrement;

  late String practiceName;

  late int count;

  @Index()
  late DateTime date;

  String? notes;
}
