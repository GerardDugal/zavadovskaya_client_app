// lib/data/repositories/course_repository.dart

import 'package:video_player/video_player.dart';
import 'package:zavadovskaya_client_app/data/models/category.dart';
import 'package:zavadovskaya_client_app/data/models/video.dart';

import '../models/course.dart';
import '../models/course_content.dart';

abstract class CourseRepository {
  Future<List<Course>> getAllCourses();
  Future<Course> getCourseByID(int courseID);
  Future<List<Category>> getAllCategories();
  Future<bool> checkCoursePayment(int id);
  Future<List<Video>> getVideosByCourseId(int courseId);
  Future<VideoPlayerController> getVideoStream(int videoId);

  // Future<void> createCourse(Course course);
  // Future<void> updateCourse(Course course);
  // Future<void> deleteCourse(int courseID);
}
