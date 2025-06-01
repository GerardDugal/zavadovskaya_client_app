// lib/data/repositories/profile_repository.dart

import '../models/user.dart';

abstract class ProfileRepository {
  Future<User> getUserProfile();
}