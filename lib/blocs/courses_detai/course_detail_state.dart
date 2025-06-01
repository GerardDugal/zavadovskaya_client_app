part of 'course_detail_bloc.dart';

abstract class CourseDetailState extends Equatable {
  const CourseDetailState();

  @override
  List<Object?> get props => [];
}

class CourseDetailInitial extends CourseDetailState {}

class CourseDetailLoading extends CourseDetailState {}

class CourseDetailLoaded extends CourseDetailState {
  final Course course;
  final List<Video> videos; // Добавлено поле с видео

  const CourseDetailLoaded({
    required this.course,
    required this.videos,
  });

  @override
  List<Object?> get props => [course, videos];
}

class CourseDetailError extends CourseDetailState {
  final String error;

  const CourseDetailError({required this.error});

  @override
  List<Object?> get props => [error];
}


class VideosLoaded extends CourseDetailState {
  final List<Video> videos;

  const VideosLoaded(this.videos);

  @override
  List<Object> get props => [videos];
}