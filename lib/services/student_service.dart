import 'dart:io';

import '../models/student_profile.dart';
import 'api_client.dart';

class StudentService {
  StudentService(this._client);

  final ApiClient _client;

  Future<StudentProfile> getProfile() async {
    final json = await _client.get('/students/profile');
    return StudentProfile.fromJson(json as Map<String, dynamic>);
  }

  /// PUT returns only {message, profilePicture} — callers should refetch
  /// getProfile() afterwards for the full updated record.
  Future<void> updateProfile({
    required String name,
    String? phone,
    String? school,
    String? grade,
    String? bio,
    String? address,
    File? profilePicture,
  }) async {
    final fields = <String, String>{
      'name': name,
      'phone': phone ?? '',
      'school': school ?? '',
      'grade': grade ?? '',
      'bio': bio ?? '',
      'address': address ?? '',
    };
    if (profilePicture != null) {
      await _client.multipart(
        '/students/profile',
        fields: fields,
        fileField: 'profilePicture',
        file: profilePicture,
      );
    } else {
      await _client.put('/students/profile', body: fields);
    }
  }
}
