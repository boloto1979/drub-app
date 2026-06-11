import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/practice/data/models/practice_entry.dart';
import '../../features/practice/data/models/practice_goal.dart';
import '../../features/library/data/models/library_item.dart';
import '../../features/library/data/models/annotation.dart';
import '../../features/calendar/data/models/sacred_date.dart';

part 'isar_provider.g.dart';

@Riverpod(keepAlive: true)
Future<Isar> isar(Ref ref) async {
  final dir = await getApplicationDocumentsDirectory();

  return Isar.open(
    [
      PracticeEntrySchema,
      PracticeGoalSchema,
      LibraryItemSchema,
      AnnotationSchema,
      SacredDateSchema,
    ],
    directory: dir.path,
  );
}
