class RecommendedTutor {
  final String name;
  final String? experience;
  final String? university;
  final String? degree;
  final String? city;
  final String? profilePicture;

  RecommendedTutor({
    required this.name,
    this.experience,
    this.university,
    this.degree,
    this.city,
    this.profilePicture,
  });

  factory RecommendedTutor.fromJson(Map<String, dynamic> json) =>
      RecommendedTutor(
        name: json['name'] as String? ?? 'Tutor',
        experience: json['experience'] as String?,
        university: json['university'] as String?,
        degree: json['degree'] as String?,
        city: json['city'] as String?,
        profilePicture: json['profile_picture'] as String?,
      );
}

class RecommendedCourse {
  final int id;
  final int tutorId;
  final String title;
  final String subject;
  final double fee;
  final String? mode;
  final String? location;
  final String? image;
  final double rating;
  final int reviews;
  final String? badge;
  final List<String> whatYouLearn;
  final Map<String, List<String>> schedule;
  final RecommendedTutor tutor;
  final int matchScore;
  final String aiInsight;

  RecommendedCourse({
    required this.id,
    required this.tutorId,
    required this.title,
    required this.subject,
    required this.fee,
    this.mode,
    this.location,
    this.image,
    this.rating = 0,
    this.reviews = 0,
    this.badge,
    this.whatYouLearn = const [],
    this.schedule = const {},
    required this.tutor,
    required this.matchScore,
    required this.aiInsight,
  });

  String get feeDisplay => 'Rs. ${fee.toStringAsFixed(0)}';

  factory RecommendedCourse.fromJson(Map<String, dynamic> json) =>
      RecommendedCourse(
        id: json['id'] as int,
        tutorId: json['tutor_id'] as int,
        title: json['title'] as String? ?? '',
        subject: json['subject'] as String? ?? '',
        fee: double.tryParse(json['fee']?.toString() ?? '') ?? 0,
        mode: json['mode'] as String?,
        location: json['location'] as String?,
        image: json['image'] as String?,
        rating: (json['rating'] as num?)?.toDouble() ?? 0,
        reviews: json['reviews'] as int? ?? 0,
        badge: json['badge'] as String?,
        whatYouLearn:
            (json['what_you_learn'] as List?)
                ?.map((e) => e.toString())
                .toList() ??
            const [],
        schedule: _parseSchedule(json['schedule']),
        tutor: RecommendedTutor.fromJson(
          json['tutor'] as Map<String, dynamic>? ?? const {},
        ),
        matchScore: json['matchScore'] as int? ?? 0,
        aiInsight: json['aiInsight'] as String? ?? '',
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

  // POST /api/recommendations returns { data: [...] }.
  static List<RecommendedCourse> listFromResponse(dynamic json) {
    final data = (json as Map<String, dynamic>)['data'] as List? ?? const [];
    return data
        .map((e) => RecommendedCourse.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

/// Request DTO for POST /api/recommendations. All fields optional — an
/// empty body still returns every active course scored with neutral
/// defaults, so callers don't need to force every field.
class RecommendationPreferences {
  final List<String> subjects;
  final String? level;
  final String? mode; // must be exactly 'Online' | 'Physical' | 'Both'
  final List<String> availableDays;
  final double? budget;
  final String? goal;
  final String? city;

  RecommendationPreferences({
    this.subjects = const [],
    this.level,
    this.mode,
    this.availableDays = const [],
    this.budget,
    this.goal,
    this.city,
  });

  Map<String, dynamic> toJson() => {
    if (subjects.isNotEmpty) 'subjects': subjects,
    if (level != null && level!.isNotEmpty) 'level': level,
    if (mode != null) 'mode': mode,
    if (availableDays.isNotEmpty) 'availableDays': availableDays,
    if (budget != null && budget! > 0) 'budget': budget,
    if (goal != null && goal!.isNotEmpty) 'goal': goal,
    if (city != null && city!.isNotEmpty) 'city': city,
  };
}
