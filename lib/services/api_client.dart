import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import 'token_storage.dart';

class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException(this.statusCode, this.message);

  @override
  String toString() => message;
}

/// Central HTTP transport: attaches the auth token to every request,
/// decodes/parses responses, and reports 401s to whoever owns the session
/// (see [onUnauthorized]) instead of every screen handling it separately.
class ApiClient {
  ApiClient({TokenStorage? tokenStorage})
    : _tokenStorage = tokenStorage ?? TokenStorage.instance;

  final TokenStorage _tokenStorage;
  final http.Client _client = http.Client();

  /// Called when a request fails with 401 while a session token was set,
  /// i.e. the server considers the current session invalid. There is no
  /// refresh-token flow on this backend, so the only recovery is to clear
  /// the token and send the user back to login.
  void Function()? onUnauthorized;

  Uri _buildUri(String path, [Map<String, dynamic>? query]) {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}$path');
    if (query == null || query.isEmpty) return uri;
    final params = <String, String>{};
    query.forEach((key, value) {
      if (value != null) params[key] = value.toString();
    });
    if (params.isEmpty) return uri;
    return uri.replace(queryParameters: params);
  }

  Map<String, String> _headers({bool json = true}) {
    final headers = <String, String>{
      if (json) 'Content-Type': 'application/json',
    };
    final token = _tokenStorage.token;
    if (token != null) headers['Authorization'] = 'Bearer $token';
    return headers;
  }

  Future<dynamic> get(String path, {Map<String, dynamic>? query}) async {
    final res = await _client.get(
      _buildUri(path, query),
      headers: _headers(json: false),
    );
    return _handle(res);
  }

  Future<dynamic> post(String path, {Object? body}) async {
    final res = await _client.post(
      _buildUri(path),
      headers: _headers(),
      body: body == null ? null : jsonEncode(body),
    );
    return _handle(res);
  }

  Future<dynamic> put(String path, {Object? body}) async {
    final res = await _client.put(
      _buildUri(path),
      headers: _headers(),
      body: body == null ? null : jsonEncode(body),
    );
    return _handle(res);
  }

  Future<dynamic> delete(String path) async {
    final res = await _client.delete(
      _buildUri(path),
      headers: _headers(json: false),
    );
    return _handle(res);
  }

  /// multipart/form-data request, used for the profile-picture upload.
  Future<dynamic> multipart(
    String path, {
    String method = 'PUT',
    Map<String, String>? fields,
    String? fileField,
    File? file,
  }) async {
    final request = http.MultipartRequest(method, _buildUri(path));
    final token = _tokenStorage.token;
    if (token != null) request.headers['Authorization'] = 'Bearer $token';
    if (fields != null) request.fields.addAll(fields);
    if (file != null && fileField != null) {
      request.files.add(
        await http.MultipartFile.fromPath(fileField, file.path),
      );
    }
    final streamed = await _client.send(request);
    final res = await http.Response.fromStream(streamed);
    return _handle(res);
  }

  dynamic _handle(http.Response res) {
    final status = res.statusCode;
    dynamic decoded;
    if (res.body.isNotEmpty) {
      try {
        decoded = jsonDecode(res.body);
      } catch (_) {
        decoded = res.body;
      }
    }

    if (status == 401 && _tokenStorage.token != null) {
      // An active session just got rejected server-side (expired/invalid
      // token) — clear it and let AuthProvider redirect to login. A 401 on
      // a login attempt (no token stored yet) is just a bad-credentials
      // error and should surface inline instead, so it's excluded above.
      _tokenStorage.clear();
      onUnauthorized?.call();
    }

    if (status < 200 || status >= 300) {
      String message = 'Request failed ($status)';
      if (decoded is Map<String, dynamic>) {
        final m = decoded['message'] ?? decoded['error'];
        if (m != null) message = m.toString();
      } else if (decoded is String && decoded.isNotEmpty) {
        message = decoded;
      }
      throw ApiException(status, message);
    }

    return decoded;
  }
}
