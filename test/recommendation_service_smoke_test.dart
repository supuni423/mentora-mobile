import 'package:flutter_test/flutter_test.dart';

import 'package:mentora_test/models/recommendation.dart';
import 'package:mentora_test/services/api_client.dart';
import 'package:mentora_test/services/recommendation_service.dart';

// Hits the live backend, including the real Gemini call (or its template
// fallback) inside recommendationService.js.
void main() {
  final service = RecommendationService(ApiClient());

  test('returns matches sorted by score with a non-empty AI insight each', () async {
    final results = await service.getRecommendations(
      RecommendationPreferences(
        subjects: ['ICT', 'Mathematics'],
        level: 'A/L',
        mode: 'Online',
        availableDays: ['Monday', 'Wednesday'],
        budget: 3000,
        goal: 'Improve for the A/L exam',
        city: 'Colombo',
      ),
    );

    expect(results, isNotEmpty);

    for (var i = 0; i < results.length - 1; i++) {
      expect(results[i].matchScore, greaterThanOrEqualTo(results[i + 1].matchScore));
    }

    for (final course in results) {
      expect(course.aiInsight, isNotEmpty);
      expect(course.tutor.name, isNotEmpty);
    }
  });

  test('an empty preference body still returns scored results', () async {
    final results = await service.getRecommendations(RecommendationPreferences());
    expect(results, isNotEmpty);
  });
}
