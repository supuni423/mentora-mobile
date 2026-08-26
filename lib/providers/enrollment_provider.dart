import 'package:flutter/foundation.dart';

import '../models/enrollment.dart';
import '../services/api_client.dart';
import '../services/enrollment_service.dart';

class EnrollmentProvider extends ChangeNotifier {
  EnrollmentProvider(this._service);

  final EnrollmentService _service;

  List<Enrollment> enrollments = [];
  bool isLoading = false;
  String? errorMessage;

  Future<void> load() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      enrollments = await _service.myEnrollments();
    } on ApiException catch (e) {
      errorMessage = e.message;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Enrollment? selected;
  bool isDetailLoading = false;
  String? detailError;

  Future<void> loadDetail(int id) async {
    isDetailLoading = true;
    detailError = null;
    selected = null;
    notifyListeners();
    try {
      selected = await _service.detail(id);
    } on ApiException catch (e) {
      detailError = e.message;
    } finally {
      isDetailLoading = false;
      notifyListeners();
    }
  }

  bool isSubmitting = false;
  String? submitError;

  Future<bool> create({
    required int classId,
    required String fullName,
    required String email,
    String? phone,
    String? school,
    String? grade,
    String? message,
    required String preferredMode,
    required String selectedDay,
    required String selectedTime,
  }) async {
    isSubmitting = true;
    submitError = null;
    notifyListeners();
    try {
      await _service.create(
        classId: classId,
        fullName: fullName,
        email: email,
        phone: phone,
        school: school,
        grade: grade,
        message: message,
        preferredMode: preferredMode,
        selectedDay: selectedDay,
        selectedTime: selectedTime,
      );
      await load();
      return true;
    } on ApiException catch (e) {
      submitError = e.message;
      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> update(
    int id, {
    required int classId,
    required String fullName,
    required String email,
    String? phone,
    String? school,
    String? grade,
    String? message,
    required String preferredMode,
    required String selectedDay,
    required String selectedTime,
  }) async {
    isSubmitting = true;
    submitError = null;
    notifyListeners();
    try {
      selected = await _service.update(
        id,
        classId: classId,
        fullName: fullName,
        email: email,
        phone: phone,
        school: school,
        grade: grade,
        message: message,
        preferredMode: preferredMode,
        selectedDay: selectedDay,
        selectedTime: selectedTime,
      );
      await load();
      return true;
    } on ApiException catch (e) {
      submitError = e.message;
      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> cancel(int id) async {
    try {
      await _service.cancel(id);
      enrollments.removeWhere((e) => e.id == id);
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      errorMessage = e.message;
      notifyListeners();
      return false;
    }
  }
}
