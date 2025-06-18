part of 'video_bloc.dart';

abstract class VideoEvent {}

class LoadVideoEvent extends VideoEvent {
  final int videoId;
  final bool autoPlay;

  LoadVideoEvent(this.videoId, {this.autoPlay = false});
}

class PlayVideoEvent extends VideoEvent {}

class PauseVideoEvent extends VideoEvent {}

class ToggleFullScreenEvent extends VideoEvent {}

class DisposeVideoEvent extends VideoEvent {}