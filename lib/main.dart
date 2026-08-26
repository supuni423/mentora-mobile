import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/course_provider.dart';
import 'providers/enrollment_provider.dart';
import 'providers/profile_provider.dart';
import 'screens/home/home_shell.dart';
import 'services/api_client.dart';
import 'services/auth_service.dart';
import 'services/course_service.dart';
import 'services/enrollment_service.dart';
import 'services/student_service.dart';
import 'services/token_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await TokenStorage.instance.load();

  final apiClient = ApiClient();
  final authProvider = AuthProvider(AuthService(apiClient));
  apiClient.onUnauthorized = authProvider.handleUnauthorized;
  final courseProvider = CourseProvider(CourseService(apiClient));
  final profileProvider = ProfileProvider(StudentService(apiClient));
  final enrollmentProvider = EnrollmentProvider(EnrollmentService(apiClient));

  runApp(
    MyApp(
      apiClient: apiClient,
      authProvider: authProvider,
      courseProvider: courseProvider,
      profileProvider: profileProvider,
      enrollmentProvider: enrollmentProvider,
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
  });

  final ApiClient apiClient;
  final AuthProvider authProvider;
  final CourseProvider courseProvider;
  final ProfileProvider profileProvider;
  final EnrollmentProvider enrollmentProvider;

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
      ],
      child: MaterialApp(
        title: 'Mentora',
        theme: ThemeData(
          colorSchemeSeed: const Color(0xFF1DD3A5),
          useMaterial3: true,
        ),
        home: const HomeShell(),
      ),
    );
  }
}
