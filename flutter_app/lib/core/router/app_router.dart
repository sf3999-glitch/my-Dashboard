import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/providers/auth_provider.dart';
import '../../presentation/screens/splash_screen.dart';
import '../../presentation/screens/onboarding_screen.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/register_screen.dart';
import '../../presentation/screens/auth/forgot_password_screen.dart';
import '../../presentation/screens/home_screen.dart';
import '../../presentation/screens/project/new_project_screen.dart';
import '../../presentation/screens/project/project_detail_screen.dart';
import '../../presentation/screens/project/floor_plan_screen.dart';
import '../../presentation/screens/project/cost_estimate_screen.dart';
import '../../presentation/screens/project/materials_screen.dart';
import '../../presentation/screens/project/report_screen.dart';
import '../../presentation/screens/settings_screen.dart';
import '../../presentation/screens/profile_screen.dart';

// Route names
class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String newProject = '/project/new';
  static const String projectDetail = '/project/:id';
  static const String floorPlan = '/project/:id/floor-plan';
  static const String costEstimate = '/project/:id/cost';
  static const String materials = '/project/:id/materials';
  static const String report = '/project/:id/report';
  static const String settings = '/settings';
  static const String profile = '/profile';
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: GoRouterRefreshStream(ref.watch(authProvider.notifier).stream),
    redirect: (context, state) {
      final isAuthenticated = authState.isAuthenticated;
      final isLoading = authState.isLoading;

      if (isLoading) return null;

      final isAuthRoute = state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.register ||
          state.matchedLocation == AppRoutes.forgotPassword ||
          state.matchedLocation == AppRoutes.onboarding ||
          state.matchedLocation == AppRoutes.splash;

      if (!isAuthenticated && !isAuthRoute) {
        return AppRoutes.login;
      }

      if (isAuthenticated && (state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.register)) {
        return AppRoutes.home;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.newProject,
        name: 'new-project',
        builder: (context, state) => const NewProjectScreen(),
      ),
      GoRoute(
        path: AppRoutes.projectDetail,
        name: 'project-detail',
        builder: (context, state) {
          final projectId = state.pathParameters['id']!;
          return ProjectDetailScreen(projectId: projectId);
        },
      ),
      GoRoute(
        path: AppRoutes.floorPlan,
        name: 'floor-plan',
        builder: (context, state) {
          final projectId = state.pathParameters['id']!;
          return FloorPlanScreen(projectId: projectId);
        },
      ),
      GoRoute(
        path: AppRoutes.costEstimate,
        name: 'cost-estimate',
        builder: (context, state) {
          final projectId = state.pathParameters['id']!;
          return CostEstimateScreen(projectId: projectId);
        },
      ),
      GoRoute(
        path: AppRoutes.materials,
        name: 'materials',
        builder: (context, state) {
          final projectId = state.pathParameters['id']!;
          return MaterialsScreen(projectId: projectId);
        },
      ),
      GoRoute(
        path: AppRoutes.report,
        name: 'report',
        builder: (context, state) {
          final projectId = state.pathParameters['id']!;
          return ReportScreen(projectId: projectId);
        },
      ),
      GoRoute(
        path: AppRoutes.settings,
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
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
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(state.error?.message ?? 'Unknown error'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.home),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});

// Helper class to convert StateNotifier stream to Listenable
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final dynamic _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
