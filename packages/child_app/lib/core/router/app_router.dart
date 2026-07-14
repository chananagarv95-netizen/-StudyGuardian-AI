import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../di/providers.dart';
import '../../presentation/screens/login_screen.dart';
import '../../presentation/screens/join_family_screen.dart';
import '../../presentation/screens/home_screen.dart';
import '../../presentation/screens/permissions_screen.dart';
import '../../presentation/screens/settings_screen.dart';

/// Placeholder screens — these will be replaced by full implementations
/// in a future feature build. They exist now so the router compiles.

class _SplashScreen extends ConsumerWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Navigate based on auth state after a brief delay
    ref.listen(authStateProvider, (_, next) {
      next.whenData((user) {
        if (user != null) {
          context.go('/home');
        } else {
          context.go('/login');
        }
      });
    });

    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shield_outlined, size: 72, color: Color(0xFF6366F1)),
            SizedBox(height: 16),
            Text(
              'StudyGuardian',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            Text(
              'Child',
              style: TextStyle(fontSize: 16, color: Color(0xFF10B981)),
            ),
            SizedBox(height: 32),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

/// GoRouter provider with auth-aware redirect logic for the child app.
final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final isSplash = state.matchedLocation == '/splash';
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/join-family';

      // Allow splash to render first
      if (isSplash) return null;

      // Redirect unauthenticated users to login
      if (!isLoggedIn && !isAuthRoute) return '/login';

      // Redirect authenticated users away from auth screens
      if (isLoggedIn && isAuthRoute) return '/home';

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const _SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/join-family',
        builder: (context, state) => const JoinFamilyScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/permissions',
        builder: (context, state) => const PermissionsScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
});
