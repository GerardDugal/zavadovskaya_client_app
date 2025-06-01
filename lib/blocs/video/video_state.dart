part of 'video_bloc.dart';

abstract class VideoState {
  VideoPlayerController? get controller;
}

class VideoInitial extends VideoState {
  @override
  VideoPlayerController? get controller => null;
}

class VideoLoading extends VideoState {
  @override
  VideoPlayerController? get controller => null;
}

class VideoReady extends VideoState {
  final VideoPlayerController _controller;

  VideoReady(this._controller);

  @override
  VideoPlayerController? get controller => _controller;
}

class VideoPlaying extends VideoState {
  final VideoPlayerController _controller;

  VideoPlaying(this._controller);

  @override
  VideoPlayerController? get controller => _controller;
}

class VideoPaused extends VideoState {
  final VideoPlayerController _controller;

  VideoPaused(this._controller);

  @override
  VideoPlayerController? get controller => _controller;
}

class VideoError extends VideoState {
  final String message;

  VideoError(this.message);

  @override
  VideoPlayerController? get controller => null;
}