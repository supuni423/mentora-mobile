import 'package:flutter_test/flutter_test.dart';

import 'package:mentora_test/services/api_client.dart';
import 'package:mentora_test/services/course_service.dart';

// Hits the live backend.
void main() {
  final service = CourseService(ApiClient());

  test('lists courses with correctly parsed fields', () async {
    final result = await service.list(page: 1, limit: 2);

    expect(result.courses, isNotEmpty);
    expect(result.totalPages, greaterThan(0));

    final course = result.courses.first;
    expect(course.id, greaterThan(0));
    expect(course.title, isNotEmpty);
    expect(course.fee, greaterThanOrEqualTo(0));
  });

  test('filters by subject and respects pagination params', () async {
    final result = await service.list(subject: 'ICT', page: 1, limit: 1);
    expect(result.courses.length, lessThanOrEqualTo(1));
    for (final c in result.courses) {
      expect(c.subject.toLowerCase(), contains('ict'));
    }
  });

  test('loads course detail and reviews for a known course', () async {
    final list = await service.list(page: 1, limit: 1);
    final id = list.courses.first.id;

    final detail = await service.detail(id);
    expect(detail.id, id);
    expect(detail.tutorName, isNotNull);

    // GET /api/courses/:id/reviews returns a plain JSON array.
    final reviews = await service.reviews(id);
    expect(reviews.length, detail.reviewCount);
  });

  test('platform stats load', () async {
    final stats = await service.stats();
    expect(stats.totalCourses, greaterThan(0));
  });
}
