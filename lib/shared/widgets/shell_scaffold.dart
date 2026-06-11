import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/router/app_router.dart';

class ShellScaffold extends StatelessWidget {
  final Widget child;

  const ShellScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();

    final currentIndex = switch (location) {
      _ when location.startsWith(AppRoutes.library) => 1,
      _ when location.startsWith(AppRoutes.calendar) => 2,
      _ when location.startsWith(AppRoutes.settings) => 3,
      _ => 0,
    };

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              context.go(AppRoutes.practice);
            case 1:
              context.go(AppRoutes.library);
            case 2:
              context.go(AppRoutes.calendar);
            case 3:
              context.go(AppRoutes.settings);
          }
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.self_improvement_outlined),
            selectedIcon: const Icon(Icons.self_improvement),
            label: S.of(context).navPractice,
          ),
          NavigationDestination(
            icon: const Icon(Icons.menu_book_outlined),
            selectedIcon: const Icon(Icons.menu_book),
            label: S.of(context).navLibrary,
          ),
          NavigationDestination(
            icon: const Icon(Icons.calendar_month_outlined),
            selectedIcon: const Icon(Icons.calendar_month),
            label: S.of(context).navCalendar,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: S.of(context).navSettings,
          ),
        ],
      ),
    );
  }
}
