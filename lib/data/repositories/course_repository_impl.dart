// lib/data/repositories/course_repository_impl.dart

import 'dart:async';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';
import 'package:zavadovskaya_client_app/data/models/category.dart';
import 'package:zavadovskaya_client_app/data/models/video.dart';
import '../models/course.dart';
import '../models/course_content.dart';
import 'course_repository.dart';
import '../../config.dart';

class CourseRepositoryImpl implements CourseRepository {
  final String baseUrl;
  final FlutterSecureStorage secureStorage;
  

  CourseRepositoryImpl(
      {required this.baseUrl, FlutterSecureStorage? secureStorage})
      : secureStorage = secureStorage ?? const FlutterSecureStorage();

  /// Получение заголовков для запросов, включая токен авторизации.
  Future<Map<String, String>> _getHeaders() async {
    final token = await secureStorage.read(key: 'access_token');
    if (token == null) {
      Config.mprint('🔒 [CourseRepository] Токен доступа не найден');
    } else {
      Config.mprint('🔒 [CourseRepository] Токен доступа загружен');
    }
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  

  /// Получение списка всех курсов.
@override
Future<List<Course>> getAllCourses() async {
  Config.mprint('📚 [CourseRepository] Начало получения всех курсов');
  final headers = await _getHeaders();
  final uri = Uri.parse('$baseUrl/courses/courses/all');
  Config.mprint('📡 Отправка GET запроса на $uri');

  try {
    final response = await http
        .get(uri, headers: headers)
        .timeout(const Duration(seconds: 10));

    Config.mprint('📬 Получен ответ с кодом: ${response.statusCode}');
    Config.mprint('📄 Тело ответа: ${response.body}');

    if (response.statusCode == 200) {
      final data =
          json.decode(utf8.decode(response.bodyBytes)) as List<dynamic>;
      Config.mprint('✅ [CourseRepository] Получено ${data.length} курсов');

      final rawCourses = data.map((json) => Course.fromJson(json)).toList();

      // ⏳ Обогащаем isPaid
      final coursesWithPayment = await Future.wait(rawCourses.map((course) async {
        final isPaid = await checkCoursePayment(course.id);
        return course.copyWith(isPaid: isPaid);
      }));

      return coursesWithPayment;
    } else {
      final error = json.decode(response.body)['message'] ?? 'Ошибка получения курсов';
      Config.mprint('❌ [CourseRepository] Ошибка получения курсов: $error');
      throw Exception(error);
    }
  } catch (e) {
    Config.mprint('🚨 [CourseRepository] Исключение при получении курсов: $e');
    throw Exception('Не удалось получить курсы. Проверьте подключение к интернету.');
  }
}
  /// Получение деталей конкретного курса по его ID.
  @override
Future<Course> getCourseByID(int courseID) async {
  Config.mprint('🔍 [CourseRepository] Начало получения курса с ID: $courseID');
  final headers = await _getHeaders();
  final uri = Uri.parse('$baseUrl/courses/courses/by_id/$courseID');
  Config.mprint('📡 Отправка GET запроса на $uri');

  try {
    final response = await http
        .get(
          uri,
          headers: headers,
        )
        .timeout(const Duration(seconds: 10));

    Config.mprint('📬 Получен ответ с кодом: ${response.statusCode}');
    Config.mprint('📄 Тело ответа: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      Config.mprint('✅ [CourseRepository] Курс получен: ${data['title']}');
      
      // Преобразуем данные в формат, ожидаемый моделью Course
      final courseData = {
        'id': data['id'],
        'title': data['title'],
        'description': data['description'],
        'photo_path': data['photo_path'],
        'cost': data['cost'],
        'category_id': data['category_id'],
      };
      
      final course = Course.fromJson(courseData);
      Config.mprint('📊 Данные курса: $course');
      return course;
    } else {
      final error = json.decode(response.body)?['message'] ?? 
          'Ошибка получения курса (код ${response.statusCode})';
      Config.mprint('❌ [CourseRepository] Ошибка получения курса: $error');
      throw Exception(error);
    }
  }on http.ClientException catch (e) {
    Config.mprint('🌐 [CourseRepository] Ошибка сети: $e');
    throw Exception('Проблемы с подключением к интернету');
  } catch (e) {
    Config.mprint('🚨 [CourseRepository] Неожиданная ошибка: $e');
    throw Exception('Произошла ошибка при получении курса');
  }
}

@override
Future<bool> checkCoursePayment(int courseId) async {
  final headers = await _getHeaders();
  final uri = Uri.parse('$baseUrl/payment/payment/status/by_course_id/$courseId');
  
  Config.mprint('🔍 Проверка статуса оплаты для курса ID: $courseId');
  Config.mprint('📡 Отправка GET запроса на $uri');

  try {
    final response = await http.get(
      uri,
      headers: headers,
    ).timeout(const Duration(seconds: 10));

    Config.mprint('📬 Получен ответ с кодом: ${response.statusCode}');
    Config.mprint('📄 Тело ответа: ${response.body}');

    // Если статус 200 - оплата подтверждена
    if (response.statusCode == 200) {
      Config.mprint('✅ Курс оплачен');
      return true;
    }
    
    // Все остальные статусы - оплата не подтверждена
    Config.mprint('❌ Статус оплаты не подтвержден');
    return false;
    
  } on TimeoutException {
    Config.mprint('⏱ Таймаут при проверке статуса оплаты');
    return false;
  } on http.ClientException catch (e) {
    Config.mprint('🌐 Ошибка сети: $e');
    return false;
  } catch (e) {
    Config.mprint('🚨 Неожиданная ошибка: $e');
    return false;
  }
}

  @override
Future<List<Category>> getAllCategories() async {
  Config.mprint('🔍 [CourseRepository] Начало получения всех категорий');
  final headers = await _getHeaders();
  final uri = Uri.parse('$baseUrl/courses/category/all');
  Config.mprint('📡 Отправка GET запроса на $uri');

  try {
    final response = await http
        .get(
          uri,
          headers: headers,
        )
        .timeout(Duration(seconds: 10));

    Config.mprint('📬 Получен ответ с кодом: ${response.statusCode}');
    Config.mprint('📄 Тело ответа: ${response.body}');

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      Config.mprint('✅ [CourseRepository] Получено ${data.length} категорий');
      
      // Преобразуем каждую категорию из JSON в объект Category
      final categories = data.map((categoryJson) => Category.fromJson(categoryJson)).toList();
      
      return categories;
    } else {
      final error = json.decode(response.body)['message'] ?? 'Ошибка получения категорий';
      Config.mprint('❌ [CourseRepository] Ошибка получения категорий: $error');
      throw Exception(error);
    }
  } catch (e) {
    Config.mprint('🚨 [CourseRepository] Исключение при получении категорий: $e');
    throw Exception(
        'Не удалось получить категории. Проверьте подключение к интернету.');
  }
}

@override
Future<List<Video>> getVideosByCourseId(int courseId) async {
  Config.mprint('🔍 [CourseRepository] Начало получения видео для курса ID: $courseId');
  final headers = await _getHeaders();
  final uri = Uri.parse('https://zavadovskayakurs.ru/api/v1/stream/stream/by_course_id/$courseId');
  Config.mprint('📡 Отправка GET запроса на $uri');

  try {
    final response = await http
        .get(
          uri,
          headers: headers,
        )
        .timeout(Duration(seconds: 10));

    Config.mprint('📬 Получен ответ с кодом: ${response.statusCode}');
    Config.mprint('📄 Тело ответа: ${response.body}');

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      Config.mprint('✅ [CourseRepository] Получено ${data.length} видео');
      
      final videos = data.map((videoJson) => Video.fromJson(videoJson)).toList();
      return videos;
    } else {
      final error = json.decode(response.body)['message'] ?? 'Ошибка получения видео';
      Config.mprint('❌ [CourseRepository] Ошибка получения видео: $error');
      throw Exception(error);
    }
  } on TimeoutException {
    Config.mprint('⏱ [CourseRepository] Таймаут при получении видео');
    throw Exception('Превышено время ожидания ответа от сервера');
  } on http.ClientException catch (e) {
    Config.mprint('🌐 [CourseRepository] Ошибка сети: $e');
    throw Exception('Проблемы с подключением к интернету');
  } catch (e) {
    Config.mprint('🚨 [CourseRepository] Неожиданная ошибка: $e');
    throw Exception('Произошла ошибка при получении видео');
  }
}

@override
Future<VideoPlayerController> getVideoStream(int videoId) async {
  Config.mprint('🔍 [VideoRepository] Получение видео потока для ID: $videoId');
  final headers = await _getHeaders();
  headers['Range'] = 'bytes=0-';
  final uri = Uri.parse('https://zavadovskayakurs.ru/api/v1/stream/stream/by_id/$videoId');
  
  Config.mprint('📡 Отправка GET запроса на $uri с заголовками: $headers');

  try {
    // Создаем контроллер для потокового видео
    final controller = VideoPlayerController.networkUrl(
  uri,
  httpHeaders: headers,
  videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true), // <- важно для Android
);

    // Инициализируем контроллер
    await controller.initialize();
    Config.mprint('✅ [VideoRepository] Видео поток успешно инициализирован');
    
    return controller;
  } on TimeoutException {
    Config.mprint('⏱ [VideoRepository] Таймаут при получении видео потока');
    throw Exception('Превышено время ожидания ответа от сервера');
  }
}

  /// Получение содержимого конкретного курса по его ID.

  /// Обновление существующего курса.
  // @override
  // Future<void> updateCourse(Course course) async {
  //   Config.mprint(
  //       '✏️ [CourseRepository] Начало обновления курса с ID: ${course.courseID}');
  //   final headers = await _getHeaders();
  //   final uri = Uri.parse('$baseUrl/UpdateCourse');
  //   Config.mprint('📡 Отправка POST запроса на $uri с телом: ${json.encode({
  //         'courseID': course.courseID,
  //         'title': course.title,
  //         'description': course.description,
  //         'thumbnailUrl': course.thumbnailUrl,
  //         'category': course.category,
  //         'price': course.price,
  //       })}');

  //   try {
  //     final response = await http
  //         .post(
  //           uri,
  //           headers: headers,
  //           body: json.encode({
  //             'courseID': course.courseID,
  //             'title': course.title,
  //             'description': course.description,
  //             'thumbnailUrl': course.thumbnailUrl,
  //             'category': course.category,
  //             'price': course.price,
  //           }),
  //         )
  //         .timeout(Duration(seconds: 10)); // Добавлен таймаут 10 секунд

  //     Config.mprint('📬 Получен ответ с кодом: ${response.statusCode}');
  //     Config.mprint('📄 Тело ответа: ${response.body}');

  //     if (response.statusCode != 200) {
  //       final error =
  //           json.decode(response.body)['message'] ?? 'Ошибка обновления курса';
  //       Config.mprint('❌ [CourseRepository] Ошибка обновления курса: $error');
  //       throw Exception(error);
  //     } else {
  //       Config.mprint('✅ [CourseRepository] Курс успешно обновлён');
  //     }
  //   } catch (e) {
  //     Config.mprint('🚨 [CourseRepository] Исключение при обновлении курса: $e');
  //     throw Exception(
  //         'Не удалось обновить курс. Проверьте подключение к интернету.');
  //   }
  // }
  // /// Создание нового курса.
  // @override
  // Future<void> createCourse(Course course) async {
  //   Config.mprint('📝 [CourseRepository] Начало создания курса: ${course.title}');
  //   final headers = await _getHeaders();
  //   final uri = Uri.parse('$baseUrl/CreateCourse');
  //   Config.mprint('📡 Отправка POST запроса на $uri с телом: ${json.encode({
  //         'title': course.title,
  //         'description': course.description,
  //         'thumbnailUrl': course.thumbnailUrl,
  //         'category': course.category,
  //         'price': course.price,
  //       })}');

  //   try {
  //     final response = await http
  //         .post(
  //           uri,
  //           headers: headers,
  //           body: json.encode({
  //             'title': course.title,
  //             'description': course.description,
  //             'thumbnailUrl': course.thumbnailUrl,
  //             'category': course.category,
  //             'price': course.price,
  //           }),
  //         )
  //         .timeout(Duration(seconds: 10)); // Добавлен таймаут 10 секунд

  //     Config.mprint('📬 Получен ответ с кодом: ${response.statusCode}');
  //     Config.mprint('📄 Тело ответа: ${response.body}');

  //     if (response.statusCode != 200) {
  //       final error =
  //           json.decode(response.body)['message'] ?? 'Ошибка создания курса';
  //       Config.mprint('❌ [CourseRepository] Ошибка создания курса: $error');
  //       throw Exception(error);
  //     } else {
  //       Config.mprint('✅ [CourseRepository] Курс успешно создан');
  //     }
  //   } catch (e) {
  //     Config.mprint('🚨 [CourseRepository] Исключение при создании курса: $e');
  //     throw Exception(
  //         'Не удалось создать курс. Проверьте подключение к интернету.');
  //   }
  // }

  /// Удаление существующего курса по его ID.
  // @override
  // Future<void> deleteCourse(int courseID) async {
  //   Config.mprint('🗑️ [CourseRepository] Начало удаления курса с ID: $courseID');
  //   final headers = await _getHeaders();
  //   final uri = Uri.parse('$baseUrl/DeleteCourse');
  //   Config.mprint('📡 Отправка POST запроса на $uri с телом: ${json.encode({
  //         'courseID': courseID
  //       })}');

  //   try {
  //     final response = await http
  //         .post(
  //           uri,
  //           headers: headers,
  //           body: json.encode({'courseID': courseID}),
  //         )
  //         .timeout(Duration(seconds: 10)); // Добавлен таймаут 10 секунд

  //     Config.mprint('📬 Получен ответ с кодом: ${response.statusCode}');
  //     Config.mprint('📄 Тело ответа: ${response.body}');

  //     if (response.statusCode != 200) {
  //       final error =
  //           json.decode(response.body)['message'] ?? 'Ошибка удаления курса';
  //       Config.mprint('❌ [CourseRepository] Ошибка удаления курса: $error');
  //       throw Exception(error);
  //     } else {
  //       Config.mprint('✅ [CourseRepository] Курс успешно удалён');
  //     }
  //   } catch (e) {
  //     Config.mprint('🚨 [CourseRepository] Исключение при удалении курса: $e');
  //     throw Exception(
  //         'Не удалось удалить курс. Проверьте подключение к интернету.');
  //   }
  // }
}
