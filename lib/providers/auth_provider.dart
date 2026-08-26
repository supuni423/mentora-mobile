import 'package:flutter/foundation.dart';

import '../models/user.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../services/token_storage.dart';

enum AuthStatus { authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._authService) {
    final storage = TokenStorage.instance;
    status = storage.token != null
        ? AuthStatus.authenticated
        : AuthStatus.unauthenticated;
    user = storage.user;
  }

  final AuthService _authService;

  late AuthStatus status;
  User? user;
  bool isLoading = false;
  String? errorMessage;

  bool get isAuthenticated => status == AuthStatus.authenticated;

  Future<bool> _run(Future<void> Function() action) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      await action();
      return true;
    } on ApiException catch (e) {
      errorMessage = e.message;
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login({required String email, required String password}) {
    return _run(() async {
      final result = await _authService.login(email: email, password: password);
      await TokenStorage.instance.save(result.token, user: result.user);
      user = result.user;
      status = AuthStatus.authenticated;
    });
  }

  Future<bool> sendVerification(String email) {
    return _run(() => _authService.sendVerification(email));
  }

  Future<bool> verifyEmail({required String email, required String otp}) {
    return _run(() => _authService.verifyEmail(email: email, otp: otp));
  }

  Future<bool> registerStudent({
    required String email,
    required String password,
    required String fullName,
    required String school,
    required int age,
    required String language,
    required String gradeLevel,
    required String address,
  }) {
    return _run(() async {
      final result = await _authService.registerStudent(
        email: email,
        password: password,
        fullName: fullName,
        school: school,
        age: age,
        language: language,
        gradeLevel: gradeLevel,
        address: address,
      );
      await TokenStorage.instance.save(result.token, user: result.user);
      user = result.user;
      status = AuthStatus.authenticated;
    });
  }

  Future<bool> forgotPassword(String email) {
    return _run(() => _authService.forgotPassword(email));
  }

  Future<bool> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) {
    return _run(
      () => _authService.resetPassword(
        email: email,
        otp: otp,
        newPassword: newPassword,
      ),
    );
  }

  Future<bool> deleteAccount() {
    return _run(() async {
      await _authService.deleteAccount();
      await TokenStorage.instance.clear();
      user = null;
      status = AuthStatus.unauthenticated;
    });
  }

  Future<void> logout() async {
    await TokenStorage.instance.clear();
    user = null;
    status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  /// Registered as ApiClient.onUnauthorized — fires when the server rejects
  /// an existing session (no refresh-token flow exists, so this is the only
  /// recovery path).
  void handleUnauthorized() {
    user = null;
    status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }
}
