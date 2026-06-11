import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/models/practice_goal.dart';
import '../data/repositories/practice_repository.dart';
import '../../../shared/providers/isar_provider.dart';

part 'practice_providers.g.dart';

@Riverpod(keepAlive: true)
Future<PracticeRepository> practiceRepository(Ref ref) async {
  final isar = await ref.watch(isarProvider.future);
  return PracticeRepository(isar);
}

@riverpod
Stream<List<PracticeGoal>> practiceGoals(Ref ref) async* {
  final repo = await ref.watch(practiceRepositoryProvider.future);
  yield* repo.watchAll();
}
