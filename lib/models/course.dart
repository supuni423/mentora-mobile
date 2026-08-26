class Course {
  final int id;
  final int tutorId;
  final String title;
  final String subject;
  final String? description;
  final double fee;
  final String? mode;
  final String? location;
  final Map<String, List<String>> schedule;
  final List<String> whatYouLearn;
  final int? maxStudents;
  final String? status;
  final double averageRating;
  final int reviewCount;
  final String? badge;
  final String? image;
  final DateTime? createdAt;
  final String? grade;
  final String? medium;
  final String? tutorName;

  // Detail-only fields (present on GET /api/courses/:id, absent on the list).
  final int? enrolledCount;
  final String? tutorAvatar;
  final String? tutorBio;
  final String? tutorUniversity;
  final String? tutorCity;
  final bool? tutorIsVerified;
  final double? tutorAverageRating;

  Course({
    required this.id,
    required this.tutorId,
    required this.title,
    required this.subject,
    this.description,
    required this.fee,
    this.mode,
    this.location,
    this.schedule = const {},
    this.whatYouLearn = const [],
    this.maxStudents,
    this.status,
    this.averageRating = 0,
    this.reviewCount = 0,
    this.badge,
    this.image,
    this.createdAt,
    this.grade,
    this.medium,
    this.tutorName,
    this.enrolledCount,
    this.tutorAvatar,
    this.tutorBio,
    this.tutorUniversity,
    this.tutorCity,
    this.tutorIsVerified,
    this.tutorAverageRating,
  });

  String get feeDisplay => 'Rs. ${fee.toStringAsFixed(0)}';

  factory Course.fromJson(Map<String, dynamic> json) => Course(
    id: json['id'] as int,
    tutorId: json['tutor_id'] as int,
    title: json['title'] as String? ?? '',
    subject: json['subject'] as String? ?? '',
    description: json['description'] as String?,
    fee: double.tryParse(json['fee']?.toString() ?? '') ?? 0,
    mode: json['mode'] as String?,
    location: json['location'] as String?,
    schedule: _parseSchedule(json['schedule']),
    whatYouLearn:
        (json['what_you_learn'] as List?)?.map((e) => e.toString()).toList() ??
        const [],
    maxStudents: json['max_students'] as int?,
    status: json['status'] as String?,
    averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0,
    reviewCount: json['review_count'] as int? ?? 0,
    badge: json['badge'] as String?,
    image: json['image'] as String?,
    createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
    grade: json['grade'] as String?,
    medium: json['medium'] as String?,
    tutorName: json['tutor_name'] as String?,
    enrolledCount: json['enrolledCount'] as int?,
    tutorAvatar: json['tutor_avatar'] as String?,
    tutorBio: json['tutor_bio'] as String?,
    tutorUniversity: json['tutor_university'] as String?,
    tutorCity: json['tutor_city'] as String?,
    tutorIsVerified: json['tutor_is_verified'] as bool?,
    tutorAverageRating: (json['tutor_average_rating'] as num?)?.toDouble(),
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
}

class CourseListResult {
  final List<Course> courses;
  final int total;
  final int totalPages;
  final int currentPage;

  CourseListResult({
    required this.courses,
    required this.total,
    required this.totalPages,
    required this.currentPage,
  });

  factory CourseListResult.fromJson(Map<String, dynamic> json) =>
      CourseListResult(
        courses: (json['courses'] as List? ?? const [])
            .map((e) => Course.fromJson(e as Map<String, dynamic>))
            .toList(),
        total: json['total'] as int? ?? 0,
        totalPages: json['totalPages'] as int? ?? 1,
        currentPage: json['currentPage'] as int? ?? 1,
      );
}

class CourseStats {
  final int totalCourses;
  final int totalTutors;
  final int totalStudents;
  final int totalReviews;

  CourseStats({
    required this.totalCourses,
    required this.totalTutors,
    required this.totalStudents,
    required this.totalReviews,
  });

  factory CourseStats.fromJson(Map<String, dynamic> json) => CourseStats(
    totalCourses: json['totalCourses'] as int? ?? 0,
    totalTutors: json['totalTutors'] as int? ?? 0,
    totalStudents: json['totalStudents'] as int? ?? 0,
    totalReviews: json['totalReviews'] as int? ?? 0,
  );
}
