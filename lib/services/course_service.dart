import '../models/course.dart';
import '../models/review.dart';
import 'api_client.dart';

class CourseService {
  CourseService(this._client);

  final ApiClient _client;

  Future<CourseListResult> list({
    String? subject,
    String? mode,
    String? location,
    double? minRating,
    double? maxFee,
    String? sortBy,
    String? q,
    int page = 1,
    int limit = 10,
  }) async {
    final json = await _client.get(
      '/courses',
      query: {
        'subject': subject,
        'mode': mode,
        'location': location,
        'minRating': minRating,
        'maxFee': maxFee,
        'sortBy': sortBy,
        'q': q,
        'page': page,
        'limit': limit,
      },
    );
    return CourseListResult.fromJson(json as Map<String, dynamic>);
  }

  Future<CourseStats> stats() async {
    final json = await _client.get('/courses/stats');
    return CourseStats.fromJson(json as Map<String, dynamic>);
  }

  Future<Course> detail(int id) async {
    final json = await _client.get('/courses/$id');
    return Course.fromJson(json as Map<String, dynamic>);
  }

  Future<List<Review>> reviews(int id) async {
    final json = await _client.get('/courses/$id/reviews');
    return Review.listFromJson(json);
  }

  Future<void> addReview(int courseId, {required int rating, String? comment}) {
    return _client.post(
      '/courses/$courseId/reviews',
      body: {'rating': rating, 'comment': comment},
    );
  }
}
