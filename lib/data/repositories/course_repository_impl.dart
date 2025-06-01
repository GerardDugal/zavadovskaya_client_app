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
      print('🔒 [CourseRepository] Токен доступа не найден');
    } else {
      print('🔒 [CourseRepository] Токен доступа загружен');
    }
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  

  /// Получение списка всех курсов.
@override
Future<List<Course>> getAllCourses() async {
  print('📚 [CourseRepository] Начало получения всех курсов');
  final headers = await _getHeaders();
  final uri = Uri.parse('$baseUrl/courses/courses/all');
  print('📡 Отправка GET запроса на $uri');

  try {
    final response = await http
        .get(uri, headers: headers)
        .timeout(const Duration(seconds: 10));

    print('📬 Получен ответ с кодом: ${response.statusCode}');
    print('📄 Тело ответа: ${response.body}');

    if (response.statusCode == 200) {
      final data =
          json.decode(utf8.decode(response.bodyBytes)) as List<dynamic>;
      print('✅ [CourseRepository] Получено ${data.length} курсов');

      final rawCourses = data.map((json) => Course.fromJson(json)).toList();

      // ⏳ Обогащаем isPaid
      final coursesWithPayment = await Future.wait(rawCourses.map((course) async {
        final isPaid = await checkCoursePayment(course.id);
        return course.copyWith(isPaid: isPaid);
      }));

      return coursesWithPayment;
    } else {
      final error = json.decode(response.body)['message'] ?? 'Ошибка получения курсов';
      print('❌ [CourseRepository] Ошибка получения курсов: $error');
      throw Exception(error);
    }
  } catch (e) {
    print('🚨 [CourseRepository] Исключение при получении курсов: $e');
    throw Exception('Не удалось получить курсы. Проверьте подключение к интернету.');
  }
}
  /// Получение деталей конкретного курса по его ID.
  @override
Future<Course> getCourseByID(int courseID) async {
  print('🔍 [CourseRepository] Начало получения курса с ID: $courseID');
  final headers = await _getHeaders();
  final uri = Uri.parse('$baseUrl/courses/courses/by_id/$courseID');
  print('📡 Отправка GET запроса на $uri');

  try {
    final response = await http
        .get(
          uri,
          headers: headers,
        )
        .timeout(const Duration(seconds: 10));

    print('📬 Получен ответ с кодом: ${response.statusCode}');
    print('📄 Тело ответа: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      print('✅ [CourseRepository] Курс получен: ${data['title']}');
      
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
      print('📊 Данные курса: $course');
      return course;
    } else {
      final error = json.decode(response.body)?['message'] ?? 
          'Ошибка получения курса (код ${response.statusCode})';
      print('❌ [CourseRepository] Ошибка получения курса: $error');
      throw Exception(error);
    }
  }on http.ClientException catch (e) {
    print('🌐 [CourseRepository] Ошибка сети: $e');
    throw Exception('Проблемы с подключением к интернету');
  } catch (e) {
    print('🚨 [CourseRepository] Неожиданная ошибка: $e');
    throw Exception('Произошла ошибка при получении курса');
  }
}

@override
Future<bool> checkCoursePayment(int courseId) async {
  final headers = await _getHeaders();
  final uri = Uri.parse('$baseUrl/payment/payment/status/by_course_id/$courseId');
  
  print('🔍 Проверка статуса оплаты для курса ID: $courseId');
  print('📡 Отправка GET запроса на $uri');

  try {
    final response = await http.get(
      uri,
      headers: headers,
    ).timeout(const Duration(seconds: 10));

    print('📬 Получен ответ с кодом: ${response.statusCode}');
    print('📄 Тело ответа: ${response.body}');

    // Если статус 200 - оплата подтверждена
    if (response.statusCode == 200) {
      print('✅ Курс оплачен');
      return true;
    }
    
    // Все остальные статусы - оплата не подтверждена
    print('❌ Статус оплаты не подтвержден');
    return false;
    
  } on TimeoutException {
    print('⏱ Таймаут при проверке статуса оплаты');
    return false;
  } on http.ClientException catch (e) {
    print('🌐 Ошибка сети: $e');
    return false;
  } catch (e) {
    print('🚨 Неожиданная ошибка: $e');
    return false;
  }
}

  @override
Future<List<Category>> getAllCategories() async {
  print('🔍 [CourseRepository] Начало получения всех категорий');
  final headers = await _getHeaders();
  final uri = Uri.parse('$baseUrl/courses/category/all');
  print('📡 Отправка GET запроса на $uri');

  try {
    final response = await http
        .get(
          uri,
          headers: headers,
        )
        .timeout(Duration(seconds: 10));

    print('📬 Получен ответ с кодом: ${response.statusCode}');
    print('📄 Тело ответа: ${response.body}');

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      print('✅ [CourseRepository] Получено ${data.length} категорий');
      
      // Преобразуем каждую категорию из JSON в объект Category
      final categories = data.map((categoryJson) => Category.fromJson(categoryJson)).toList();
      
      return categories;
    } else {
      final error = json.decode(response.body)['message'] ?? 'Ошибка получения категорий';
      print('❌ [CourseRepository] Ошибка получения категорий: $error');
      throw Exception(error);
    }
  } catch (e) {
    print('🚨 [CourseRepository] Исключение при получении категорий: $e');
    throw Exception(
        'Не удалось получить категории. Проверьте подключение к интернету.');
  }
}

@override
Future<List<Video>> getVideosByCourseId(int courseId) async {
  print('🔍 [CourseRepository] Начало получения видео для курса ID: $courseId');
  final headers = await _getHeaders();
  final uri = Uri.parse('https://zavadovskayakurs.ru/api/v1/stream/stream/by_course_id/$courseId');
  print('📡 Отправка GET запроса на $uri');

  try {
    final response = await http
        .get(
          uri,
          headers: headers,
        )
        .timeout(Duration(seconds: 10));

    print('📬 Получен ответ с кодом: ${response.statusCode}');
    print('📄 Тело ответа: ${response.body}');

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      print('✅ [CourseRepository] Получено ${data.length} видео');
      
      final videos = data.map((videoJson) => Video.fromJson(videoJson)).toList();
      return videos;
    } else {
      final error = json.decode(response.body)['message'] ?? 'Ошибка получения видео';
      print('❌ [CourseRepository] Ошибка получения видео: $error');
      throw Exception(error);
    }
  } on TimeoutException {
    print('⏱ [CourseRepository] Таймаут при получении видео');
    throw Exception('Превышено время ожидания ответа от сервера');
  } on http.ClientException catch (e) {
    print('🌐 [CourseRepository] Ошибка сети: $e');
    throw Exception('Проблемы с подключением к интернету');
  } catch (e) {
    print('🚨 [CourseRepository] Неожиданная ошибка: $e');
    throw Exception('Произошла ошибка при получении видео');
  }
}

@override
Future<VideoPlayerController> getVideoStream(int videoId) async {
  print('🔍 [VideoRepository] Получение видео потока для ID: $videoId');
  final headers = await _getHeaders();
  final uri = Uri.parse('https://zavadovskayakurs.ru/api/v1/stream/stream/by_id/$videoId');
  
  print('📡 Отправка GET запроса на $uri с заголовками: $headers');

  try {
    // Создаем контроллер для потокового видео
    final controller = VideoPlayerController.network(
      uri.toString(),
      httpHeaders: headers,
    );

    // Инициализируем контроллер
    await controller.initialize();
    print('✅ [VideoRepository] Видео поток успешно инициализирован');
    
    return controller;
  } on TimeoutException {
    print('⏱ [VideoRepository] Таймаут при получении видео потока');
    throw Exception('Превышено время ожидания ответа от сервера');
  }
}

  /// Получение содержимого конкретного курса по его ID.

  /// Обновление существующего курса.
  // @override
  // Future<void> updateCourse(Course course) async {
  //   print(
  //       '✏️ [CourseRepository] Начало обновления курса с ID: ${course.courseID}');
  //   final headers = await _getHeaders();
  //   final uri = Uri.parse('$baseUrl/UpdateCourse');
  //   print('📡 Отправка POST запроса на $uri с телом: ${json.encode({
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

  //     print('📬 Получен ответ с кодом: ${response.statusCode}');
  //     print('📄 Тело ответа: ${response.body}');

  //     if (response.statusCode != 200) {
  //       final error =
  //           json.decode(response.body)['message'] ?? 'Ошибка обновления курса';
  //       print('❌ [CourseRepository] Ошибка обновления курса: $error');
  //       throw Exception(error);
  //     } else {
  //       print('✅ [CourseRepository] Курс успешно обновлён');
  //     }
  //   } catch (e) {
  //     print('🚨 [CourseRepository] Исключение при обновлении курса: $e');
  //     throw Exception(
  //         'Не удалось обновить курс. Проверьте подключение к интернету.');
  //   }
  // }
  // /// Создание нового курса.
  // @override
  // Future<void> createCourse(Course course) async {
  //   print('📝 [CourseRepository] Начало создания курса: ${course.title}');
  //   final headers = await _getHeaders();
  //   final uri = Uri.parse('$baseUrl/CreateCourse');
  //   print('📡 Отправка POST запроса на $uri с телом: ${json.encode({
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

  //     print('📬 Получен ответ с кодом: ${response.statusCode}');
  //     print('📄 Тело ответа: ${response.body}');

  //     if (response.statusCode != 200) {
  //       final error =
  //           json.decode(response.body)['message'] ?? 'Ошибка создания курса';
  //       print('❌ [CourseRepository] Ошибка создания курса: $error');
  //       throw Exception(error);
  //     } else {
  //       print('✅ [CourseRepository] Курс успешно создан');
  //     }
  //   } catch (e) {
  //     print('🚨 [CourseRepository] Исключение при создании курса: $e');
  //     throw Exception(
  //         'Не удалось создать курс. Проверьте подключение к интернету.');
  //   }
  // }

  /// Удаление существующего курса по его ID.
  // @override
  // Future<void> deleteCourse(int courseID) async {
  //   print('🗑️ [CourseRepository] Начало удаления курса с ID: $courseID');
  //   final headers = await _getHeaders();
  //   final uri = Uri.parse('$baseUrl/DeleteCourse');
  //   print('📡 Отправка POST запроса на $uri с телом: ${json.encode({
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

  //     print('📬 Получен ответ с кодом: ${response.statusCode}');
  //     print('📄 Тело ответа: ${response.body}');

  //     if (response.statusCode != 200) {
  //       final error =
  //           json.decode(response.body)['message'] ?? 'Ошибка удаления курса';
  //       print('❌ [CourseRepository] Ошибка удаления курса: $error');
  //       throw Exception(error);
  //     } else {
  //       print('✅ [CourseRepository] Курс успешно удалён');
  //     }
  //   } catch (e) {
  //     print('🚨 [CourseRepository] Исключение при удалении курса: $e');
  //     throw Exception(
  //         'Не удалось удалить курс. Проверьте подключение к интернету.');
  //   }
  // }
}
