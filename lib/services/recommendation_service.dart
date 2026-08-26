import '../models/recommendation.dart';
import 'api_client.dart';

class RecommendationService {
  RecommendationService(this._client);

  final ApiClient _client;

  Future<List<RecommendedCourse>> getRecommendations(
    RecommendationPreferences preferences,
  ) async {
    final json = await _client.post(
      '/recommendations',
      body: preferences.toJson(),
    );
    return RecommendedCourse.listFromResponse(json);
  }
}
