import 'dart:io';

import 'package:flutter/foundation.dart';

import '../models/student_profile.dart';
import '../services/api_client.dart';
import '../services/student_service.dart';

class ProfileProvider extends ChangeNotifier {
  ProfileProvider(this._service);

  final StudentService _service;

  StudentProfile? profile;
  bool isLoading = false;
  String? errorMessage;
  bool isSaving = false;
  String? saveError;

  Future<void> load() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      profile = await _service.getProfile();
    } on ApiException catch (e) {
      errorMessage = e.message;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> save({
    required String name,
    String? phone,
    String? school,
    String? grade,
    String? bio,
    String? address,
    File? profilePicture,
  }) async {
    isSaving = true;
    saveError = null;
    notifyListeners();
    try {
      await _service.updateProfile(
        name: name,
        phone: phone,
        school: school,
        grade: grade,
        bio: bio,
        address: address,
        profilePicture: profilePicture,
      );
      await load();
      return true;
    } on ApiException catch (e) {
      saveError = e.message;
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }
}
