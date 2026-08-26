class Review {
  final int id;
  final int rating;
  final String? comment;
  final String? studentName;
  final DateTime? createdAt;

  Review({
    required this.id,
    required this.rating,
    this.comment,
    this.studentName,
    this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) => Review(
    id: json['id'] as int,
    rating: (json['rating'] as num).toInt(),
    comment: json['comment'] as String?,
    studentName:
        json['student_name'] as String? ??
        (json['student'] as Map<String, dynamic>?)?['name'] as String?,
    createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
  );

  // GET /api/courses/:id/reviews returns a plain JSON array.
  static List<Review> listFromJson(dynamic json) => (json as List? ?? const [])
      .map((e) => Review.fromJson(e as Map<String, dynamic>))
      .toList();
}
