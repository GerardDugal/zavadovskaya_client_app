// lib/data/repositories/auth_repository.dart

import '../models/user.dart';

abstract class AuthRepository {
  Future<Map<String, dynamic>> login(String email, String password);
  Future<Map<String, dynamic>> registration(String name, String phone, String email, String password);
  Future<void> logout();
  Future<User> getCurrentUser();
  Future<bool> isLoggedIn();
  Future<void> refreshToken();

  removePurchasedCourse(int courseID) {}
}