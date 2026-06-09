import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/providers/auth_provider.dart';
import '../../presentation/screens/ai/ai_chat_screen.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/bible/bible_reader_screen.dart';
import '../../presentation/screens/bible/bible_screen.dart';
import '../../presentation/screens/home/dashboard_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/liturgy/liturgy_screen.dart';
import '../../presentation/screens/onboarding/onboarding_screen.dart';
import '../../presentation/screens/prayers/prayer_detail_screen.dart';
import '../../presentation/screens/prayers/prayers_screen.dart';
import '../../presentation/screens/prayers/rosary_screen.dart';
import '../../presentation/screens/profile/profile_screen.dart';
import '../../presentation/screens/saints/saint_detail_screen.dart';
import '../../presentation/screens/saints/saints_screen.dart';
import '../../presentation/screens/splash/splash_screen.dart';

// ── Route names ───────────────────────────────────────────────────────────

class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';

  // Shell routes
  static const String home = '/home';
  static const String dashboard = '/home/dashboard';
  static const String bible = '/home/bible';
  static const String bibleReader = '/home/bible/reader';
  static const String prayers = '/home/prayers';
  static const String prayerDetail = '/home/prayers/detail';
  static const String rosary = '/home/prayers/rosary';
  static const String liturgy = '/home/liturgy';
  static const String saints = '/home/saints';
  static const String saintDetail = '/home/saints/detail';
  static const String aiChat = '/home/ai';
  static const String profile = '/home/profile';
  static const String formation = '/home/formation';
  static const String community = '/home/community';
  static const String parishes = '/home/parishes';
}

// ── Router provider ───────────────────────────────────────────────────────

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: false,
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final isSplash = state.matchedLocation == AppRoutes.splash;
      final isOnboarding = state.matchedLocation == AppRoutes.onboarding;
      final isLogin = state.matchedLocation == AppRoutes.login;
      final isAuthRoute = isLogin || isOnboarding || isSplash;

      // Loading: stay on splash
      if (authState.isLoading) return null;

      // Not logged in and not on auth route: go to login
      if (!isLoggedIn && !isAuthRoute) {
        return AppRoutes.login;
      }

      // Logged in but on auth route: go to home
      if (isLoggedIn && isAuthRoute && !isSplash) {
        return AppRoutes.home;
      }

      return null;
    },
    routes: [
      // ── Splash ──────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // ── Onboarding ───────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.onboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),

      // ── Login ────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),

      // ── Home Shell ───────────────────────────────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return HomeScreen(navigationShell: navigationShell);
        },
        branches: [
          // Branch 0: Dashboard
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.dashboard,
                name: 'dashboard',
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),

          // Branch 1: Bible
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.bible,
                name: 'bible',
                builder: (context, state) => const BibleScreen(),
                routes: [
                  GoRoute(
                    path: 'reader',
                    name: 'bibleReader',
                    builder: (context, state) {
                      final extra = state.extra as Map<String, dynamic>?;
                      return BibleReaderScreen(
                        bookId: extra?['bookId'] as String? ?? 'jn',
                        chapter: extra?['chapter'] as int? ?? 1,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),

          // Branch 2: Prayers
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.prayers,
                name: 'prayers',
                builder: (context, state) => const PrayersScreen(),
                routes: [
                  GoRoute(
                    path: 'detail/:id',
                    name: 'prayerDetail',
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return PrayerDetailScreen(prayerId: id);
                    },
                  ),
                  GoRoute(
                    path: 'rosary',
                    name: 'rosary',
                    builder: (context, state) => const RosaryScreen(),
                  ),
                ],
              ),
            ],
          ),

          // Branch 3: Liturgy
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.liturgy,
                name: 'liturgy',
                builder: (context, state) => const LiturgyScreen(),
              ),
            ],
          ),

          // Branch 4: Saints
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.saints,
                name: 'saints',
                builder: (context, state) => const SaintsScreen(),
                routes: [
                  GoRoute(
                    path: 'detail/:id',
                    name: 'saintDetail',
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return SaintDetailScreen(saintId: id);
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),

      // ── Standalone routes (within home but not bottom nav) ──────────
      GoRoute(
        path: AppRoutes.aiChat,
        name: 'aiChat',
        builder: (context, state) => const AiChatScreen(),
      ),

      GoRoute(
        path: AppRoutes.profile,
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Page introuvable',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.home),
              child: const Text('Retour à l\'accueil'),
            ),
          ],
        ),
      ),
    ),
  );
});
