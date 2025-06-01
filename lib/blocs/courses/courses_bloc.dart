// lib/blocs/courses/courses_bloc.dart

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:zavadovskaya_client_app/data/models/category.dart';
import '../../data/models/course.dart';
import '../../data/models/course_content.dart';
import '../../data/repositories/course_repository.dart';

part 'courses_event.dart';
part 'courses_state.dart';

class CoursesBloc extends Bloc<CoursesEvent, CoursesState> {
  final CourseRepository courseRepository;

  CoursesBloc({required this.courseRepository}) : super(CoursesInitial()) {
    on<GetAllCoursesRequested>(_onGetAllCoursesRequested);
    on<GetCourseByIDRequested>(_onGetCourseByIDRequested);
    on<GetAllCategory>(_onGetAllCategory);
    on<CheckPaymentStatus>(_onCheckPaymentStatus);
    // on<CreateCourseRequested>(_onCreateCourseRequested);
    // on<UpdateCourseRequested>(_onUpdateCourseRequested);
    // on<DeleteCourseRequested>(_onDeleteCourseRequested);
  }

  Future<void> _onGetAllCoursesRequested(
  GetAllCoursesRequested event,
  Emitter<CoursesState> emit,
) async {
  emit(CoursesLoading());
  try {
    final courses = await courseRepository.getAllCourses();
    final categories = await courseRepository.getAllCategories();
    emit(CoursesLoaded(courses: courses, categories: categories));
  } catch (e) {
    emit(CoursesError(error: e.toString()));
  }
}

  Future<void> _onGetCourseByIDRequested(
      GetCourseByIDRequested event, Emitter<CoursesState> emit) async {
    emit(CoursesLoading());
    try {
      final course = await courseRepository.getCourseByID(event.courseID);
      emit(CourseDetailLoaded(course: course));
  
    } catch (e) {
      emit(CoursesError(error: e.toString()));
    }
  }

 Future<void> _onGetAllCategory(
    GetAllCategory event, 
    Emitter<CoursesState> emit
) async {
  emit(CoursesLoading());
  try {
    final categories = await courseRepository.getAllCategories();
    emit(CategoriesLoaded(categories: categories));
  } catch (e) {
    emit(CoursesError(error: e.toString()));
    // Можно добавить более конкретное сообщение об ошибке:
    // emit(CoursesError(error: 'Не удалось загрузить категории: ${e.toString()}'));
  }
}

 Future<void> _onCheckPaymentStatus(
    CheckPaymentStatus event,
    Emitter<CoursesState> emit,
  ) async {
    emit(PaymentChecking());
    
    try {
      final isPaid = await courseRepository.checkCoursePayment(event.courseId);
      emit(PaymentChecked(isPaid));
    } catch (e) {
      emit(PaymentError('Ошибка при проверке статуса оплаты'));
    }
  }

}

  // Future<void> _onCreateCourseRequested(
  //     CreateCourseRequested event, Emitter<CoursesState> emit) async {
  //   emit(CoursesLoading());
  //   try {
  //     await courseRepository.createCourse(event.course);
  //     emit(CourseCreated());
  //     add(GetAllCoursesRequested()); // Обновить список курсов
  //   } catch (e) {
  //     emit(CoursesError(error: e.toString()));
  //   }
  // }

  // Future<void> _onUpdateCourseRequested(
  //     UpdateCourseRequested event, Emitter<CoursesState> emit) async {
  //   emit(CoursesLoading());
  //   try {
  //     await courseRepository.updateCourse(event.course);
  //     emit(CourseUpdated());
  //     add(GetAllCoursesRequested()); // Обновить список курсов
  //   } catch (e) {
  //     emit(CoursesError(error: e.toString()));
  //   }
  // }

  // Future<void> _onDeleteCourseRequested(
  //     DeleteCourseRequested event, Emitter<CoursesState> emit) async {
  //   emit(CoursesLoading());
  //   try {
  //     await courseRepository.deleteCourse(event.courseID);
  //     emit(CourseDeleted());
  //     add(GetAllCoursesRequested()); // Обновить список курсов
  //   } catch (e) {
  //     emit(CoursesError(error: e.toString()));
  //   }
  // }

