import 'dart:io' show HttpOverrides;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mentora_test/models/enrollment.dart';
import 'package:mentora_test/services/api_client.dart';
import 'package:mentora_test/services/auth_service.dart';
import 'package:mentora_test/services/course_service.dart';
import 'package:mentora_test/services/enrollment_service.dart';
import 'package:mentora_test/services/token_storage.dart';

// Hits the live backend and exercises the full student booking loop:
// browse a course -> submit -> land in Requested -> edit while requested
// -> cancel. Cleans up after itself either way.
const _secureStorageChannel = MethodChannel(
  'plugins.it_nomads.com/flutter_secure_storage',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    HttpOverrides.global = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_secureStorageChannel, (call) async => null);
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_secureStorageChannel, null);
    TokenStorage.instance.debugSetSession(null);
  });

  test('create -> requested -> edit while requested -> cancel', () async {
    final apiClient = ApiClient();
    final auth = await AuthService(apiClient)
        .login(email: 'testboy@gmail.com', password: 'testboy@123');
    TokenStorage.instance.debugSetSession(auth.token, user: auth.user);

    final courses = CourseService(apiClient);
    final enrollments = EnrollmentService(apiClient);

    final course = (await courses.list(
      subject: 'ICT',
      page: 1,
      limit: 5,
    )).courses.firstWhere((c) => c.schedule.isNotEmpty);
    final day = course.schedule.keys.first;
    final time = course.schedule[day]!.first;

    Enrollment? created;
    try {
      created = await enrollments.create(
        classId: course.id,
        fullName: 'Test boy',
        email: 'testboy@gmail.com',
        phone: '0771112222',
        school: 'Test High School',
        grade: 'A/L',
        message: 'Automated verification enrollment',
        preferredMode: course.mode ?? 'online',
        selectedDay: day,
        selectedTime: time,
      );

      expect(created.status, EnrollmentStatus.requested);
      expect(created.classId, course.id);

      final mine = await enrollments.myEnrollments();
      expect(
        mine.any(
          (e) => e.id == created!.id && e.status == EnrollmentStatus.requested,
        ),
        isTrue,
      );

      final updated = await enrollments.update(
        created.id,
        classId: course.id,
        fullName: 'Test boy',
        email: 'testboy@gmail.com',
        phone: '0771112222',
        school: 'Test High School',
        grade: 'A/L',
        message: 'Updated by automated verification',
        preferredMode: course.mode ?? 'online',
        selectedDay: day,
        selectedTime: time,
      );
      expect(updated.message, 'Updated by automated verification');
    } finally {
      if (created != null) {
        await enrollments.cancel(created.id);
        final mineAfterCancel = await enrollments.myEnrollments();
        expect(mineAfterCancel.any((e) => e.id == created!.id), isFalse);
      }
    }
  });
}
