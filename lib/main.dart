import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/course_provider.dart';
import 'providers/enrollment_provider.dart';
import 'providers/profile_provider.dart';
import 'providers/recommendation_provider.dart';
import 'screens/home/home_shell.dart';
import 'screens/welcome/welcome_screen.dart';
import 'services/api_client.dart';
import 'services/auth_service.dart';
import 'services/course_service.dart';
import 'services/enrollment_service.dart';
import 'services/recommendation_service.dart';
import 'services/student_service.dart';
import 'services/token_storage.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await TokenStorage.instance.load();

  final apiClient = ApiClient();
  final authProvider = AuthProvider(AuthService(apiClient));
  apiClient.onUnauthorized = authProvider.handleUnauthorized;
  final courseProvider = CourseProvider(CourseService(apiClient));
  final profileProvider = ProfileProvider(StudentService(apiClient));
  final enrollmentProvider = EnrollmentProvider(EnrollmentService(apiClient));
  final recommendationProvider = RecommendationProvider(
    RecommendationService(apiClient),
  );

  runApp(
    MyApp(
      apiClient: apiClient,
      authProvider: authProvider,
      courseProvider: courseProvider,
      profileProvider: profileProvider,
      enrollmentProvider: enrollmentProvider,
      recommendationProvider: recommendationProvider,
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.apiClient,
    required this.authProvider,
    required this.courseProvider,
    required this.profileProvider,
    required this.enrollmentProvider,
    required this.recommendationProvider,
  });

  final ApiClient apiClient;
  final AuthProvider authProvider;
  final CourseProvider courseProvider;
  final ProfileProvider profileProvider;
  final EnrollmentProvider enrollmentProvider;
  final RecommendationProvider recommendationProvider;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ApiClient>.value(value: apiClient),
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ChangeNotifierProvider<CourseProvider>.value(value: courseProvider),
        ChangeNotifierProvider<ProfileProvider>.value(value: profileProvider),
        ChangeNotifierProvider<EnrollmentProvider>.value(
          value: enrollmentProvider,
        ),
        ChangeNotifierProvider<RecommendationProvider>.value(
          value: recommendationProvider,
        ),
      ],
      child: MaterialApp(
        title: 'Mentora',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        // This is a phone UI — on a wide browser window (the web target),
        // constrain to a phone-like width instead of stretching grids/cards
        // edge to edge. No-op on real mobile devices, whose screens are
        // already narrower than this.
        builder: (context, child) => ColoredBox(
          color: AppColors.background,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: child,
            ),
          ),
        ),
        home: const _AppRoot(),
      ),
    );
  }
}

/// Swaps Welcome for HomeShell in-place (same root route) rather than
/// pushing a new one, so Login/Register's `popUntil((r) => r.isFirst)`
/// still lands correctly regardless of which of the two is currently shown.
class _AppRoot extends StatefulWidget {
  const _AppRoot();

  @override
  State<_AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<_AppRoot> {
  bool _showWelcome = true;

  @override
  Widget build(BuildContext context) {
    if (_showWelcome) {
      return WelcomeScreen(
        onGetStarted: () => setState(() => _showWelcome = false),
      );
    }
    return const HomeShell();
  }
}
