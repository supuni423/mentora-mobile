import 'package:flutter_test/flutter_test.dart';

import 'package:mentora_test/main.dart';
import 'package:mentora_test/providers/auth_provider.dart';
import 'package:mentora_test/providers/enrollment_provider.dart';
import 'package:mentora_test/providers/profile_provider.dart';
import 'package:mentora_test/providers/recommendation_provider.dart';
import 'package:mentora_test/screens/courses/course_list_screen.dart';
import 'package:mentora_test/screens/welcome/welcome_screen.dart';
import 'package:mentora_test/providers/course_provider.dart';
import 'package:mentora_test/services/api_client.dart';
import 'package:mentora_test/services/auth_service.dart';
import 'package:mentora_test/services/course_service.dart';
import 'package:mentora_test/services/enrollment_service.dart';
import 'package:mentora_test/services/recommendation_service.dart';
import 'package:mentora_test/services/student_service.dart';

void main() {
  MyApp buildApp() {
    final apiClient = ApiClient();
    final authProvider = AuthProvider(AuthService(apiClient));
    apiClient.onUnauthorized = authProvider.handleUnauthorized;
    return MyApp(
      apiClient: apiClient,
      authProvider: authProvider,
      courseProvider: CourseProvider(CourseService(apiClient)),
      profileProvider: ProfileProvider(StudentService(apiClient)),
      enrollmentProvider: EnrollmentProvider(EnrollmentService(apiClient)),
      recommendationProvider: RecommendationProvider(
        RecommendationService(apiClient),
      ),
    );
  }

  testWidgets('shows the welcome screen first', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pump();

    expect(find.byType(WelcomeScreen), findsOneWidget);
  });

  testWidgets('Browse Courses leads to the public course list', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pump();

    await tester.tap(find.text('Browse Courses'));
    await tester.pump();

    expect(find.byType(CourseListScreen), findsOneWidget);
  });
}
