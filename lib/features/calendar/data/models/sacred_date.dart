import 'package:isar/isar.dart';

part 'sacred_date.g.dart';

@collection
class SacredDate {
  Id id = Isar.autoIncrement;

  late String name;

  String? description;

  @Index()
  late DateTime date;

  late bool isRecurring;
}
