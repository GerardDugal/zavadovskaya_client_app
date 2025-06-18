part of 'video_bloc.dart';

abstract class VideoState {
  final VideoPlayerController? videoController;
  final ChewieController? chewieController;
  final bool? isPlaying;
  final bool? isFullScreen;
  final bool? hasAudio;

  VideoState({
    this.videoController,
    this.chewieController,
    this.isPlaying,
    this.isFullScreen,
    this.hasAudio,
  });
}

class VideoInitial extends VideoState {}

class VideoLoading extends VideoState {}

class VideoReady extends VideoState {
  VideoReady({
    required VideoPlayerController videoController,
    required ChewieController chewieController,
    bool hasAudio = true,
    bool isPlaying = false,
    bool isFullScreen = false,
  }) : super(
          videoController: videoController,
          chewieController: chewieController,
          hasAudio: hasAudio,
          isPlaying: isPlaying,
          isFullScreen: isFullScreen,
        );

  VideoReady copyWith({
    bool? isPlaying,
    bool? isFullScreen,
    bool? hasAudio,
  }) {
    return VideoReady(
      videoController: videoController!,
      chewieController: chewieController!,
      hasAudio: hasAudio ?? this.hasAudio!,
      isPlaying: isPlaying ?? this.isPlaying!,
      isFullScreen: isFullScreen ?? this.isFullScreen!,
    );
  }
}

class VideoError extends VideoState {
  final String message;

  VideoError(this.message);
}