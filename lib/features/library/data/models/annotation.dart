import 'package:isar/isar.dart';

part 'annotation.g.dart';

@collection
class Annotation {
  Id id = Isar.autoIncrement;

  @Index()
  late int libraryItemId;

  late int page;

  late String selectedText;

  String? note;

  late int colorValue;

  @Index()
  late DateTime createdAt;
}
