import 'package:flutter_test/flutter_test.dart';

import 'package:mentora_test/services/api_client.dart';
import 'package:mentora_test/services/auth_service.dart';

// Hits the live backend with the documented test student account.
void main() {
  test('login succeeds with the test student account', () async {
    final auth = AuthService(ApiClient());
    final result = await auth.login(
      email: 'testboy@gmail.com',
      password: 'testboy@123',
    );

    expect(result.token, isNotEmpty);
    expect(result.user.role, 'student');
    expect(result.user.email, 'testboy@gmail.com');
  });

  test(
    'login with a bad password throws an ApiException with a message',
    () async {
      // Note: this backend's login controller returns 400 (not 401) for bad
      // credentials — 401 is reserved for an already-issued token being
      // rejected. ApiClient's onUnauthorized/forced-logout path only fires on
      // 401, so this correctly does not affect app-wide session state.
      final auth = AuthService(ApiClient());

      await expectLater(
        auth.login(email: 'testboy@gmail.com', password: 'definitely-wrong'),
        throwsA(
          isA<ApiException>().having((e) => e.statusCode, 'statusCode', 400),
        ),
      );
    },
  );

  test('send-verification accepts a well-formed email', () async {
    final auth = AuthService(ApiClient());
    await auth.sendVerification(
      'smoke-test-${DateTime.now().millisecondsSinceEpoch}@example.com',
    );
    // No exception thrown = 2xx response; full OTP round-trip requires
    // reading a real inbox, so registration's later steps aren't covered
    // by this automated check.
  });
}
