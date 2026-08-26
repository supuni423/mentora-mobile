class StudentProfileStats {
  final int classesEnrolled;
  final int activeClasses;
  final int pendingApprovals;
  final int sessionsAttended;
  final int subjectsStudying;
  final double avgRatingGiven;

  StudentProfileStats({
    this.classesEnrolled = 0,
    this.activeClasses = 0,
    this.pendingApprovals = 0,
    this.sessionsAttended = 0,
    this.subjectsStudying = 0,
    this.avgRatingGiven = 0,
  });

  factory StudentProfileStats.fromJson(Map<String, dynamic> json) =>
      StudentProfileStats(
        classesEnrolled: json['classesEnrolled'] as int? ?? 0,
        activeClasses: json['activeClasses'] as int? ?? 0,
        pendingApprovals: json['pendingApprovals'] as int? ?? 0,
        sessionsAttended: json['sessionsAttended'] as int? ?? 0,
        subjectsStudying: json['subjectsStudying'] as int? ?? 0,
        avgRatingGiven: (json['avgRatingGiven'] as num?)?.toDouble() ?? 0,
      );
}

class StudentProfile {
  final String name;
  final String email;
  final String? phone;
  final String? school;
  final String? grade;
  final String? bio;
  final String? address;
  final String? profilePicture;
  final StudentProfileStats stats;

  StudentProfile({
    required this.name,
    required this.email,
    this.phone,
    this.school,
    this.grade,
    this.bio,
    this.address,
    this.profilePicture,
    required this.stats,
  });

  factory StudentProfile.fromJson(Map<String, dynamic> json) => StudentProfile(
    name: json['name'] as String? ?? '',
    email: json['email'] as String? ?? '',
    phone: json['phone'] as String?,
    school: json['school'] as String?,
    grade: json['grade'] as String?,
    bio: json['bio'] as String?,
    address: json['address'] as String?,
    profilePicture: json['profilePicture'] as String?,
    stats: StudentProfileStats.fromJson(
      json['stats'] as Map<String, dynamic>? ?? const {},
    ),
  );
}
