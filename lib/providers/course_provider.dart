import 'package:flutter/foundation.dart';

import '../models/course.dart';
import '../models/review.dart';
import '../services/api_client.dart';
import '../services/course_service.dart';

class CourseProvider extends ChangeNotifier {
  CourseProvider(this._service);

  final CourseService _service;

  // List state
  List<Course> courses = [];
  int _page = 1;
  int totalPages = 1;
  bool isLoading = false;
  String? errorMessage;

  // Filters
  String? subject;
  String? mode;
  String? location;
  double? minRating;
  double? maxFee;
  String? sortBy;
  String searchQuery = '';

  bool get hasMore => _page < totalPages;

  Future<void> loadFirstPage() async {
    _page = 1;
    await _load();
  }

  Future<void> loadNextPage() async {
    if (!hasMore || isLoading) return;
    _page += 1;
    await _load(append: true);
  }

  Future<void> _load({bool append = false}) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final result = await _service.list(
        subject: subject,
        mode: mode,
        location: location,
        minRating: minRating,
        maxFee: maxFee,
        sortBy: sortBy,
        q: searchQuery.isEmpty ? null : searchQuery,
        page: _page,
      );
      courses = append ? [...courses, ...result.courses] : result.courses;
      totalPages = result.totalPages;
    } on ApiException catch (e) {
      errorMessage = e.message;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void applyFilters({
    String? subject,
    String? mode,
    String? location,
    double? minRating,
    double? maxFee,
    String? sortBy,
  }) {
    this.subject = subject;
    this.mode = mode;
    this.location = location;
    this.minRating = minRating;
    this.maxFee = maxFee;
    this.sortBy = sortBy;
    loadFirstPage();
  }

  void search(String query) {
    searchQuery = query;
    loadFirstPage();
  }

  // Detail state (the selected course + its reviews)
  Course? selectedCourse;
  List<Review> reviews = [];
  bool isDetailLoading = false;
  String? detailError;

  Future<void> loadDetail(int id) async {
    isDetailLoading = true;
    detailError = null;
    selectedCourse = null;
    reviews = [];
    notifyListeners();
    try {
      final course = await _service.detail(id);
      final reviewList = await _service.reviews(id);
      selectedCourse = course;
      reviews = reviewList;
    } on ApiException catch (e) {
      detailError = e.message;
    } finally {
      isDetailLoading = false;
      notifyListeners();
    }
  }

  Future<String?> submitReview(
    int courseId, {
    required int rating,
    String? comment,
  }) async {
    try {
      await _service.addReview(courseId, rating: rating, comment: comment);
      await loadDetail(courseId);
      return null;
    } on ApiException catch (e) {
      return e.message;
    }
  }
}
