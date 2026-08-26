/// Status values enforced by a DB CHECK constraint on the backend. New
/// enrollments are created with 'requested', not 'pending'.
class EnrollmentStatus {
  static const requested = 'requested';
  static const approved = 'approved';
  static const rejected = 'rejected';
  static const active = 'active';
  static const cancelled = 'cancelled';
  static const pending = 'pending';

  static const all = [requested, approved, active, rejected, cancelled];
}

class Enrollment {
  final int id;
  final int classId;
  final String status;
  final String fullName;
  final String? email;
  final String? phone;
  final String? school;
  final String? grade;
  final String? message;
  final String preferredMode;
  final String selectedDay;
  final String selectedTime;
  final int sessionsAttended;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Joined course/tutor info (present on list/detail, not on a bare create).
  final String? title;
  final String? subject;
  final String? mode;
  final String? location;
  final double? fee;
  final String? image;
  final String? tutorName;
  final Map<String, List<String>> schedule;

  Enrollment({
    required this.id,
    required this.classId,
    required this.status,
    required this.fullName,
    this.email,
    this.phone,
    this.school,
    this.grade,
    this.message,
    required this.preferredMode,
    required this.selectedDay,
    required this.selectedTime,
    this.sessionsAttended = 0,
    this.createdAt,
    this.updatedAt,
    this.title,
    this.subject,
    this.mode,
    this.location,
    this.fee,
    this.image,
    this.tutorName,
    this.schedule = const {},
  });

  factory Enrollment.fromJson(Map<String, dynamic> json) => Enrollment(
    id: json['id'] as int,
    classId: json['class_id'] as int,
    status: json['status'] as String? ?? EnrollmentStatus.requested,
    fullName: json['full_name'] as String? ?? '',
    email: json['email'] as String?,
    phone: json['phone'] as String?,
    school: json['school'] as String?,
    grade: json['grade'] as String?,
    message: json['message'] as String?,
    preferredMode: json['preferred_mode'] as String? ?? '',
    selectedDay: json['selected_day'] as String? ?? '',
    selectedTime: json['selected_time'] as String? ?? '',
    sessionsAttended: json['sessions_attended'] as int? ?? 0,
    createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
    updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? ''),
    title: json['title'] as String?,
    subject: json['subject'] as String?,
    mode: json['mode'] as String?,
    location: json['location'] as String?,
    fee: json['fee'] != null ? double.tryParse(json['fee'].toString()) : null,
    image: json['image'] as String?,
    tutorName: json['tutor_name'] as String?,
    schedule: _parseSchedule(json['schedule']),
  );

  static Map<String, List<String>> _parseSchedule(dynamic raw) {
    if (raw is! Map) return const {};
    return raw.map(
      (key, value) => MapEntry(
        key.toString(),
        (value as List? ?? const []).map((e) => e.toString()).toList(),
      ),
    );
  }

  // GET /api/enrollments/me and /schedule return plain JSON arrays.
  static List<Enrollment> listFromJson(dynamic json) =>
      (json as List? ?? const [])
          .map((e) => Enrollment.fromJson(e as Map<String, dynamic>))
          .toList();

  // POST/PUT return {message, enrollment: {...}}.
  factory Enrollment.fromWrapped(Map<String, dynamic> json) =>
      Enrollment.fromJson(json['enrollment'] as Map<String, dynamic>);
}

class ScheduleItem {
  final int enrollmentId;
  final int courseId;
  final String title;
  final String? subject;
  final String? tutor;
  final String? mode;
  final String? location;
  final String? selectedDay;
  final String? selectedTime;

  ScheduleItem({
    required this.enrollmentId,
    required this.courseId,
    required this.title,
    this.subject,
    this.tutor,
    this.mode,
    this.location,
    this.selectedDay,
    this.selectedTime,
  });

  factory ScheduleItem.fromJson(Map<String, dynamic> json) => ScheduleItem(
    enrollmentId: json['enrollmentId'] as int,
    courseId: json['courseId'] as int,
    title: json['title'] as String? ?? '',
    subject: json['subject'] as String?,
    tutor: json['tutor'] as String?,
    mode: json['mode'] as String?,
    location: json['location'] as String?,
    selectedDay: json['selectedDay'] as String?,
    selectedTime: json['selectedTime'] as String?,
  );

  static List<ScheduleItem> listFromJson(dynamic json) =>
      (json as List? ?? const [])
          .map((e) => ScheduleItem.fromJson(e as Map<String, dynamic>))
          .toList();
}
