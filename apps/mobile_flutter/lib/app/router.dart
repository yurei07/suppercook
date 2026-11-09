import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/app_providers.dart';
import '../core/preferences.dart';
import '../features/auth/presentation/auth_screen.dart';
import '../features/chat/presentation/chat_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/onboarding/presentation/language_screen.dart';
import '../features/onboarding/presentation/onboarding_screen.dart';
import '../features/onboarding/presentation/setup_screen.dart';
import '../features/pantry/presentation/pantry_screen.dart';
import '../features/planner/presentation/planner_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/recipes/presentation/cooking_mode_screen.dart';
import '../features/recipes/presentation/recipe_detail_screen.dart';
import '../features/recipes/presentation/suggestions_screen.dart';
import '../features/scan/presentation/scan_results_screen.dart';
import '../features/scan/presentation/scan_screen.dart';
import '../features/shopping/presentation/shopping_screen.dart';
import 'app_shell.dart';
import 'theme/app_colors.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final override = ref.watch(initialRouteOverrideProvider);
  final initialLocation =
      override ?? (isOnboardingComplete(prefs) ? '/home' : '/language');

  final router = GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: '/language',
        builder: (context, state) => const LanguageScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/auth',
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: '/setup',
        builder: (context, state) => const SetupScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/planner',
                builder: (context, state) => const PlannerScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/shopping',
                builder: (context, state) => const ShoppingScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/scan',
        builder: (context, state) => const ScanScreen(),
      ),
      GoRoute(
        path: '/scan/results',
        builder: (context, state) => ScanResultsScreen(
          imagePath: state.extra as String?,
        ),
      ),
      GoRoute(
        path: '/suggestions',
        builder: (context, state) => const SuggestionsScreen(),
      ),
      GoRoute(
        path: '/recipe/:id',
        builder: (context, state) => RecipeDetailScreen(
          recipeId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/recipe/:id/cook',
        builder: (context, state) => CookingModeScreen(
          recipeId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/pantry',
        builder: (context, state) => const PantryScreen(),
      ),
      GoRoute(
        path: '/chat',
        builder: (context, state) => const ChatScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            state.error?.toString() ?? 'Route not found',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ),
      ),
    ),
  );

  ref.onDispose(router.dispose);
  return router;
});
