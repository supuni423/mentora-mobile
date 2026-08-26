import '../models/user.dart';
import 'api_client.dart';

class AuthService {
  AuthService(this._client);

  final ApiClient _client;

  Future<void> sendVerification(String email) =>
      _client.post('/auth/send-verification', body: {'email': email});

  Future<void> verifyEmail({required String email, required String otp}) =>
      _client.post('/auth/verify-email', body: {'email': email, 'otp': otp});

  Future<AuthResult> registerStudent({
    required String email,
    required String password,
    required String fullName,
    required String school,
    required int age,
    required String language,
    required String gradeLevel,
    required String address,
  }) async {
    final json = await _client.post(
      '/auth/register/student',
      body: {
        'email': email,
        'password': password,
        'fullName': fullName,
        'school': school,
        'age': age,
        'language': language,
        'gradeLevel': gradeLevel,
        'address': address,
      },
    );
    return AuthResult.fromJson(json as Map<String, dynamic>);
  }

  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    final json = await _client.post(
      '/auth/login',
      body: {'email': email, 'password': password},
    );
    return AuthResult.fromJson(json as Map<String, dynamic>);
  }

  Future<void> forgotPassword(String email) =>
      _client.post('/auth/forgot-password', body: {'email': email});

  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) => _client.post(
    '/auth/reset-password',
    body: {'email': email, 'otp': otp, 'newPassword': newPassword},
  );

  Future<void> deleteAccount() => _client.delete('/auth/account');
}
