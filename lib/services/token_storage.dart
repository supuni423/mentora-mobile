import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/user.dart';

/// Persists the current session (JWT + the small amount of user info the
/// backend returns alongside it) so the app doesn't need a network call
/// just to restore login state after a restart. Keeps a synchronous
/// in-memory cache so ApiClient can attach the token without an await per
/// request, and so a later Socket.io phase can read it synchronously too.
class TokenStorage {
  TokenStorage._();
  static final TokenStorage instance = TokenStorage._();

  final _storage = const FlutterSecureStorage();
  static const _tokenKey = 'auth_token';
  static const _userKey = 'auth_user';

  String? _cachedToken;
  User? _cachedUser;

  String? get token => _cachedToken;
  User? get user => _cachedUser;

  Future<void> load() async {
    _cachedToken = await _storage.read(key: _tokenKey);
    final userJson = await _storage.read(key: _userKey);
    if (userJson != null) {
      _cachedUser = User.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
    }
  }

  Future<void> save(String token, {required User user}) async {
    _cachedToken = token;
    _cachedUser = user;
    await _storage.write(key: _tokenKey, value: token);
    await _storage.write(key: _userKey, value: jsonEncode(user.toJson()));
  }

  Future<void> clear() async {
    _cachedToken = null;
    _cachedUser = null;
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userKey);
  }

  /// Sets the in-memory session directly, bypassing the secure-storage
  /// plugin (which needs a platform channel not available in plain `test()`
  /// runs). For tests only — real code paths always go through save/clear.
  @visibleForTesting
  void debugSetSession(String? token, {User? user}) {
    _cachedToken = token;
    _cachedUser = user;
  }
}
