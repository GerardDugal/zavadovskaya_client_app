// lib/data/repositories/course_repository_impl.dart

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:universal_html/html.dart' as html;
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
  final videoUrl = '$baseUrl/stream/stream/by_id/$videoId'; // Явно указываем .mp4
  
  Config.mprint('📡 Запрос видео по URL: $videoUrl');

  try {
    // Для веба используем простой network controller
    if (kIsWeb) {
      Config.mprint('🌐 Используем веб-версию видеоплеера');
      Config.mprint('ссфлка $baseUrl/stream/stream/by_id/$videoId');
      Config.mprint('$headers');
      final controller = VideoPlayerController.networkUrl(
        Uri.parse(videoUrl),
        httpHeaders: headers,
      );
      Config.mprint('$controller');
      await controller.initialize();
      Config.mprint('✅ Видео успешно инициализировано для веба');
      return controller;
    }

    // Для мобильных устройств используем networkUrl с поддержкой потоков
    Config.mprint('📱 Используем мобильную версию видеоплеера');
    final controller = VideoPlayerController.networkUrl(
      Uri.parse(videoUrl),
      httpHeaders: headers,
      videoPlayerOptions: VideoPlayerOptions(
        mixWithOthers: true,
      ),
    );

    // Таймаут инициализации (15 секунд)
    await controller.initialize().timeout(
      const Duration(seconds: 15),
      onTimeout: () {
        controller.dispose();
        throw TimeoutException('Инициализация видео заняла слишком много времени');
      },
    );

    Config.mprint('✅ Видео успешно инициализировано');
    return controller;
  } on TimeoutException catch (e) {
    Config.mprint('⏱ Таймаут при загрузке видео: $e');
    throw Exception('Превышено время ожидания загрузки видео');
  } catch (e) {
    Config.mprint('🚨 ошибка: $e');
    throw Exception('Произошла ошибка при получении видео');
  }
}

Future<VideoPlayerController> _getConvertedWebVideo(String videoUrl, Map<String, String> headers) async {

  try {
    Config.mprint('🔄 Initializing FFmpeg...');

    // Correct initialization method
    final ffmpeg = createFFmpeg(CreateFFmpegParam(log: true));
    await ffmpeg.load();

    // Optional: Load core from specific URL if needed
    // await ffmpeg.load({
    //   'coreURL': 'https://unpkg.com/@ffmpeg/core@0.11.0/dist/ffmpeg-core.js',
    //   'wasmURL': 'https://unpkg.com/@ffmpeg/core@0.11.0/dist/ffmpeg-core.wasm',
    // });

    Config.mprint('📥 Downloading video...');
    final response = await http.get(Uri.parse(videoUrl), headers: headers);
    final inputName = 'input_${DateTime.now().millisecondsSinceEpoch}.mp4';
    ffmpeg.writeFile(inputName, response.bodyBytes);

    Config.mprint('🔄 Converting video...');
    const outputName = 'output.mp4';
    ffmpeg.readDir([
      '-i', inputName,
      '-c:v', 'libx264',
      '-profile:v', 'main',
      '-pix_fmt', 'yuv420p',
      '-movflags', '+faststart',
      '-c:a', 'aac',
      '-b:a', '128k',
      outputName
    ] as String);

    Config.mprint('📤 Getting converted video...');
    final data = await ffmpeg.readFile(outputName);
    final blob = html.Blob([data], 'video/mp4');
    final url = html.Url.createObjectUrl(blob);

    Config.mprint('▶️ Initializing player...');
    final controller = VideoPlayerController.network(url);
    await controller.initialize();
    
    // Cleanup when disposed
    controller.addListener(() {
      if (!controller.value.isInitialized) {
        html.Url.revokeObjectUrl(url);
      }
    });

    Config.mprint('✅ Conversion successful');
    return controller;
  } catch (e, st) {
    Config.mprint('❌ Conversion failed, trying fallback: $e\n$st');
    
    // Fallback to original video
    try {
      final controller = VideoPlayerController.network(videoUrl, httpHeaders: headers);
      await controller.initialize();
      return controller;
    } catch (e) {
      throw Exception('All video playback methods failed: ${e.toString()}');
    }
  }
}

}
