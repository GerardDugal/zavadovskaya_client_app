// lib/blocs/courses/courses_state.dart

part of 'courses_bloc.dart';

abstract class CoursesState extends Equatable {
  const CoursesState();
  
  @override
  List<Object?> get props => [];
}

class CoursesInitial extends CoursesState {}

class CoursesLoading extends CoursesState {}

class CoursesLoaded extends CoursesState {
  final List<Course> courses;
  final List<Category> categories;
  final Map<String, List<Course>> groupedCourses;

  CoursesLoaded({required this.courses, required this.categories})
      : groupedCourses = _groupCoursesByCategory(courses, categories);

  @override
  List<Object?> get props => [courses, groupedCourses];

  static Map<String, List<Course>> _groupCoursesByCategory(List<Course> courses, List<Category> categories) {
    final Map<String, List<Course>> grouped = {};
    for (var course in courses) {
      grouped.putIfAbsent(CategoriesLoaded(categories: categories).getCategoryName(course.categoryId), () => []).add(course);
    }
    return grouped;
  }

  
}

class CourseDetailLoaded extends CoursesState {
  final Course course;

  const CourseDetailLoaded({required this.course});

  @override
  List<Object?> get props => [course];
}

class CategoriesLoaded extends CoursesState {
  final List<Category> categories;
  final Map<int, Category> categoriesById; // Для быстрого доступа по ID

  CategoriesLoaded({required this.categories})
      : categoriesById = _createCategoriesMap(categories);

  @override
  List<Object?> get props => [categories, categoriesById];

  // Вспомогательный метод для создания словаря категорий по ID
  static Map<int, Category> _createCategoriesMap(List<Category> categories) {
    final Map<int, Category> map = {};
    for (var category in categories) {
      map[category.categoryId] = category;
    }
    return map;
  }

  // Дополнительные полезные методы:
  
  // Получение названия категории по ID
  String getCategoryName(int categoryId) {
    return categoriesById[categoryId]?.name ?? 'Неизвестная категория';
  }

  // Получение описания категории по ID
  String getCategoryDescription(int categoryId) {
    return categoriesById[categoryId]?.description ?? '';
  }
}

class PaymentInitial extends CoursesState {}

class PaymentChecking extends CoursesState {}

class PaymentChecked extends CoursesState {
  final bool isPaid;

  PaymentChecked(this.isPaid);
}

class PaymentError extends CoursesState {
  final String message;

  PaymentError(this.message);
}

// class CourseContentsLoaded extends CoursesState {
//   final List<CourseContent> contents;

//   const CourseContentsLoaded({required this.contents});

//   @override
//   List<Object?> get props => [contents];
// }

class CourseCreated extends CoursesState {}

class CourseUpdated extends CoursesState {}

class CourseDeleted extends CoursesState {}

class CoursesError extends CoursesState {
  final String error;

  const CoursesError({required this.error});

  @override
  List<Object?> get props => [error];
}