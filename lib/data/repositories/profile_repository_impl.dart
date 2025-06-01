// lib/data/repositories/profile_repository_impl.dart

import '../models/user.dart';
import 'profile_repository.dart';
import 'auth_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final AuthRepository authRepository;

  ProfileRepositoryImpl({required this.authRepository});

  @override
  Future<User> getUserProfile() async {
    // Получение данных пользователя из AuthRepository
    return await authRepository.getCurrentUser();
  }
}