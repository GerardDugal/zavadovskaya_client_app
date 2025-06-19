
part of 'course_detail_bloc.dart';


abstract class CourseDetailEvent extends Equatable {
  const CourseDetailEvent();

  @override
  List<Object> get props => [];
}

class GetCourseDetailRequested extends CourseDetailEvent {
  final int courseID;

  const GetCourseDetailRequested({required this.courseID});

  @override
  List<Object> get props => [courseID];
}

class GetVideosByCourseId extends CourseDetailEvent {
  final int courseId;

  const GetVideosByCourseId(this.courseId);

  @override
  List<Object> get props => [courseId];
}

class CheckPaymentStatus extends CourseDetailEvent {
  final int courseId;

  CheckPaymentStatus(this.courseId);
}