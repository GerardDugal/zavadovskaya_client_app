// lib/blocs/courses/courses_event.dart

part of 'courses_bloc.dart';

abstract class CoursesEvent extends Equatable {
  const CoursesEvent();
  
  @override
  List<Object?> get props => [];
}

class GetAllCoursesRequested extends CoursesEvent {}

class GetCourseByIDRequested extends CoursesEvent {
  final int courseID;

  const GetCourseByIDRequested({required this.courseID});

  @override
  List<Object?> get props => [courseID];
}

class GetCourseContentsRequested extends CoursesEvent {
  final int courseID;

  const GetCourseContentsRequested({required this.courseID});

  @override
  List<Object?> get props => [courseID];
}

class CreateCourseRequested extends CoursesEvent {
  final Course course;

  const CreateCourseRequested({required this.course});

  @override
  List<Object?> get props => [course];
}

class UpdateCourseRequested extends CoursesEvent {
  final Course course;

  const UpdateCourseRequested({required this.course});

  @override
  List<Object?> get props => [course];
}

class GetAllCategory extends CoursesEvent{
  final Course course;

  const GetAllCategory({required this.course});

   @override
  List<Object?> get props => [course];
}

class DeleteCourseRequested extends CoursesEvent {
  final int courseID;

  const DeleteCourseRequested({required this.courseID});

  @override
  List<Object?> get props => [courseID];
}

class CheckPaymentStatus extends CoursesEvent {
  final int courseId;

  CheckPaymentStatus(this.courseId);
}