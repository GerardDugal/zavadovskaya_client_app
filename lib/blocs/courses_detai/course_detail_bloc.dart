import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:zavadovskaya_client_app/blocs/courses/courses_bloc.dart';
import 'package:zavadovskaya_client_app/data/models/video.dart';
import '../../data/models/course.dart';
import '../../data/repositories/course_repository.dart';

part 'course_detail_event.dart';
part 'course_detail_state.dart';

class CourseDetailBloc extends Bloc<CourseDetailEvent, CourseDetailState> {
  final CourseRepository courseRepository;

  CourseDetailBloc({required this.courseRepository})
      : super(CourseDetailInitial()) {
    on<GetCourseDetailRequested>(_onGetCourseDetailRequested);
    on<CheckPaymentStatus>(_onCheckPaymentStatus);
  }

 Future<void> _onGetCourseDetailRequested(
  GetCourseDetailRequested event,
  Emitter<CourseDetailState> emit,
) async {
  emit(CourseDetailLoading());
  try {
    final course = await courseRepository.getCourseByID(event.courseID);
    final video = await courseRepository.getVideosByCourseId(event.courseID);

    final isPaid = await courseRepository.checkCoursePayment(event.courseID);
    final updatedCourse = course.copyWith(isPaid: isPaid); // <-- обновлённое поле

    emit(CourseDetailLoaded(course: updatedCourse, videos: video));
  } catch (error) {
    emit(CourseDetailError(error: error.toString()));
  }
}


  Future<void> _onCheckPaymentStatus(
    CheckPaymentStatus event,
    Emitter<CourseDetailState> emit,
  ) async {
    emit(PaymentChecking());
    
    try {
      final isPaid = await courseRepository.checkCoursePayment(event.courseId);
      emit(PaymentChecked(isPaid));
    } catch (e) {
      emit(PaymentError('Ошибка при проверке статуса оплаты'));
    }
  }

  Future<void> _onGetVideosByCourseId(
    GetVideosByCourseId event,
    Emitter<CourseDetailState> emit,
  ) async {
    emit(CourseDetailLoading());
    try {
      final videos = await courseRepository.getVideosByCourseId(event.courseId);
      emit(VideosLoaded(videos));
    } catch (e) {
      emit(CourseDetailError(error: e.toString()));
    }
  }
}