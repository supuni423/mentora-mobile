import 'dart:io' show HttpOverrides;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mentora_test/services/api_client.dart';
import 'package:mentora_test/services/auth_service.dart';
import 'package:mentora_test/services/student_service.dart';
import 'package:mentora_test/services/token_storage.dart';

// Hits the live backend. Also mocks the flutter_secure_storage platform
// channel (unavailable in plain `test()` runs) so TokenStorage.clear() —
// which ApiClient calls for real on a 401 — doesn't throw.
const _secureStorageChannel = MethodChannel(
  'plugins.it_nomads.com/flutter_secure_storage',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    // TestWidgetsFlutterBinding installs HttpOverrides that fake every
    // request as a 400 — these tests intentionally hit the real backend.
    HttpOverrides.global = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_secureStorageChannel, (call) async => null);
    TokenStorage.instance.debugSetSession(null);
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_secureStorageChannel, null);
    TokenStorage.instance.debugSetSession(null);
  });

  test('loads and round-trips the student profile', () async {
    final apiClient = ApiClient();
    final result = await AuthService(apiClient)
        .login(email: 'testboy@gmail.com', password: 'testboy@123');
    TokenStorage.instance.debugSetSession(result.token, user: result.user);

    final student = StudentService(apiClient);
    final profile = await student.getProfile();

    expect(profile.email, 'testboy@gmail.com');
    expect(profile.stats.classesEnrolled, greaterThanOrEqualTo(0));

    // Idempotent save (writes back the same values) to confirm the PUT
    // round-trips without throwing, then confirm a reload reflects it.
    await student.updateProfile(
      name: profile.name,
      phone: profile.phone,
      school: profile.school,
      grade: profile.grade,
      bio: profile.bio,
      address: profile.address,
    );
    final reloaded = await student.getProfile();
    expect(reloaded.name, profile.name);
    expect(reloaded.school, profile.school);
  });

  test('a rejected token clears the session via onUnauthorized', () async {
    final apiClient = ApiClient();
    var unauthorizedFired = false;
    apiClient.onUnauthorized = () => unauthorizedFired = true;

    TokenStorage.instance.debugSetSession('deliberately-invalid-token');

    await expectLater(
      StudentService(apiClient).getProfile(),
      throwsA(isA<ApiException>()),
    );

    expect(unauthorizedFired, isTrue);
    expect(TokenStorage.instance.token, isNull);
  });
}
