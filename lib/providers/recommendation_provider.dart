import 'package:flutter/foundation.dart';

import '../models/recommendation.dart';
import '../services/api_client.dart';
import '../services/recommendation_service.dart';

class RecommendationProvider extends ChangeNotifier {
  RecommendationProvider(this._service);

  final RecommendationService _service;

  List<RecommendedCourse> results = [];
  bool isLoading = false;
  String? errorMessage;
  bool hasSearched = false;

  Future<void> fetch(RecommendationPreferences preferences) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      results = await _service.getRecommendations(preferences);
      hasSearched = true;
    } on ApiException catch (e) {
      errorMessage = e.message;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void reset() {
    results = [];
    errorMessage = null;
    hasSearched = false;
    notifyListeners();
  }
}
