import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';
import 'package:zavadovskaya_client_app/data/repositories/course_repository.dart';

part 'video_event.dart';
part 'video_state.dart';

class VideoBloc extends Bloc<VideoEvent, VideoState> {
  final CourseRepository repository;
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;

  VideoBloc(this.repository) : super(VideoInitial()) {
    on<LoadVideoEvent>(_onLoadVideo);
    on<PlayVideoEvent>(_onPlayVideo);
    on<PauseVideoEvent>(_onPauseVideo);
    on<ToggleFullScreenEvent>(_onToggleFullScreen);
    on<DisposeVideoEvent>(_onDisposeVideo);
  }

  Future<void> _onLoadVideo(LoadVideoEvent event, Emitter<VideoState> emit) async {
    emit(VideoLoading());
    
    try {
      // Dispose previous controllers if they exist
      await _disposeControllers();
      
      _videoController = await repository.getVideoStream(event.videoId);
      
      // Initialize ChewieController
      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: event.autoPlay,
        looping: false,
        allowFullScreen: true,
        showControls: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: Colors.red,
          handleColor: Colors.red,
          backgroundColor: Colors.grey,
          bufferedColor: Colors.grey.withOpacity(0.5),
        ),
        placeholder: Container(color: Colors.black),
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Text(
              errorMessage,
              style: const TextStyle(color: Colors.white),
            ),
          );
        },
      );

      emit(VideoReady(
        videoController: _videoController!,
        chewieController: _chewieController!,
        hasAudio: true, // You can implement audio detection here
      ));
    } catch (e) {
      await _disposeControllers();
      emit(VideoError(e.toString()));
    }
  }

  Future<void> _onPlayVideo(PlayVideoEvent event, Emitter<VideoState> emit) async {
    if (state is VideoReady) {
      await _videoController?.play();
      emit((state as VideoReady).copyWith(isPlaying: true));
    }
  }

  Future<void> _onPauseVideo(PauseVideoEvent event, Emitter<VideoState> emit) async {
    if (state is VideoReady) {
      await _videoController?.pause();
      emit((state as VideoReady).copyWith(isPlaying: false));
    }
  }

  Future<void> _onToggleFullScreen(ToggleFullScreenEvent event, Emitter<VideoState> emit) async {
    if (state is VideoReady && _chewieController != null) {
      final isFullScreen = !(_chewieController!.isFullScreen);
      if (isFullScreen) {
        _chewieController!.enterFullScreen();
      } else {
        _chewieController!.exitFullScreen();
      }
      emit((state as VideoReady).copyWith(isFullScreen: isFullScreen));
    }
  }

  Future<void> _onDisposeVideo(DisposeVideoEvent event, Emitter<VideoState> emit) async {
    await _disposeControllers();
    emit(VideoInitial());
  }

  Future<void> _disposeControllers() async {
    _chewieController?.dispose();
    await _videoController?.dispose();
    _chewieController = null;
    _videoController = null;
  }

  @override
  Future<void> close() {
    _disposeControllers();
    return super.close();
  }
}