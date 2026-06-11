import 'package:isar/isar.dart';

part 'library_item.g.dart';

enum LibraryItemType { pdf, epub }

@collection
class LibraryItem {
  Id id = Isar.autoIncrement;

  late String title;

  String? author;

  late String filePath;

  @Enumerated(EnumType.name)
  late LibraryItemType type;

  late bool isFavorite;

  @Index()
  late DateTime addedAt;

  DateTime? lastReadAt;

  int lastReadPage = 0;
}
