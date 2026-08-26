import 'package:flutter_test/flutter_test.dart';

import 'package:mentora_test/main.dart';
import 'package:mentora_test/providers/auth_provider.dart';
import 'package:mentora_test/providers/enrollment_provider.dart';
import 'package:mentora_test/providers/profile_provider.dart';
import 'package:mentora_test/providers/recommendation_provider.dart';
import 'package:mentora_test/screens/courses/course_list_screen.dart';
import 'package:mentora_test/providers/course_provider.dart';
import 'package:mentora_test/services/api_client.dart';
import 'package:mentora_test/services/auth_service.dart';
import 'package:mentora_test/services/course_service.dart';
import 'package:mentora_test/services/enrollment_service.dart';
import 'package:mentora_test/services/recommendation_service.dart';
import 'package:mentora_test/services/student_service.dart';

void main() {
  testWidgets('shows the course list (public) when logged out', (tester) async {
    final apiClient = ApiClient();
    final authProvider = AuthProvider(AuthService(apiClient));
    apiClient.onUnauthorized = authProvider.handleUnauthorized;
    final courseProvider = CourseProvider(CourseService(apiClient));
    final profileProvider = ProfileProvider(StudentService(apiClient));
    final enrollmentProvider = EnrollmentProvider(EnrollmentService(apiClient));
    final recommendationProvider = RecommendationProvider(
      RecommendationService(apiClient),
    );

    await tester.pumpWidget(
      MyApp(
        apiClient: apiClient,
        authProvider: authProvider,
        courseProvider: courseProvider,
        profileProvider: profileProvider,
        enrollmentProvider: enrollmentProvider,
        recommendationProvider: recommendationProvider,
      ),
    );
    await tester.pump();

    expect(find.byType(CourseListScreen), findsOneWidget);
  });
}
