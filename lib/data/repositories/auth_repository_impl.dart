// lib/data/repositories/auth_repository_impl.dart

import 'dart:async';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart'; // Импорт для декодирования JWT
import '../models/user.dart';
import 'auth_repository.dart';
import '../../config.dart';

class AuthRepositoryImpl implements AuthRepository {
  final String baseUrl;
  final FlutterSecureStorage secureStorage;

  AuthRepositoryImpl(
      {required this.baseUrl, FlutterSecureStorage? secureStorage})
      : secureStorage = secureStorage ?? const FlutterSecureStorage();

  // Сохранение списка купленных курсов
  Future<void> _savePurchasedCourses(List<int> courseIds) async {
    final jsonString = json.encode(courseIds);
    await secureStorage.write(key: 'purchased_courses', value: jsonString);
    print('✅ [AuthRepository] Сохранены купленные курсы: $courseIds');
  }

  // Получение списка купленных курсов
  Future<List<int>> _getPurchasedCourses() async {
    final jsonString = await secureStorage.read(key: 'purchased_courses');
    if (jsonString != null) {
      try {
        final List<dynamic> jsonList = json.decode(jsonString);
        final List<int> courseIds = jsonList.cast<int>();
        print('🔄 [AuthRepository] Получены купленные курсы: $courseIds');
        return courseIds;
      } catch (e) {
        print('🚨 [AuthRepository] Ошибка декодирования купленных курсов: $e');
        return [];
      }
    }
    print('🔄 [AuthRepository] Купленные курсы не найдены');
    return [];
  }

  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    print('🔑 [AuthRepository] Начало запроса логина');
    print('📧 Email: $email');
    // 🔒 Password: $password // **Важно:** В продакшене не рекомендуется логировать пароли

    try {
      final uri = Uri.parse('$baseUrl/auth/login');
      print('📡 Отправка POST запроса на $uri');

      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json', 'accept': 'application/json'},
            body: json.encode({'login': email, 'password': password}),
          )
          .timeout(Duration(seconds: 10)); // Добавлен таймаут 10 секунд

      print('📬 Получен ответ с кодом: ${response.statusCode}');
      print('📄 Тело ответа: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final token = data['token']; // Получаем токен из ответа
        await secureStorage.write(key: 'access_token', value: token);
        print('✅ Логин успешен. Токен сохранен.');

        // Декодирование токена для получения информации о пользователе
        Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
        print('👤 Декодированный токен: $decodedToken');

        // Получение списка купленных курсов (если есть, иначе пустой)
        List<int> purchasedCourses = await _getPurchasedCourses();

        return {
          ...decodedToken,
          'purchasedCourseIds': purchasedCourses,
        };
      } else {
        final error = json.decode(response.body)['message'] ?? 'Ошибка входа';
        print('❌ Ошибка логина: $error');
        throw Exception(error);
      }
    } catch (e) {
      print('🚨 Исключение при выполнении логина: $e');
      throw Exception(
          'Не удалось выполнить логин. Проверьте подключение к интернету и правильность введённых данных.');
    }
  }

  @override
  Future<Map<String, dynamic>> registration(
      String name,String phone, String email,  String password,
      {String photoPath = ""}) async {
    print('📝 [AuthRepository] Начало запроса регистрации');
    print('🧑‍💼 Name: $name');
    print('📧 Email: $email');
    print('📞 Phone: $phone');
    print('🖼️ Photo path: $photoPath');
    // 🔒 Password: $password // **Важно:** В продакшене не рекомендуется логировать пароли

    try {
      final uri = Uri.parse('$baseUrl/auth/registration');
      print('📡 Отправка POST запроса на $uri');

      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json', 'accept': 'application/json'},
            body: json.encode({
              'name': name,
              'email': email,
              'phone': phone,
              'photo_path': photoPath,
              'password': password,
            }),
          )
          .timeout(Duration(seconds: 10));

      print('📬 Получен ответ с кодом: ${response.statusCode}');
      print('📄 Тело ответа: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final token = data['token']; // Получаем токен из ответа
        await secureStorage.write(key: 'access_token', value: token);
        print('✅ Регистрация успешна. Токен сохранен.');

        // Декодирование токена для получения информации о пользователе
        Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
        print('👤 Декодированный токен: $decodedToken');

        // Получение списка купленных курсов (если есть, иначе пустой)
        List<int> purchasedCourses = await _getPurchasedCourses();

        return {
          ...decodedToken,
          'purchasedCourseIds': purchasedCourses,
        };
      } else {
        final error = json.decode(response.body)?['message'] ?? 
            json.decode(response.body)?['error'] ?? 
            'Ошибка регистрации';
        print('❌ Ошибка регистрации: $error');
        throw Exception(error);
      }
    } on TimeoutException {
      print('⏱️ Превышено время ожидания ответа от сервера');
      throw Exception('Сервер не отвечает. Попробуйте позже.');
    } on http.ClientException catch (e) {
      print('🌐 Ошибка сети: $e');
      throw Exception('Проблемы с подключением к интернету');
    } catch (e) {
      print('🚨 Неожиданное исключение при регистрации: $e');
      throw Exception('Произошла непредвиденная ошибка. Попробуйте снова.');
    }
  }

  @override
  Future<void> logout() async {
    print('🚪 [AuthRepository] Начало выхода из системы');

    try {
      await secureStorage.delete(key: 'access_token');
      await secureStorage.delete(key: 'refresh_token');
      await secureStorage.delete(
          key: 'purchased_courses'); // Удаление купленных курсов
      print('✅ Выход успешен. Токены и купленные курсы удалены.');
    } catch (e) {
      print('🚨 Исключение при выполнении выхода: $e');
      throw Exception('Не удалось выполнить выход из системы.');
    }
  }

  @override
  Future<User> getCurrentUser() async {
    const methodName = 'getCurrentUser';
    print('👤 [AuthRepository] Запрос текущего пользователя');

    try {
      // 1. Получение токена из безопасного хранилища
      final accessToken = await secureStorage.read(key: 'access_token');
      if (accessToken == null || accessToken.isEmpty) {
        print('❌ $methodName: Токен доступа не найден или пуст');
        throw const UnauthorizedException('Требуется авторизация');
      }

      // 2. Декодирование JWT токена
      final decodedToken = _decodeToken(accessToken);
      print('🔍 $methodName: Декодированный токен: $decodedToken');

      // 3. Получение списка купленных курсов
      final purchasedCourses = await _getPurchasedCourses();
      print('🛒 $methodName: Найдено курсов: ${purchasedCourses.length}');

      // 4. Создание объекта пользователя
      return User(
        id: decodedToken['usr']?.toString() ?? decodedToken['id']?.toString() ?? '',
        email: decodedToken['email']?.toString() ?? '',
        name: decodedToken['name']?.toString() ?? '',
        phone: decodedToken['phone']?.toString() ?? '',
        photoPath: decodedToken['photo_path']?.toString() ?? 
                  decodedToken['avatar']?.toString() ?? '',
        purchasedCourseIds: purchasedCourses,
      );
      
    } on UnauthorizedException {
      rethrow;
    } on JwtException catch (e) {
      print('🚨 $methodName: Ошибка декодирования токена: ${e.message}');
      throw const UnauthorizedException('Недействительная сессия');
    } catch (e, stackTrace) {
      print('🚨 $methodName: Неожиданная ошибка: $e');
      print('📌 Stack trace: $stackTrace');
      throw AppException('Не удалось загрузить данные пользователя');
    }
  }

  /// Вспомогательный метод для декодирования токена
  Map<String, dynamic> _decodeToken(String token) {
    try {
      return JwtDecoder.decode(token);
    } catch (e) {
      throw JwtException('Невалидный JWT токен');
    }
  }

  /// Кастомные исключения

  @override
  Future<bool> isLoggedIn() async {
    final accessToken = await secureStorage.read(key: 'access_token');
    print('🔑 [AuthRepository] Проверка авторизации: ${accessToken != null}');
    return accessToken != null;
  }

  @override
  Future<void> refreshToken() async {
    print('🔄 [AuthRepository] Начало обновления токена');

    try {
      final accessToken = await secureStorage.read(key: 'access_token');
      if (accessToken == null) {
        print('❌ Токен не найден');
        throw Exception('Отсутствует токен');
      }

      final uri = Uri.parse('$baseUrl/auth/refresh');
      print('📡 Отправка POST запроса на $uri с токеном');

      final response = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $accessToken'
            },
          )
          .timeout(Duration(seconds: 10)); // Добавлен таймаут 10 секунд

      print('📬 Получен ответ с кодом: ${response.statusCode}');
      print('📄 Тело ответа: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final newToken = data['token']; // Получаем новый токен
        await secureStorage.write(key: 'access_token', value: newToken);
        print('✅ Токен успешно обновлен');
      } else {
        final error =
            json.decode(response.body)['message'] ?? 'Ошибка обновления токена';
        print('❌ Ошибка обновления токена: $error');
        throw Exception(error);
      }
    } catch (e) {
      print('🚨 Исключение при обновлении токена: $e');
      throw Exception('Не удалось обновить токен.');
    }
  }

  Future<void> addPurchasedCourse(int courseID) async {
    print('🛒 [AuthRepository] Добавление купленного курса с ID: $courseID');
    try {
      List<int> purchasedCourses = await _getPurchasedCourses();
      if (!purchasedCourses.contains(courseID)) {
        purchasedCourses.add(courseID);
        await _savePurchasedCourses(purchasedCourses);
        print(
            '✅ [AuthRepository] Курс добавлен в купленные: $purchasedCourses');
      } else {
        print('ℹ️ [AuthRepository] Курс уже куплен: $courseID');
      }
    } catch (e) {
      print('🚨 [AuthRepository] Ошибка при добавлении купленного курса: $e');
      throw Exception('Не удалось добавить купленный курс.');
    }
  }

  /// Метод для удаления купленного курса
  Future<void> removePurchasedCourse(int courseID) async {
    print('🛍️ [AuthRepository] Удаление купленного курса с ID: $courseID');
    try {
      List<int> purchasedCourses = await _getPurchasedCourses();
      if (purchasedCourses.contains(courseID)) {
        purchasedCourses.remove(courseID);
        await _savePurchasedCourses(purchasedCourses);
        print('✅ [AuthRepository] Курс удалён из купленных: $purchasedCourses');
      } else {
        print('ℹ️ [AuthRepository] Курс не найден в купленных: $courseID');
      }
    } catch (e) {
      print('🚨 [AuthRepository] Ошибка при удалении купленного курса: $e');
      throw Exception('Не удалось удалить купленный курс.');
    }
  }
}

class UnauthorizedException implements Exception {
  final String message;
  const UnauthorizedException(this.message);
}

class JwtException implements Exception {
  final String message;
  const JwtException(this.message);
}

class AppException implements Exception {
  final String message;
  const AppException(this.message);
}