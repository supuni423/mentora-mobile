import '../models/enrollment.dart';
import 'api_client.dart';

class EnrollmentService {
  EnrollmentService(this._client);

  final ApiClient _client;

  Future<Enrollment> create({
    required int classId,
    required String fullName,
    required String email,
    String? phone,
    String? school,
    String? grade,
    String? message,
    required String preferredMode,
    required String selectedDay,
    required String selectedTime,
  }) async {
    final json = await _client.post(
      '/enrollments',
      body: {
        'classId': classId,
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'school': school,
        'grade': grade,
        'message': message,
        'preferredMode': preferredMode,
        'selectedDay': selectedDay,
        'selectedTime': selectedTime,
      },
    );
    return Enrollment.fromWrapped(json as Map<String, dynamic>);
  }

  Future<List<Enrollment>> myEnrollments({String? status}) async {
    final json = await _client.get(
      '/enrollments/me',
      query: status != null ? {'status': status} : null,
    );
    return Enrollment.listFromJson(json);
  }

  Future<List<ScheduleItem>> schedule() async {
    final json = await _client.get('/enrollments/schedule');
    return ScheduleItem.listFromJson(json);
  }

  Future<Enrollment> detail(int id) async {
    final json = await _client.get('/enrollments/$id');
    return Enrollment.fromJson(json as Map<String, dynamic>);
  }

  /// The backend requires the full field set on PUT, not a partial patch —
  /// callers pass the enrollment's unchanged identity fields alongside
  /// whatever the student actually edited.
  Future<Enrollment> update(
    int id, {
    required int classId,
    required String fullName,
    required String email,
    String? phone,
    String? school,
    String? grade,
    String? message,
    required String preferredMode,
    required String selectedDay,
    required String selectedTime,
  }) async {
    final json = await _client.put(
      '/enrollments/$id',
      body: {
        'classId': classId,
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'school': school,
        'grade': grade,
        'message': message,
        'preferredMode': preferredMode,
        'selectedDay': selectedDay,
        'selectedTime': selectedTime,
      },
    );
    return Enrollment.fromWrapped(json as Map<String, dynamic>);
  }

  Future<void> cancel(int id) => _client.delete('/enrollments/$id');
}
