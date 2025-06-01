import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';
import 'package:zavadovskaya_client_app/data/repositories/course_repository.dart';

part 'video_event.dart';
part 'video_state.dart';

class VideoBloc extends Bloc<VideoEvent, VideoState> {
  final CourseRepository repository;
  VideoPlayerController? _controller;

  VideoBloc(this.repository) : super(VideoInitial()) {
    on<LoadVideoEvent>(_onLoadVideo);
    on<PlayVideoEvent>(_onPlayVideo);
    on<PauseVideoEvent>(_onPauseVideo);
    on<DisposeVideoEvent>(_onDisposeVideo);
  }

  Future<void> _onLoadVideo(LoadVideoEvent event, Emitter<VideoState> emit) async {
    emit(VideoLoading());
    try {
      _controller = await repository.getVideoStream(event.videoId);
      emit(VideoReady(_controller!));
    } catch (e) {
      emit(VideoError(e.toString()));
    }
  }

  Future<void> _onPlayVideo(PlayVideoEvent event, Emitter<VideoState> emit) async {
    if (state.controller != null) {
      await state.controller!.play();
      emit(VideoPlaying(state.controller!));
    }
  }

  Future<void> _onPauseVideo(PauseVideoEvent event, Emitter<VideoState> emit) async {
    if (state.controller != null) {
      await state.controller!.pause();
      emit(VideoPaused(state.controller!));
    }
  }

  Future<void> _onDisposeVideo(DisposeVideoEvent event, Emitter<VideoState> emit) async {
    await _controller?.dispose();
    _controller = null;
    emit(VideoInitial());
  }

  @override
  Future<void> close() {
    _controller?.dispose();
    return super.close();
  }
}