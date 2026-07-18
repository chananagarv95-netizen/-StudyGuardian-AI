import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared/models/app_category.dart';
import '../../presentation/screens/splash/splash_screen.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/register_screen.dart';
import '../../presentation/screens/pairing/pairing_screen.dart';
import '../../presentation/screens/pairing/scan_qr_screen.dart';
import '../../presentation/screens/pairing/device_list_screen.dart';
import '../../presentation/screens/dashboard/dashboard_screen.dart';
import '../../presentation/screens/app_usage/app_usage_screen.dart';
import '../../presentation/screens/app_usage/app_detail_screen.dart';
import '../../presentation/screens/app_usage/category_breakdown_screen.dart';
import '../../presentation/screens/study_analytics/study_analytics_screen.dart';
import '../../presentation/screens/device_info/device_info_screen.dart';
import '../../presentation/screens/reports/reports_screen.dart';
import '../../presentation/screens/reports/report_detail_screen.dart';
import '../../presentation/screens/notifications/notifications_screen.dart';
import '../../presentation/screens/settings/settings_screen.dart';
import '../../presentation/screens/security/pin_setup_screen.dart';
import '../../presentation/screens/security/auth_gate_screen.dart';
import '../../presentation/screens/study_coach/study_coach_screen.dart';
import '../../presentation/screens/app_usage/category_usage_screen.dart';
import '../di/providers.dart';

/// Navigation shell key for bottom navigation persistence.
final _shellNavigatorKey = GlobalKey<NavigatorState>();

/// GoRouter provider with auth-aware redirect logic.
final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final isSplash = state.matchedLocation == '/splash';
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      // Allow splash to render first
      if (isSplash) return null;

      // Redirect unauthenticated users to login
      if (!isLoggedIn && !isAuthRoute) return '/login';

      // Redirect authenticated users away from auth screens
      if (isLoggedIn && isAuthRoute) return '/dashboard';

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/pairing',
        builder: (context, state) => const PairingScreen(),
      ),
      GoRoute(
        path: '/scan-qr',
        builder: (context, state) => const ScanQRScreen(),
      ),
      GoRoute(
        path: '/devices',
        builder: (context, state) => const DeviceListScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/device-info/:id',
        builder: (context, state) => DeviceInfoScreen(
          deviceId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/usage/detail/:packageName',
        builder: (context, state) => AppDetailScreen(
          packageName: state.pathParameters['packageName']!,
        ),
      ),
      GoRoute(
        path: '/usage/category/:category',
        builder: (context, state) {
          final categoryName = state.pathParameters['category']!;
          final category = AppCategory.values.firstWhere(
            (c) => c.name == categoryName,
            orElse: () => AppCategory.others,
          );
          return CategoryBreakdownScreen(category: category);
        },
      ),
      GoRoute(
        path: '/reports/:id',
        builder: (context, state) => ReportDetailScreen(
          reportId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/pin-setup',
        builder: (context, state) => const PinSetupScreen(),
      ),
      GoRoute(
        path: '/auth-gate',
        builder: (context, state) => const AuthGateScreen(),
      ),
      GoRoute(
        path: '/study-coach',
        builder: (context, state) => const StudyCoachScreen(),
      ),
      GoRoute(
        path: '/category-usage',
        builder: (context, state) => const CategoryUsageScreen(),
      ),

      // Shell route for bottom navigation
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return _ScaffoldWithNav(child: child);
        },
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/usage',
            builder: (context, state) => const AppUsageScreen(),
          ),
          GoRoute(
            path: '/analytics',
            builder: (context, state) => const StudyAnalyticsScreen(),
          ),
          GoRoute(
            path: '/reports',
            builder: (context, state) => const ReportsScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
    ],
  );
});

/// Scaffold wrapper with Material 3 NavigationBar for main tabs.
class _ScaffoldWithNav extends StatelessWidget {
  final Widget child;

  const _ScaffoldWithNav({required this.child});

  static const _tabs = [
    '/dashboard',
    '/usage',
    '/analytics',
    '/reports',
    '/settings',
  ];

  int _locationToIndex(String location) {
    final index = _tabs.indexWhere((tab) => location.startsWith(tab));
    return index < 0 ? 0 : index;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final currentIndex = _locationToIndex(location);

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          context.go(_tabs[index]);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.apps_outlined),
            selectedIcon: Icon(Icons.apps),
            label: 'Usage',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics),
            label: 'Analytics',
          ),
          NavigationDestination(
            icon: Icon(Icons.assessment_outlined),
            selectedIcon: Icon(Icons.assessment),
            label: 'Reports',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
