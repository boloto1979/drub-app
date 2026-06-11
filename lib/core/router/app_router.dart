import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/practice/presentation/pages/practice_page.dart';
import '../../features/library/presentation/pages/library_page.dart';
import '../../features/calendar/presentation/pages/calendar_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/settings/presentation/pages/language_selection_page.dart';
import '../../shared/providers/locale_provider.dart';
import '../../shared/widgets/shell_scaffold.dart';

part 'app_router.g.dart';

@riverpod
GoRouter appRouter(Ref ref) {
  final onboardingDone = ref.watch(onboardingNotifierProvider);

  return GoRouter(
    initialLocation: AppRoutes.practice,
    redirect: (context, state) {
      if (!onboardingDone && state.uri.path != AppRoutes.language) {
        return AppRoutes.language;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.language,
        name: 'language',
        builder: (context, state) => const LanguageSelectionPage(),
      ),
      ShellRoute(
        builder: (context, state, child) => ShellScaffold(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.practice,
            name: 'practice',
            builder: (context, state) => const PracticePage(),
          ),
          GoRoute(
            path: AppRoutes.library,
            name: 'library',
            builder: (context, state) => const LibraryPage(),
          ),
          GoRoute(
            path: AppRoutes.calendar,
            name: 'calendar',
            builder: (context, state) => const CalendarPage(),
          ),
          GoRoute(
            path: AppRoutes.settings,
            name: 'settings',
            builder: (context, state) => const SettingsPage(),
          ),
        ],
      ),
    ],
  );
}

abstract class AppRoutes {
  static const language = '/language';
  static const practice = '/';
  static const library = '/library';
  static const calendar = '/calendar';
  static const settings = '/settings';
}
